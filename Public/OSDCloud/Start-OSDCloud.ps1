<#
.SYNOPSIS
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

.DESCRIPTION
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

.PARAMETER Manufacturer
Automatically populated from Get-MyComputerManufacturer -Brief
Overrides the System Manufacturer for Driver matching

.PARAMETER Product
Automatically populated from Get-MyComputerProduct
Overrides the System Product for Driver matching

.PARAMETER Firmware
$Global:StartOSDCloud.ApplyCatalogFirmware = $true

.PARAMETER Restart
Restart the computer after Invoke-OSDCloud to OOBE

.PARAMETER Shutdown
Shutdown the computer after Invoke-OSDCloud

.PARAMETER Screenshot
Captures screenshots during OSDCloud WinPE

.PARAMETER SkipAutopilot
Skips the Autopilot Task routine

.PARAMETER SkipODT
Skips the ODT Task routine

.PARAMETER ZTI
Skip prompting to wipe Disks

.PARAMETER OSBuild
ParameterSet Default
Operating System Build of the Windows installation
Alias = Build

.PARAMETER OSEdition
ParameterSet Default
Operating System Edition of the Windows installation
Alias = Edition

.PARAMETER OSLanguage
ParameterSet Default
Operating System Language of the Windows installation
Alias = Culture, OSCulture

.PARAMETER OSLicense

.PARAMETER FindImageFile
ParameterSet CustomImage

.PARAMETER ImageFileUrl
ParameterSet CustomImage

.PARAMETER ImageIndex
ParameterSet CustomImage

.LINK
https://osdcloud.osdeploy.com/

.NOTES
#>
function Start-OSDCloud {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct),

        [switch]$Firmware,
        [switch]$Restart,
        [switch]$Shutdown,
        [switch]$Screenshot,
        [switch]$SkipAutopilot,
        [switch]$SkipODT,
        [switch]$ZTI,

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('21H2','21H1','20H2','2004','1909','1903','1809')]
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
    #=================================================
    #	$Global:StartOSDCloud
    #=================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
        ApplyManufacturerDrivers = $true
        ApplyCatalogDrivers = $true
        ApplyCatalogFirmware = $false
        AutopilotJsonChildItem = $null
        AutopilotJsonItem = $null
        AutopilotJsonName = $null
        AutopilotJsonObject = $null
        AutopilotOOBEJsonChildItem = $null
        AutopilotOOBEJsonItem = $null
        AutopilotOOBEJsonName = $null
        AutopilotOOBEJsonObject = $null
        DriverPackUrl = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileTarget = $null
        ImageFileUrl = $ImageFileUrl
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = $Manufacturer
        OOBEDeployJsonChildItem = $null
        OOBEDeployJsonItem = $null
        OOBEDeployJsonName = $null
        OOBEDeployJsonObject = $null
        OSBuild = $OSBuild
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSImageIndex = $ImageIndex
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSLicense = $OSLicense
        OSVersion = 'Windows 10'
        Product = $Product
        Restart = $Restart
        Screenshot = $Screenshot
        Shutdown = $Shutdown
        SkipAutopilot = $SkipAutopilot
        SkipAutopilotOOBE = $null
        SkipODT = $SkipODT
        SkipOOBEDeploy = $null
        TimeStart = Get-Date
        ZTI = $ZTI
    }
    #=================================================
    #	Update Defaults
    #=================================================
    if ($Firmware) {
        $Global:StartOSDCloud.ApplyCatalogFirmware = $true
    }
    #=================================================
    #	$Global:StartOSDCloudGUI
    #=================================================
    if ($Global:StartOSDCloudGUI) {
        foreach ($Key in $Global:StartOSDCloudGUI.Keys) {
            $Global:StartOSDCloud.$Key = $Global:StartOSDCloudGUI.$Key
        }
    }
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	-Screenshot
    #=================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:StartOSDCloud.Screenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory $Global:StartOSDCloud.Screenshot
    }
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloud"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Global:StartOSDCloud.Function)" -NoNewline
    Write-Host -ForegroundColor Cyan " | Manufacturer: $Manufacturer | Product: $Product"
    #=================================================
    #	-ZTI
    #=================================================
    if ($Global:StartOSDCloud.ZTI) {
        $Global:StartOSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if (($Global:StartOSDCloud.GetDiskFixed | Measure-Object).Count -lt 2) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "This Warning is displayed when using the -ZTI parameter"
            Write-Warning "OSDisk will be cleaned automatically without confirmation"
            Write-Warning "Press CTRL + C to cancel"
            $Global:StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
            Write-Warning "OSDCloud will continue in 5 seconds"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "More than 1 Fixed Disk is present"
            Write-Warning "Disks will not be cleaned automatically"
            $Global:StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
            Start-Sleep -Seconds 5
        }
    }
    #=================================================
    #	Battery
    #=================================================
    if ($Global:StartOSDCloud.IsOnBattery) {
        Write-Warning "This computer is currently running on Battery"
    }
    #=================================================
    #	Test Web Connection
    #=================================================
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
    #=================================================
    #	Custom Image
    #=================================================
    if ($Global:StartOSDCloud.ImageFileFullName -and $Global:StartOSDCloud.ImageFileItem -and $Global:StartOSDCloud.ImageFileName) {
        #Custom Image set in OSDCloudGUI
    }
    #=================================================
    #	ParameterSet CustomImage
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'CustomImage') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Custom Windows Image"

        if ($Global:StartOSDCloud.ImageFileUrl) {
            Write-Host -ForegroundColor DarkGray "ImageFileUrl: $($Global:StartOSDCloud.ImageFileUrl)"
            Write-Host -ForegroundColor DarkGray "ImageIndex: $($Global:StartOSDCloud.OSImageIndex)"
        }
        if ($PSBoundParameters.ContainsKey('FindImageFile')) {
            $Global:StartOSDCloud.ImageFileItem = Select-OSDCloudFile.wim
        
            if ($Global:StartOSDCloud.ImageFileItem) {
                $Global:StartOSDCloud.OSImageIndex = Select-OSDCloudImageIndex -ImagePath $Global:StartOSDCloud.ImageFileItem.FullName

                Write-Host -ForegroundColor DarkGray "ImageFileItem: $($Global:StartOSDCloud.ImageFileItem.FullName)"
                Write-Host -ForegroundColor DarkGray "OSImageIndex: $($Global:StartOSDCloud.OSImageIndex)"
            }
            else {
                $Global:StartOSDCloud.ImageFileItem = $null
                $Global:StartOSDCloud.OSImageIndex = 1
                #$Global:OSDImageParent = $null
                #$Global:OSDCloudWimFullName = $null
                Write-Warning "Custom Windows Image on USB was not found"
                Break
            }
        }
    }
    #=================================================
    #	ParameterSet Default
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'Default') {

        if ($Global:StartOSDCloud.OSVersion -eq 'Windows 11') {
            $OSVersion = 'Windows 11'
        }
        else {
            $OSVersion = 'Windows 10'
        }
        #=================================================
        #	OSBuild
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$OSVersion OSBuild " -NoNewline
        
        if ($Global:StartOSDCloud.OSBuild) {
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSBuild
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSBuild = '21H1'
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSBuild
        }
        else {
            Write-Host -ForegroundColor Cyan "Menu"
            $Global:StartOSDCloud.OSBuildNames = @('21H2','21H1','20H2','2004','1909','1903','1809')
            
            $i = $null
            $Global:StartOSDCloud.OSBuildMenu = foreach ($Item in $Global:StartOSDCloud.OSBuildNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSBuildMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows OSBuild"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSBuildMenu.Selection))))
            
            $Global:StartOSDCloud.OSBuild = $Global:StartOSDCloud.OSBuildMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
            Write-Host -ForegroundColor Cyan "OSBuild: " -NoNewline
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSBuild
        }
        #=================================================
        #	OSEdition
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$OSVersion OSEdition " -NoNewline

        if ($Global:StartOSDCloud.OSEdition) {
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSEdition
        }
        elseif ($ZTI) {
            $Global:StartOSDCloud.OSEdition = 'Enterprise'
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSEdition
        }
        else {
            Write-Host -ForegroundColor Cyan "Menu"
            $Global:StartOSDCloud.OSEditionNames = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

            $i = $null
            $Global:StartOSDCloud.OSEditionMenu = foreach ($Item in $Global:StartOSDCloud.OSEditionNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSEditionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows OSEdition"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSEditionMenu.Selection))))
            
            $Global:StartOSDCloud.OSEdition = $Global:StartOSDCloud.OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
            Write-Host -ForegroundColor Cyan "OSEdition: " -NoNewline
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSEdition
        }
        #=================================================
        #	OSEditionId and OSLicense
        #=================================================
        if ($Global:StartOSDCloud.OSEdition -eq 'Home') {
            $Global:StartOSDCloud.OSEditionId = 'Core'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 4
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home N') {
            $Global:StartOSDCloud.OSEditionId = 'CoreN'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 5
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home Single Language') {
            $Global:StartOSDCloud.OSEditionId = 'CoreSingleLanguage'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise') {
            $Global:StartOSDCloud.OSEditionId = 'Enterprise'
            $Global:StartOSDCloud.OSLicense = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise N') {
            $Global:StartOSDCloud.OSEditionId = 'EnterpriseN'
            $Global:StartOSDCloud.OSLicense = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 7
        }
        #=================================================
        #	OSLicense
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$OSVersion OSLicense " -NoNewline

        if ($Global:StartOSDCloud.OSLicense) {
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLicense
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSLicense = 'Volume'
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLicense
        }
        else {
            Write-Host -ForegroundColor Cyan "Menu"
            $Global:StartOSDCloud.OSLicenseNames = @('Retail Windows Consumer Editions','Volume Windows Business Editions')
            
            $i = $null
            $Global:StartOSDCloud.OSLicenseMenu = foreach ($Item in $Global:StartOSDCloud.OSLicenseNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection           = $i
                    Name                = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSLicenseMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows License"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSLicenseMenu.Selection))))
            
            $Global:StartOSDCloud.OSLicenseMenu = $Global:StartOSDCloud.OSLicenseMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

            if ($Global:StartOSDCloud.OSLicenseMenu -match 'Retail') {
                $Global:StartOSDCloud.OSLicense = 'Retail'
            }
            else {
                $Global:StartOSDCloud.OSLicense = 'Volume'
            }
            Write-Host -ForegroundColor Cyan "OSLicense: " -NoNewline
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLicense
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education') {
            $Global:StartOSDCloud.OSEditionId = 'Education'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 7}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 4}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education N') {
            $Global:StartOSDCloud.OSEditionId = 'EducationN'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 8}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 5}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro') {
            $Global:StartOSDCloud.OSEditionId = 'Professional'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 9}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 8}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro N') {
            $Global:StartOSDCloud.OSEditionId = 'ProfessionalN'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 10}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 9}
        }
        Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSEditionId
        Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSImageIndex
        #=================================================
        #	OSLanguage
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$OSVersion OSLanguage " -NoNewline
        
        if ($Global:StartOSDCloud.OSLanguage) {
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLanguage
        }
        elseif ($PSBoundParameters.ContainsKey('OSLanguage')) {
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLanguage
        }
        elseif ($ZTI) {
            $Global:StartOSDCloud.OSLanguage = 'en-us'
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLanguage
        }
        else {
            Write-Host -ForegroundColor Cyan "Menu"
            $Global:StartOSDCloud.OSLanguageNames = @('ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr','en-gb','en-us','es-es','es-mx','et-ee','fi-fi','fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it','ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl','pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk','sl-si','sr-latn-rs','sv-se','th-th','tr-tr','uk-ua','zh-cn','zh-tw')
            
            $i = $null
            $Global:StartOSDCloud.OSLanguageMenu = foreach ($Item in $Global:StartOSDCloud.OSLanguageNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSLanguageMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter a Selection for the Windows OSLanguage"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSLanguageMenu.Selection))))
            
            $Global:StartOSDCloud.OSLanguage = $Global:StartOSDCloud.OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
            Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
            Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLanguage
        }
        #=================================================
        #	Get-FeatureUpdate
        #   This is where we take the OSB OSE OSL information and get the
        #   Feature Update.  Global Variables will be set for Deploy-OSDCloud
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-FeatureUpdate"
        if ($Global:StartOSDCloud.OSVersion -eq 'Windows 11') {
            Write-Host -ForegroundColor DarkGray "Windows 11 x64 | OSLicense: $($Global:StartOSDCloud.OSLicense) | OSBuild: $($Global:StartOSDCloud.OSBuild) | OSLanguage: $($Global:StartOSDCloud.OSLanguage)"
            $Global:StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate -OSVersion 'Windows 11' -OSLicense $Global:StartOSDCloud.OSLicense -OSBuild $Global:StartOSDCloud.OSBuild -OSLanguage $Global:StartOSDCloud.OSLanguage
        }
        else {
            Write-Host -ForegroundColor DarkGray "Windows 10 x64 | OSLicense: $($Global:StartOSDCloud.OSLicense) | OSBuild: $($Global:StartOSDCloud.OSBuild) | OSLanguage: $($Global:StartOSDCloud.OSLanguage)"
            $Global:StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate -OSLicense $Global:StartOSDCloud.OSLicense -OSBuild $Global:StartOSDCloud.OSBuild -OSLanguage $Global:StartOSDCloud.OSLanguage
        }

        if ($Global:StartOSDCloud.GetFeatureUpdate) {
            $Global:StartOSDCloud.GetFeatureUpdate = $Global:StartOSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
            $Global:StartOSDCloud.ImageFileName = $Global:StartOSDCloud.GetFeatureUpdate.FileName
            $Global:StartOSDCloud.ImageFileUrl = $Global:StartOSDCloud.GetFeatureUpdate.FileUri
        }
        else {
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
        #=================================================
        #	Get-FeatureUpdate Offline
        #   Determine if the OS is Offline
        #   Need to bail if the file is Online is not valid or not Offline
        #=================================================
        $Global:StartOSDCloud.ImageFileItem = Find-OSDCloudFile -Name $Global:StartOSDCloud.GetFeatureUpdate.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $Global:StartOSDCloud.ImageFileItem = $Global:StartOSDCloud.ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

        if ($Global:StartOSDCloud.ImageFileItem) {
            Write-Host -ForegroundColor Green "OK"
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.ImageFileItem.FullName
        }
        elseif (Test-WebConnection -Uri $Global:StartOSDCloud.GetFeatureUpdate.FileUri) {
            Write-Host -ForegroundColor Yellow "Download"
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.FileUri
        }
        else {
            Write-Warning "Could not verify an Internet connection for Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #	Start-OSDCloud Get-MyDriverPack
    #=================================================
    if ($Global:StartOSDCloud.Product -ne 'None') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDriverPack"

        if ($OSVersion -eq 'Windows 11') {
            $Global:StartOSDCloud.GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:StartOSDCloud.Manufacturer -Product $Global:StartOSDCloud.Product -OsCode 'Win11'

            if (! ($Global:StartOSDCloud.GetMyDriverPack)) {
                $Global:StartOSDCloud.GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:StartOSDCloud.Manufacturer -Product $Global:StartOSDCloud.Product -OsCode 'Win10'
            }
        }
        else {
            $Global:StartOSDCloud.GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:StartOSDCloud.Manufacturer -Product $Global:StartOSDCloud.Product -OsCode 'Win10'
        }

        if ($Global:StartOSDCloud.GetMyDriverPack) {
            Write-Host -ForegroundColor DarkGray "Name: $($Global:StartOSDCloud.GetMyDriverPack.Name)"
            Write-Host -ForegroundColor DarkGray "Product: $($Global:StartOSDCloud.GetMyDriverPack.Product)"


            $Global:StartOSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $Global:StartOSDCloud.GetMyDriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
            $Global:StartOSDCloud.DriverPackOffline = $Global:StartOSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

            if ($Global:StartOSDCloud.DriverPackOffline) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.DriverPackOffline.FullName
            }
            elseif (Test-WebConnection -Uri $Global:StartOSDCloud.GetMyDriverPack.DriverPackUrl) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetMyDriverPack.DriverPackUrl
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Driver Pack"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
        }
    }
    #=================================================
    #   Invoke-OSDCloud.ps1
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
    #=================================================
}