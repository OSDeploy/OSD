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

.LINK
https://osdcloud.osdeploy.com/

.NOTES
#>
function Start-OSDCloud {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),

        [string]$Product = (Get-MyComputerProduct),

        [switch]$Screenshot,

        [switch]$SkipAutopilot,

        [switch]$SkipODT,

        [switch]$UpdateFirmware,

        [switch]$ZTI,

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild,

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')]
        [Alias('Edition')]
        [string]$OSEdition,

        [Parameter(ParameterSetName = 'Default')]
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

        [ValidateSet('Retail','Volume')]
        [string]$OSLicense,

        [Parameter(ParameterSetName = 'CustomImage')]
        [switch]$FindImageFile,

        [Parameter(ParameterSetName = 'CustomImage')]
        [string]$ImageFileUrl,

        [Parameter(ParameterSetName = 'CustomImage')]
        [int32]$ImageIndex = 1
    )
    #=======================================================================
    #	Create Hashtable
    #=======================================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
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
        ImageFileUrl = $ImageFileUrl
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = $Manufacturer
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
        OSLicense = $OSLicense
        OSImageIndex = $ImageIndex
        Product = $Product
        Screenshot = $null
        SkipAutopilot = $SkipAutopilot
        SkipODT = $SkipODT
        TimeStart = Get-Date
        UpdateFirmware = $UpdateFirmware
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
    #	ParameterSet CustomImage
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'CustomImage') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Custom Windows Image"

        if ($StartOSDCloud.ImageFileUrl) {
            Write-Host -ForegroundColor DarkGray "ImageFileUrl: $($StartOSDCloud.ImageFileUrl)"
            Write-Host -ForegroundColor DarkGray "ImageIndex: $($StartOSDCloud.OSImageIndex)"
        }
        if ($PSBoundParameters.ContainsKey('FindImageFile')) {
            $StartOSDCloud.ImageFileOffline = Select-OSDCloudFile.wim
        
            if ($StartOSDCloud.ImageFileOffline) {
                $StartOSDCloud.OSImageIndex = Select-OSDCloudImageIndex -ImagePath $StartOSDCloud.ImageFileOffline.FullName

                Write-Host -ForegroundColor DarkGray "ImageFileOffline: $($StartOSDCloud.ImageFileOffline.FullName)"
                Write-Host -ForegroundColor DarkGray "OSImageIndex: $($StartOSDCloud.OSImageIndex)"
            }
            else {
                $StartOSDCloud.ImageFileOffline = $null
                $StartOSDCloud.OSImageIndex = 1
                #$Global:OSDImageParent = $null
                #$Global:OSDCloudWimFullName = $null
                Write-Warning "Custom Windows Image on USB was not found"
                Break
            }
        }
    }
    #=======================================================================
    #	ParameterSet Default
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        #=======================================================================
        #	OSBuild
        #=======================================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Windows 10 OSBuild " -NoNewline
        
        if ($StartOSDCloud.OSBuild) {
            Write-Host -ForegroundColor Green $StartOSDCloud.OSBuild
        }
        elseif ($StartOSDCloud.ZTI) {
            $StartOSDCloud.OSBuild = '21H1'
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
            $StartOSDCloud.ImageFileName = $StartOSDCloud.GetFeatureUpdate.FileName
            $StartOSDCloud.ImageFileUrl = $StartOSDCloud.GetFeatureUpdate.FileUri
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
    #	Update Firmware
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "UpdateFirmware"
    $SystemFirmwareResource = Get-SystemFirmwareResource
    if ($SystemFirmwareResource) {
        if ($UpdateFirmware) {
            Write-Host -ForegroundColor DarkGray "Firmware will be updated for $SystemFirmwareResource"
        }
        else {
            Write-Host -ForegroundColor DarkGray "Firmware will not be updated for $SystemFirmwareResource"
        }
    }
    else {
        Write-Warning "Unable to get a System Firmware Resource"
        $UpdateFirmware = $false
    }
    #=======================================================================
    #   Invoke-OSDCloud.ps1
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
    #=======================================================================
}