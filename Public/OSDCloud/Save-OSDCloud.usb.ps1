<#
.SYNOPSIS
Saves OSDCloud to an NTFS Partition on a USB Drive

.DESCRIPTION
Saves OSDCloud to an NTFS Partition on a USB Drive

.PARAMETER OSEdition
Edition of the Windows installation

.PARAMETER OSCulture
Culture of the Windows installation

.LINK
https://osdcloud.osdeploy.com/

.NOTES
21.3.13 Initial Release
#>
function Save-OSDCloud.usb {
    [CmdletBinding()]
    param (
        [ValidateSet('Windows 10','Windows 11')]
        [string]$OSVersion = 'Windows 10',

        [ValidateSet('21H2','21H1','20H2','2004','1909','1903','1809')]
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

        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )

    #=================================================
    #	Start the Clock
    #=================================================
    $Global:OSDCloudStartTime = Get-Date
    #=================================================
    #	Global Variables
    #=================================================
    $Global:OSDCloudOSVersion = $OSVersion
    $Global:OSDCloudOSEdition = $OSEdition
    $Global:OSDCloudOSCulture = $OSCulture
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)" -NoNewline
    Write-Host -ForegroundColor Cyan " | Manufacturer: $Manufacturer | Product: $Product"
    Write-Host -ForegroundColor Cyan "OSDCloud content can be saved to an 8GB+ NTFS USB Volume"
    Write-Host -ForegroundColor White "Windows 10 will require about 4GB, and DriverPacks up to 2GB"
    #=================================================
    #   Get-Volume.usb
    #=================================================
    $GetUSBVolume = Get-Volume.usb | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if (-NOT ($GetUSBVolume)) {
        Write-Warning                           "Unfortunately, I don't see any USB Volumes that will work"
        Write-Warning                           "OSDCloud Failed!"
        Write-Host -ForegroundColor DarkGray    "================================================"
        Break
    }

    Write-Warning                               "USB Free Space is not verified before downloading yet, so this is on you!"
    Write-Host -ForegroundColor DarkGray        "================================================"
    if ($GetUSBVolume) {
        #$GetUSBVolume | Select-Object -Property DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB, DriveType | Format-Table
        $SelectUSBVolume = Select-Volume.usb -MinimumSizeGB 8 -FileSystem 'NTFS'
        $Global:OSDCloudOfflineFullName = "$($SelectUSBVolume.DriveLetter):\OSDCloud"
        Write-Host -ForegroundColor White       "OSDCloud content will be saved to $OSDCloudOfflineFullName"
    } else {
        Write-Warning                           "Save-OSDCloud.usb Requirements:"
        Write-Warning                           "8 GB Minimum"
        Write-Warning                           "NTFS File System"
        Break
    }
    #=================================================
    #	Autopilot Profiles
    #=================================================
    Write-Host -ForegroundColor DarkGray        "================================================"
    Write-Host -ForegroundColor Cyan            "Autopilot Profiles"

    if (-NOT (Test-Path "$OSDCloudOfflineFullName\Config\AutopilotJSON")) {
        New-Item -Path "$OSDCloudOfflineFullName\Config\AutopilotJSON" -ItemType Directory -Force | Out-Null
        Write-Host "Autopilot Profiles can be saved to $OSDCloudOfflineFullName\Config\AutopilotJSON"
    }
    $FindOSDCloudFile = @()
    [array]$FindOSDCloudFile = Find-OSDCloudFile -Name $Global:OSDCloudAutopilotJsonName -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
    [array]$FindOSDCloudFile += Find-OSDCloudFile -Name $Global:OSDCloudAutopilotJsonName -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
    $FindOSDCloudFile = $FindOSDCloudFile | Where-Object {$_.FullName -notlike "C*"}

    if ($FindOSDCloudFile) {
        foreach ($Item in $FindOSDCloudFile) {
            Write-Host -ForegroundColor White "$($Item.FullName)"
        }
    } else {
        Write-Warning "No Autopilot Profiles were found in any <PSDrive>:\OSDCloud\Config\AutopilotJSON"
        Write-Warning "Autopilot Profiles must be located in a $OSDCloudOfflineFullName\Config\AutopilotJSON direcory"
    }
    #=================================================
    #	OSBuild
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$OSVersion OSBuild " -NoNewline

    if ($OSVersion -eq 'Windows 11') {
        $OSBuild = '21H2'
    }
    
    if ($OSBuild) {
        Write-Host -ForegroundColor Green $OSBuild
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSBuildNames = @('21H2','21H1','20H2','2004','1909','1903','1809')
        
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
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the $OSVersion OSBuild"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSBuildMenu.Selection))))
        
        $OSBuild = $OSBuildMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSBuild: " -NoNewline
        Write-Host -ForegroundColor Green "$OSBuild"
    }
    #=================================================
    #	OSEdition
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$OSVersion OSEdition " -NoNewline

    if ($PSBoundParameters.ContainsKey('OSEdition')) {
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
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the $OSVersion OSEdition"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSEditionMenu.Selection))))
        
        $OSEdition = $OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSEdition: " -NoNewline
        Write-Host -ForegroundColor Green "$OSEdition"
    }
    #=================================================
    #	OSEditionId and OSLicense
    #=================================================
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
    #=================================================
    #	OSLicense
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$OSVersion OSLicense " -NoNewline

    if ($OSLicense) {
        Write-Host -ForegroundColor Green $OSLicense
    }
    else {
        Write-Host -ForegroundColor Cyan "Menu"
        $OSLicenseNames = @('Retail Windows Consumer Editions','Volume Windows Business Editions')
        
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
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the $OSVersion License"
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
    #=================================================
    #	OSLanguage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$OSVersion OSLanguage " -NoNewline
    
    if ($PSBoundParameters.ContainsKey('OSLanguage')) {
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
            $SelectReadHost = Read-Host -Prompt "Enter a Selection for the $OSVersion OSLanguage"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $OSLanguageMenu.Selection))))
        
        $OSLanguage = $OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
        Write-Host -ForegroundColor Green "$OSLanguage"
    }
    #=================================================
    #	Get-FeatureUpdate
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-FeatureUpdate"
    Write-Host -ForegroundColor DarkGray "$OSVersion x64 | OSLicense: $OSLicense | OSBuild: $OSBuild | OSLanguage: $OSLanguage"

    if ($OSVersion -eq 'Windows 11') {
        $GetFeatureUpdate = Get-FeatureUpdate -OSVersion 'Windows 11' -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage
    }
    else {
        $GetFeatureUpdate = Get-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage
    }

    if ($GetFeatureUpdate) {
        $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    }
    else {
        Write-Warning "Unable to locate a $OSVersion Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=================================================
    #	Offline OS
    #=================================================
    $OSDCloudOfflineOS = Find-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

    if ($OSDCloudOfflineOS) {
        $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
        Write-Host -ForegroundColor Cyan "Offline: $OSDCloudOfflineOSFullName"
    }
    elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
        $SaveFeatureUpdate = Save-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage -DownloadPath "$OSDCloudOfflineFullName\OS" | Out-Null
    }
    else {
        Write-Warning "Could not verify an Internet connection for the Windows Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=================================================
    #	Save-MyDriverPack
    #=================================================
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Cyan        "Save-MyDriverPack"

    Save-MyDriverPack -DownloadPath "$OSDCloudOfflineFullName\DriverPacks\$Manufacturer" -Manufacturer $Manufacturer -Product $Product
    #=================================================
    #	PSGallery Modules
    #=================================================
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Cyan        "PowerShell Modules and Scripts"

    #Offline
    Write-Host "PowerShell Offline Modules and Scripts are located at $OSDCloudOfflineFullName\PowerShell\Offline"
    Write-Host "This is for Modules and Scripts that OSDCloud needs to add to the Offline OS"
    Write-Host ""
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts" -ItemType Directory -Force | Out-Null
    }

    #Required
    Write-Host "PowerShell Required Modules and Scripts are located at $OSDCloudOfflineFullName\PowerShell\Required"
    Write-Host "This is for Modules and Scripts that you want to add to the Offline OS"
    Write-Host ""
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Required\Modules")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Required\Modules" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Required\Scripts")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Required\Scripts" -ItemType Directory -Force | Out-Null
    }

    if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
        Write-Host -ForegroundColor DarkGray "Save-Module OSD to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Save-Module -Name OSD -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Copy-PSModuleToFolder -Name OSD -Destination "$OSDCloudOfflineFullName\PowerShell\Offline\Modules"

        Write-Host -ForegroundColor DarkGray "Save-Module WindowsAutopilotIntune to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Save-Module -Name WindowsAutopilotIntune -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Write-Host -ForegroundColor DarkGray "Save-Module AzureAD to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Write-Host -ForegroundColor DarkGray "Save-Module Microsoft.Graph.Intune to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"

        Write-Host -ForegroundColor DarkGray "Save-Script Get-WindowsAutopilotInfo to $OSDCloudOfflineFullName\PowerShell\Offline\Scripts"
        Save-Script -Name Get-WindowsAutopilotInfo -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts"
    }
    else {
        Write-Warning "Could not validate an Internet connection to the PowerShell Gallery"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=================================================
    #	Save-OSDCloud.usb Complete
    #=================================================
    $Global:OSDCloudEndTime = Get-Date
    $Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    explorer $OSDCloudOfflineFullName
    #=================================================
}