<#
.SYNOPSIS
Starts the OSDCloud Windows 10 Build Process from the OSD Module or a GitHub Repository

.DESCRIPTION
Starts the OSDCloud Windows 10 Build Process from the OSD Module or a GitHub Repository

.PARAMETER OSEdition
Edition of the Windows installation

.PARAMETER OSLanguage
Language of the Windows installation
Alias = Culture, Language

.PARAMETER Screenshot
Captures screenshots during OSDCloud

.PARAMETER GitHub
Starts OSDCloud from GitHub
GitHub Variable Url: $GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript
GitHub Resolved Url: https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/Start-OSDCloud.ps1

.PARAMETER GitHubBaseUrl
The GitHub Base URL

.PARAMETER GitHubUser
GitHub Repository User

.PARAMETER GitHubRepository
OSDCloud Repository

.PARAMETER GitHubBranch
Branch of the Repository

.PARAMETER GitHubScript
Script to execute

.PARAMETER GitHubToken
Used to access a GitHub Private Repository

.LINK
https://osdcloud.osdeploy.com/

.NOTES
#>
function Start-OSDCloud {
    [CmdletBinding(DefaultParameterSetName = 'Module')]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),

        [string]$Product = (Get-MyComputerProduct),

        [ValidateSet('21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild,

        [ValidateSet('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')]
        [Alias('Edition')]
        [string]$OSEdition,

        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture','OSCulture')]
        [string]$OSLanguage,

        [switch]$Screenshot,

        [switch]$SkipAutopilot,

        [switch]$SkipODT,

        [switch]$ZTI,

        [Parameter(ParameterSetName = 'GitHub')]
        [switch]$GitHub,

        [Parameter(ParameterSetName = 'GitHub')]
        [string]$GitHubBaseUrl = 'https://raw.githubusercontent.com',
        
        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('U','User')]
        [string]$GitHubUser = 'OSDeploy',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('R','Repository')]
        [string]$GitHubRepository = 'OSDCloud',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('B','Branch')]
        [string]$GitHubBranch = 'main',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('S','Script')]
        [string]$GitHubScript = 'Deploy-OSDCloud.ps1',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('T','Token')]
        [string]$GitHubToken = ''
    )
    #=======================================================================
    #	Create Hashtable
    #=======================================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
        AutopilotConfigurationFile = 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        AutopilotFile = $null
        AutopilotFiles = $null
        AutopilotJsonName = $null
        AutopilotJsonString = $null
        AutopilotJsonUrl = $null
        AutopilotObject = $null
        BuildName = 'OSDCloud'
        DriverPackUrl = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        ImageFileOffline = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileTarget = $null
        ImageFileUri = $null
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = $Manufacturer
        ODTConfigFile = 'C:\OSDCloud\ODT\Config.xml'
        ODTFile = $null
        ODTFiles = $null
        ODTSetupFile = $null
        ODTSource = $null
        ODTTarget = 'C:\OSDCloud\ODT'
        ODTTargetData = 'C:\OSDCloud\ODT\Office'
        OSBuild = $OSBuild
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSLicense = $null
        OSImageIndex = 1
        Product = $Product
        Screenshot = $null
        SkipAutopilot = $SkipAutopilot
        SkipODT = $SkipODT
        TimeStart = Get-Date
        ZTI = $ZTI
    }
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #	-Screenshot
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $StartOSDCloud.Screenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory $StartOSDCloud.Screenshot
    }
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloud"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($StartOSDCloud.Function)" -NoNewline
    Write-Host -ForegroundColor Cyan " | Manufacturer: $Manufacturer | Product: $Product"
    #=======================================================================
    #	-ZTI
    #=======================================================================
    if ($StartOSDCloud.ZTI) {
        $StartOSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if (($StartOSDCloud.GetDiskFixed | Measure-Object).Count -lt 2) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "This Warning is displayed when using the -ZTI parameter"
            Write-Warning "OSDisk will be cleaned automatically without confirmation"
            Write-Warning "Press CTRL + C to cancel"
            $StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
            Write-Warning "OSDCloud will continue in 5 seconds"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "More than 1 Fixed Disk is present"
            Write-Warning "Disks will not be cleaned automatically"
            $StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
            Start-Sleep -Seconds 5
        }
    }
    #=======================================================================
    #	Battery
    #=======================================================================
    if ($StartOSDCloud.IsOnBattery) {
        Write-Warning "This computer is currently running on Battery"
    }
    #=======================================================================
    #	Test Web Connection
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Test-WebConnection"
    Write-Host -ForegroundColor DarkGray "google.com"

    if (Test-WebConnection -Uri "google.com") {
        Write-Host -ForegroundColor Green "OK"
    }
    else {
        Write-Host -ForegroundColor Red " FAILED"
        Write-Warning "Could not validate an Internet connection"
        Write-Warning "OSDCloud will continue, but there may be issues if this can't be resolved"
    }
    #=======================================================================
    #	OSBuild
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSBuild " -NoNewline
    
    if ($StartOSDCloud.OSBuild) {
        Write-Host -ForegroundColor Green $StartOSDCloud.OSBuild
    }
    elseif ($StartOSDCloud.ZTI) {
        $StartOSDCloud.OSBuild = '20H2'
        Write-Host -ForegroundColor Green $StartOSDCloud.OSBuild
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $StartOSDCloud.OSBuildNames = @('21H1','20H2','2004','1909','1903','1809')
        
        $i = $null
        $StartOSDCloud.OSBuildMenu = foreach ($Item in $StartOSDCloud.OSBuildNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $StartOSDCloud.OSBuildMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSBuild"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $StartOSDCloud.OSBuildMenu.Selection))))
        
        $StartOSDCloud.OSBuild = $StartOSDCloud.OSBuildMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSBuild: " -NoNewline
        Write-Host -ForegroundColor Green $StartOSDCloud.OSBuild
    }
    #=======================================================================
    #	OSEdition
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSEdition " -NoNewline

    if ($StartOSDCloud.OSEdition) {
        Write-Host -ForegroundColor Green $StartOSDCloud.OSEdition
    }
    elseif ($ZTI) {
        $StartOSDCloud.OSEdition = 'Enterprise'
        Write-Host -ForegroundColor Green $StartOSDCloud.OSEdition
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $StartOSDCloud.OSEditionNames = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

        $i = $null
        $StartOSDCloud.OSEditionMenu = foreach ($Item in $StartOSDCloud.OSEditionNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $StartOSDCloud.OSEditionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSEdition"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $StartOSDCloud.OSEditionMenu.Selection))))
        
        $StartOSDCloud.OSEdition = $StartOSDCloud.OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSEdition: " -NoNewline
        Write-Host -ForegroundColor Green $StartOSDCloud.OSEdition
    }
    #=======================================================================
    #	OSEditionId and OSLicense
    #=======================================================================
    if ($StartOSDCloud.OSEdition -eq 'Home') {
        $StartOSDCloud.OSEditionId = 'Core'
        $StartOSDCloud.OSLicense = 'Retail'
        $StartOSDCloud.OSImageIndex = 4
    }
    if ($StartOSDCloud.OSEdition -eq 'Home N') {
        $StartOSDCloud.OSEditionId = 'CoreN'
        $StartOSDCloud.OSLicense = 'Retail'
        $StartOSDCloud.OSImageIndex = 5
    }
    if ($StartOSDCloud.OSEdition -eq 'Home Single Language') {
        $StartOSDCloud.OSEditionId = 'CoreSingleLanguage'
        $StartOSDCloud.OSLicense = 'Retail'
        $StartOSDCloud.OSImageIndex = 6
    }
    if ($StartOSDCloud.OSEdition -eq 'Enterprise') {
        $StartOSDCloud.OSEditionId = 'Enterprise'
        $StartOSDCloud.OSLicense = 'Volume'
        $StartOSDCloud.OSImageIndex = 6
    }
    if ($StartOSDCloud.OSEdition -eq 'Enterprise N') {
        $StartOSDCloud.OSEditionId = 'EnterpriseN'
        $StartOSDCloud.OSLicense = 'Volume'
        $StartOSDCloud.OSImageIndex = 7
    }
    #=======================================================================
    #	OSLicense
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSLicense " -NoNewline

    if ($StartOSDCloud.OSLicense) {
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLicense
    }
    elseif ($StartOSDCloud.ZTI) {
        $StartOSDCloud.OSLicense = 'Volume'
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLicense
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $StartOSDCloud.OSLicenseNames = @('Retail Windows 10 Consumer Editions','Volume Windows 10 Business Editions')
        
        $i = $null
        $StartOSDCloud.OSLicenseMenu = foreach ($Item in $StartOSDCloud.OSLicenseNames) {
            $i++
        
            $ObjectProperties = @{
                Selection           = $i
                Name                = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $StartOSDCloud.OSLicenseMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 License"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $StartOSDCloud.OSLicenseMenu.Selection))))
        
        $StartOSDCloud.OSLicenseMenu = $StartOSDCloud.OSLicenseMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

        if ($StartOSDCloud.OSLicenseMenu -match 'Retail') {
            $StartOSDCloud.OSLicense = 'Retail'
        }
        else {
            $StartOSDCloud.OSLicense = 'Volume'
        }
        Write-Host -ForegroundColor Cyan "OSLicense: " -NoNewline
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLicense
    }
    if ($StartOSDCloud.OSEdition -eq 'Education') {
        $StartOSDCloud.OSEditionId = 'Education'
        if ($StartOSDCloud.OSLicense -eq 'Retail') {$StartOSDCloud.OSImageIndex = 7}
        if ($StartOSDCloud.OSLicense -eq 'Volume') {$StartOSDCloud.OSImageIndex = 4}
    }
    if ($StartOSDCloud.OSEdition -eq 'Education N') {
        $StartOSDCloud.OSEditionId = 'EducationN'
        if ($StartOSDCloud.OSLicense -eq 'Retail') {$StartOSDCloud.OSImageIndex = 8}
        if ($StartOSDCloud.OSLicense -eq 'Volume') {$StartOSDCloud.OSImageIndex = 5}
    }
    if ($StartOSDCloud.OSEdition -eq 'Pro') {
        $StartOSDCloud.OSEditionId = 'Professional'
        if ($StartOSDCloud.OSLicense -eq 'Retail') {$StartOSDCloud.OSImageIndex = 9}
        if ($StartOSDCloud.OSLicense -eq 'Volume') {$StartOSDCloud.OSImageIndex = 8}
    }
    if ($StartOSDCloud.OSEdition -eq 'Pro N') {
        $StartOSDCloud.OSEditionId = 'ProfessionalN'
        if ($StartOSDCloud.OSLicense -eq 'Retail') {$StartOSDCloud.OSImageIndex = 10}
        if ($StartOSDCloud.OSLicense -eq 'Volume') {$StartOSDCloud.OSImageIndex = 9}
    }
    Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
    Write-Host -ForegroundColor Green $StartOSDCloud.OSEditionId
    Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
    Write-Host -ForegroundColor Green $StartOSDCloud.OSImageIndex
    #=======================================================================
    #	OSLanguage
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSLanguage " -NoNewline
    
    if ($PSBoundParameters.ContainsKey('OSLanguage')) {
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLanguage
    }
    elseif ($ZTI) {
        $StartOSDCloud.OSLanguage = 'en-us'
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLanguage
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $StartOSDCloud.OSLanguageNames = @('ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr','en-gb','en-us','es-es','es-mx','et-ee','fi-fi','fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it','ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl','pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk','sl-si','sr-latn-rs','sv-se','th-th','tr-tr','uk-ua','zh-cn','zh-tw')
        
        $i = $null
        $StartOSDCloud.OSLanguageMenu = foreach ($Item in $StartOSDCloud.OSLanguageNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $StartOSDCloud.OSLanguageMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSLanguage"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $StartOSDCloud.OSLanguageMenu.Selection))))
        
        $StartOSDCloud.OSLanguage = $StartOSDCloud.OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
        Write-Host -ForegroundColor Green $StartOSDCloud.OSLanguage
    }
    #=======================================================================
    #	Get-FeatureUpdate
    #   This is where we take the OSB OSE OSL information and get the
    #   Feature Update.  Global Variables will be set for Deploy-OSDCloud
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-FeatureUpdate"
    Write-Host -ForegroundColor DarkGray "Windows 10 x64 | OSLicense: $($StartOSDCloud.OSLicense) | OSBuild: $($StartOSDCloud.OSBuild) | OSLanguage: $($StartOSDCloud.OSLanguage)"

    $StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate -OSLicense $StartOSDCloud.OSLicense -OSBuild $StartOSDCloud.OSBuild -OSLanguage $StartOSDCloud.OSLanguage

    if ($StartOSDCloud.GetFeatureUpdate) {
        $StartOSDCloud.GetFeatureUpdate = $StartOSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    }
    else {
        Write-Warning "Unable to locate a Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Get-FeatureUpdate Offline
    #   Determine if the OS is Offline
    #   Need to bail if the file is Online is not valid or not Offline
    #=======================================================================
    $StartOSDCloud.ImageFileOffline = Find-OSDCloudFile -Name $StartOSDCloud.GetFeatureUpdate.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
    $StartOSDCloud.ImageFileOffline = $StartOSDCloud.ImageFileOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

    if ($StartOSDCloud.ImageFileOffline) {
        Write-Host -ForegroundColor Green "OK"
        Write-Host -ForegroundColor DarkGray $StartOSDCloud.GetFeatureUpdate.Title
        Write-Host -ForegroundColor DarkGray $StartOSDCloud.ImageFileOffline.FullName
    }
    elseif (Test-WebConnection -Uri $StartOSDCloud.GetFeatureUpdate.FileUri) {
        Write-Host -ForegroundColor Yellow "Download"
        Write-Host -ForegroundColor Yellow $StartOSDCloud.GetFeatureUpdate.Title
        Write-Host -ForegroundColor Yellow $StartOSDCloud.GetFeatureUpdate.FileUri
    }
    else {
        Write-Warning "Could not verify an Internet connection for Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Start-OSDCloud Get-MyDriverPack
    #=======================================================================
    if ($StartOSDCloud.Product -ne 'None') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDriverPack"
        
        $StartOSDCloud.GetMyDriverPack = Get-MyDriverPack -Manufacturer $StartOSDCloud.Manufacturer -Product $StartOSDCloud.Product

    
        if ($StartOSDCloud.GetMyDriverPack) {
            Write-Host -ForegroundColor DarkGray "Name: $($StartOSDCloud.GetMyDriverPack.Name)"
            Write-Host -ForegroundColor DarkGray "Product: $($StartOSDCloud.GetMyDriverPack.Product)"


            $StartOSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $StartOSDCloud.GetMyDriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
            $StartOSDCloud.DriverPackOffline = $StartOSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

            if ($StartOSDCloud.DriverPackOffline) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray $StartOSDCloud.DriverPackOffline.FullName
            }
            elseif (Test-WebConnection -Uri $StartOSDCloud.GetMyDriverPack.DriverPackUrl) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow $StartOSDCloud.GetMyDriverPack.DriverPackUrl
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
        }
    }
    #=======================================================================
    #	Get-MyDellBios
    #=======================================================================
<#     if ($Manufacturer -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDellBios"

        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.Name)"
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.ReleaseDate)"

            $GetOSDCloudOfflineFile = Find-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1

            if ($StartOSDCloudOfflineBios) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray "$($StartOSDCloudOfflineBios.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow "$($GetMyDellBios.Url)"
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios Update"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }

            $StartOSDCloudOfflineFlash64W = Find-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
            if ($StartOSDCloudOfflineFlash64W) {
                Write-Host -ForegroundColor DarkGray "$($StartOSDCloudOfflineFlash64W.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                Write-Host -ForegroundColor Yellow "$($GetMyDellBios.Flash64W)"
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Flash64W"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    } #>
    #=======================================================================
    #	List Autopilot Profiles
    #=======================================================================
<#     if (!($SkipAutopilot -eq $true)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "OSDCloud Autopilot"
        
        $FindOSDCloudFile = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
        $FindOSDCloudFile = $FindOSDCloudFile | Where-Object {$_.FullName -notlike "C*"}
    
        if ($FindOSDCloudFile) {
            Write-Host -ForegroundColor Green "OK"
            if ($ZTI) {
                Write-Warning "-SkipAutopilot parameter can be used to skip Autopilot Configuration"
                Write-Warning "-ZTI automatically selects the first Autopilot Profile listed below"
                Write-Warning "Rename your Autopilot Configuration Files so your default is the first Selection"
            }
            foreach ($Item in $FindOSDCloudFile) {
                Write-Host -ForegroundColor DarkGray "$($Item.FullName)"
            }
        } else {
            Write-Warning "No Autopilot Profiles were found in any PSDrive"
            Write-Warning "Autopilot Profiles must be located in a <PSDrive>:\OSDCloud\Autopilot\Profiles directory"
        }
    } #>
    #=======================================================================
    #   Module
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Module') {
        $DeployMyOSDCloud = Find-OSDCloudOfflineFile -Name 'Deploy-MyOSDCloud.ps1' | Select-Object -First 1
        if ($DeployMyOSDCloud) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Starting in 5 seconds..."
            Write-Host -ForegroundColor Green "$($DeployMyOSDCloud.FullName)"
            Start-Sleep -Seconds 5
            & "$($DeployMyOSDCloud.FullName)"
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-DeployOSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            Invoke-DeployOSDCloud
        }
    }
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        if (-NOT (Test-WebConnection -Uri $GitHubBaseUrl)) {
            Write-Warning "Could not verify an Internet connection to $Global:GitHubUrl"
            Write-Warning "OSDCloud -GitHub cannot continue"
            Write-Warning "Verify you have an Internet connection or remove the -GitHub parameter"
            Break
        }

        if ($PSBoundParameters['Token']) {
            $Global:GitHubUrl = "$GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript`?token=$GitHubToken"
        } else {
            $Global:GitHubUrl = "$GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript"
        }

        if (-NOT (Test-WebConnection -Uri $Global:GitHubUrl)) {
            Write-Warning "Could not verify an Internet connection to $Global:GitHubUrl"
            Write-Warning "OSDCloud -GitHub cannot continue"
            Write-Warning "Verify you have an Internet connection or remove the -GitHub parameter"
            Break
        }

        $Global:GitHubBaseUrl = $GitHubBaseUrl
        $Global:GitHubUser = $GitHubUser
        $Global:GitHubRepository = $GitHubRepository
        $Global:GitHubBranch = $GitHubBranch
        $Global:GitHubScript = $GitHubScript
        $Global:GitHubToken = $GitHubToken

        Write-Host -ForegroundColor Cyan "Starting $($Global:GitHubUrl)"
        Start-Sleep -Seconds 5
        Invoke-WebPSScript -WebPSScript $Global:GitHubUrl
    }
    #=======================================================================
}