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
        [string]$GitHubToken = '',

        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $Global:OSDCloudStartTime = Get-Date
    #=======================================================================
    #   Screenshot
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:OSDCloudScreenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory "$env:TEMP\ScreenPNG"
    }
    #=======================================================================
    #	Block
    #=======================================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Warning "OSDCLOUD IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)" -NoNewline
    Write-Host -ForegroundColor Cyan " | Manufacturer: $Manufacturer | Product: $Product"
    #=======================================================================
    #	Variables and Disk Warnings
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('SkipAutopilot')) {
        $Global:OSDCloudSkipAutopilot = $true
    }
    else {
        $Global:OSDCloudSkipAutopilot = $false
    }
    if ($PSBoundParameters.ContainsKey('ZTI')) {
        $GetDisk = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if (($GetDisk | Measure-Object).Count -lt 2) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "This Warning is displayed when using the -ZTI parameter"
            Write-Warning "OSDisk will be cleaned automatically without confirmation"
            Write-Warning "Press CTRL + C to cancel"
            $GetDisk | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
            Write-Warning "OSDCloud will continue in 20 seconds"
            Start-Sleep -Seconds 20
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "More than 1 Fixed Disk is present"
            Write-Warning "Disks will not be cleaned automatically"
            Start-Sleep -Seconds 5
        }

        $Global:OSDCloudZTI = $true
        $Global:OSDCloudSkipODT = $true
    }
    else {
        $Global:OSDCloudZTI = $false
        $Global:OSDCloudSkipODT = $false
    }
    #=======================================================================
    #	Test PowerShell Gallery Connectivity
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Test-WebConnection"
    Write-Host -ForegroundColor DarkGray "powershellgallery.com"

    if (Test-WebConnection -Uri "powershellgallery.com") {
        Write-Host -ForegroundColor Green "OK"
    }
    else {
        Write-Host -ForegroundColor Red " FAILED"
        Write-Warning "Could not validate an Internet connection to the PowerShell Gallery"
        Write-Warning "OSDCloud will continue, but there may be issues if this can't be resolved"
    }
    #=======================================================================
    #	OSBuild
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSBuild " -NoNewline
    
    if ($OSBuild) {
        Write-Host -ForegroundColor Green $OSBuild
    }
    elseif ($Global:OSDCloudZTI -eq $true) {
        $OSBuild = '20H2'
        Write-Host -ForegroundColor Green $OSBuild
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSBuildNames = @('21H1','20H2','2004','1909','1903','1809')
        
        $i = $null
        $OSBuildMenu = foreach ($Item in $OSBuildNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $OSBuildMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSBuild"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSBuildMenu.Selection))))
        
        $OSBuild = $OSBuildMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSBuild: " -NoNewline
        Write-Host -ForegroundColor Green "$OSBuild"
    }
    #=======================================================================
    #	OSEdition
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSEdition " -NoNewline

    if ($PSBoundParameters.ContainsKey('OSEdition')) {
        Write-Host -ForegroundColor Green $OSEdition
    }
    elseif ($Global:OSDCloudZTI -eq $true) {
        $OSEdition = 'Enterprise'
        Write-Host -ForegroundColor Green $OSEdition
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSEditionNames = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

        $i = $null
        $OSEditionMenu = foreach ($Item in $OSEditionNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $OSEditionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSEdition"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSEditionMenu.Selection))))
        
        $OSEdition = $OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSEdition: " -NoNewline
        Write-Host -ForegroundColor Green "$OSEdition"
    }
    #=======================================================================
    #	OSEditionId and OSLicense
    #=======================================================================
    if ($OSEdition -eq 'Home') {
        $OSEditionId = 'Core'
        $OSLicense = 'Retail'
        $ImageIndex = 4
    }
    if ($OSEdition -eq 'Home N') {
        $OSEditionId = 'CoreN'
        $OSLicense = 'Retail'
        $ImageIndex = 5
    }
    if ($OSEdition -eq 'Home Single Language') {
        $OSEditionId = 'CoreSingleLanguage'
        $OSLicense = 'Retail'
        $ImageIndex = 6
    }
    if ($OSEdition -eq 'Enterprise') {
        $OSEditionId = 'Enterprise'
        $OSLicense = 'Volume'
        $ImageIndex = 6
    }
    if ($OSEdition -eq 'Enterprise N') {
        $OSEditionId = 'EnterpriseN'
        $OSLicense = 'Volume'
        $ImageIndex = 7
    }
    #=======================================================================
    #	OSLicense
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSLicense " -NoNewline

    if ($OSLicense) {
        Write-Host -ForegroundColor Green $OSLicense
    }
    elseif ($Global:OSDCloudZTI -eq $true) {
        $OSLicense = 'Volume'
        Write-Host -ForegroundColor Green $OSLicense
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSLicenseNames = @('Retail Windows 10 Consumer Editions','Volume Windows 10 Business Editions')
        
        $i = $null
        $OSLicenseMenu = foreach ($Item in $OSLicenseNames) {
            $i++
        
            $ObjectProperties = @{
                Selection           = $i
                Name                = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $OSLicenseMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 License"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSLicenseMenu.Selection))))
        
        $OSLicenseMenu = $OSLicenseMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

        if ($OSLicenseMenu -match 'Retail') {
            $OSLicense = 'Retail'
        }
        else {
            $OSLicense = 'Volume'
        }
        Write-Host -ForegroundColor Cyan "OSLicense: " -NoNewline
        Write-Host -ForegroundColor Green "$OSLicense"
    }
    if ($OSEdition -eq 'Education') {
        $OSEditionId = 'Education'
        if ($OSLicense -eq 'Retail') {$ImageIndex = 7}
        if ($OSLicense -eq 'Volume') {$ImageIndex = 4}
    }
    if ($OSEdition -eq 'Education N') {
        $OSEditionId = 'EducationN'
        if ($OSLicense -eq 'Retail') {$ImageIndex = 8}
        if ($OSLicense -eq 'Volume') {$ImageIndex = 5}
    }
    if ($OSEdition -eq 'Pro') {
        $OSEditionId = 'Professional'
        if ($OSLicense -eq 'Retail') {$ImageIndex = 9}
        if ($OSLicense -eq 'Volume') {$ImageIndex = 8}
    }
    if ($OSEdition -eq 'Pro N') {
        $OSEditionId = 'ProfessionalN'
        if ($OSLicense -eq 'Retail') {$ImageIndex = 10}
        if ($OSLicense -eq 'Volume') {$ImageIndex = 9}
    }
    Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
    Write-Host -ForegroundColor Green "$OSEditionId"
    Write-Host -ForegroundColor Cyan "ImageIndex: " -NoNewline
    Write-Host -ForegroundColor Green "$ImageIndex"
    #=======================================================================
    #	OSLanguage
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSLanguage " -NoNewline
    
    if ($PSBoundParameters.ContainsKey('OSLanguage')) {
        Write-Host -ForegroundColor Green $OSLanguage
    }
    elseif ($Global:OSDCloudZTI -eq $true) {
        $OSLanguage = 'en-us'
        Write-Host -ForegroundColor Green $OSLanguage
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSLanguageNames = @('ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr','en-gb','en-us','es-es','es-mx','et-ee','fi-fi','fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it','ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl','pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk','sl-si','sr-latn-rs','sv-se','th-th','tr-tr','uk-ua','zh-cn','zh-tw')
        
        $i = $null
        $OSLanguageMenu = foreach ($Item in $OSLanguageNames) {
            $i++
        
            $ObjectProperties = @{
                Selection   = $i
                Name     = $Item
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        $OSLanguageMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
        
        do {
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows 10 OSLanguage"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSLanguageMenu.Selection))))
        
        $OSLanguage = $OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
        Write-Host -ForegroundColor Green "$OSLanguage"
    }
    #=======================================================================
    #	Get-FeatureUpdate
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-FeatureUpdate"
    Write-Host -ForegroundColor DarkGray "Windows 10 x64 | OSLicense: $OSLicense | OSBuild: $OSBuild | OSLanguage: $OSLanguage"

    $GetFeatureUpdate = Get-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage

    if ($GetFeatureUpdate) {
        $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    }
    else {
        Write-Warning "Unable to locate a Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Get-FeatureUpdate Source
    #=======================================================================
    $OSDCloudOfflineOS = Find-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

    if ($OSDCloudOfflineOS) {
        $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
        Write-Host -ForegroundColor Green "OK"
        Write-Host -ForegroundColor DarkGray "$($GetFeatureUpdate.Title)"
        Write-Host -ForegroundColor DarkGray "$OSDCloudOfflineOSFullName"
    }
    elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
        Write-Host -ForegroundColor Yellow "Download"
        Write-Host -ForegroundColor Yellow "$($GetFeatureUpdate.Title)"
        Write-Host -ForegroundColor Yellow "$($GetFeatureUpdate.FileUri)"
    }
    else {
        Write-Warning "Could not verify an Internet connection for Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Start-OSDCloud Get-MyDriverPack
    #=======================================================================
    if ($Product -ne 'None') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDriverPack"
        
        if ($PSBoundParameters.ContainsKey('Manufacturer')) {
            $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
        }
        else {
            $GetMyDriverPack = Get-MyDriverPack -Product $Product
        }
    
        if ($GetMyDriverPack) {
            Write-Host -ForegroundColor DarkGray "Name: $($GetMyDriverPack.Name)"
            Write-Host -ForegroundColor DarkGray "Product: $($GetMyDriverPack.Product)"
    
            $GetOSDCloudOfflineFile = Find-OSDCloudOfflineFile -Name $GetMyDriverPack.FileName | Select-Object -First 1
            if ($GetOSDCloudOfflineFile) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray "$($GetOSDCloudOfflineFile.FullName)"
            }
            elseif (Test-WebConnection -Uri $GetMyDriverPack.DriverPackUrl) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow "$($GetMyDriverPack.DriverPackUrl)"
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
    if ($Manufacturer -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDellBios"

        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.Name)"
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.ReleaseDate)"

            $GetOSDCloudOfflineFile = Find-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1

            if ($OSDCloudOfflineBios) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray "$($OSDCloudOfflineBios.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow "$($GetMyDellBios.Url)"
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios Update"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }

            $OSDCloudOfflineFlash64W = Find-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
            if ($OSDCloudOfflineFlash64W) {
                Write-Host -ForegroundColor DarkGray "$($OSDCloudOfflineFlash64W.FullName)"
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
    }
    #=======================================================================
    #	Autopilot Profiles
    #=======================================================================
    if ($Global:OSDCloudSkipAutopilot -eq $false) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Find-OSDCloudAutopilotFile"
    
        $GetOSDCloudAutopilotFile = Find-OSDCloudAutopilotFile
    
        if ($GetOSDCloudAutopilotFile) {
            Write-Host -ForegroundColor Green "OK"
            if ($Global:OSDCloudZTI -eq $true) {
                Write-Warning "-SkipAutopilot parameter can be used to skip Autopilot Configuration"
                Write-Warning "-ZTI automatically selects the first Autopilot Profile listed below"
                Write-Warning "Rename your Autopilot Configuration Files so your default is the first Selection"
            }
            foreach ($Item in $GetOSDCloudAutopilotFile) {
                Write-Host -ForegroundColor DarkGray "$($Item.FullName)"
            }
        } else {
            Write-Warning "No Autopilot Profiles were found in any PSDrive"
            Write-Warning "Autopilot Profiles must be located in a <PSDrive>:\OSDCloud\Autopilot\Profiles directory"
        }
    }
    #=======================================================================
    #	Global Variables
    #=======================================================================
    $Global:OSDCloudOSBuild = $OSBuild
    $Global:OSDCloudOSEdition = $OSEdition
    $Global:OSDCloudOSEditionId = $OSEditionId
    $Global:OSDCloudOSLicense = $OSLicense
    $Global:OSDCloudOSLanguage = $OSLanguage
    $Global:OSDCloudOSImageIndex = $ImageIndex
    $Global:OSDCloudManufacturer = $Manufacturer
    $Global:OSDCloudProduct = $Product
    #=======================================================================
    #   Module
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Module') {
        $GetDeployOSDCloud = Find-OSDCloudOfflineFile -Name 'Deploy-MyOSDCloud.ps1' | Select-Object -First 1
        if ($GetDeployOSDCloud) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Starting in 5 seconds..."
            Write-Host -ForegroundColor Green "$($GetDeployOSDCloud.FullName)"
            Start-Sleep -Seconds 5
            & "$($GetDeployOSDCloud.FullName)"
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Starting in 5 seconds..."
            Write-Host -ForegroundColor Green "$($MyInvocation.MyCommand.Module.ModuleBase)\OSDCloud\Deploy-OSDCloud.ps1"
            Start-Sleep -Seconds 5
            & "$($MyInvocation.MyCommand.Module.ModuleBase)\OSDCloud\Deploy-OSDCloud.ps1"
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