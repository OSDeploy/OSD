<#
.SYNOPSIS
Clear, Initialize, 2 Partition, and Format a USB Disk for use with OSDCloud

.Description
Clear, Initialize, 2 Partition, and Format a USB Disk for use with OSDCloud

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.18     Initial Release
#>
function New-OSDCloud.usb {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $osdcloudusbStartTime = Get-Date
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=======================================================================
    #	Set Variables
    #=======================================================================
    $ErrorActionPreference = 'Stop'
    $BootLabel = 'OSDBoot'
    $DataLabel = 'OSDCloud'
    #=======================================================================
    #	Set WorkspacePath
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop
    #=======================================================================
    #	Setup Workspace
    #=======================================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "New-OSDCloud.iso -WorkspacePath C:\OSDCloud"
        Write-Warning "New-OSDCloud.workspace -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
    #=======================================================================
    #	New-Bootable.usb
    #=======================================================================
    $NewOSDBootUSB = New-Bootable.usb -DataLabel 'OSDCloud'
    #=======================================================================
    #	Get-Partition.usb
    #=======================================================================
    $GetOSDBootPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $NewOSDBootUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($GetOSDBootPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    $GetUSBDataPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $NewOSDBootUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($GetUSBDataPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    #=======================================================================
    #	Copy OSDCloud
    #=======================================================================
    if ((Test-Path -Path "$WorkspacePath\Media") -and (Test-Path -Path "$($GetOSDBootPartition.DriveLetter):\")) {
        robocopy "$WorkspacePath\Media" "$($GetOSDBootPartition.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    if (Test-Path -Path "$WorkspacePath\Autopilot") {
        robocopy "$WorkspacePath\Autopilot" "$($GetUSBDataPartition.DriveLetter):\OSDCloud\Autopilot" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    if (Test-Path -Path "$WorkspacePath\ODT") {
        robocopy "$WorkspacePath\ODT" "$($GetUSBDataPartition.DriveLetter):\OSDCloud\ODT" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    #=======================================================================
    #	Complete
    #=======================================================================
    $osdcloudusbEndTime = Get-Date
    $osdcloudusbTimeSpan = New-TimeSpan -Start $osdcloudusbStartTime -End $osdcloudusbEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($osdcloudusbTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
}
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

        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )

    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $Global:OSDCloudStartTime = Get-Date
    #=======================================================================
    #	Global Variables
    #=======================================================================
    $Global:OSDCloudOSEdition = $OSEdition
    $Global:OSDCloudOSCulture = $OSCulture
    #=======================================================================
    #	Block
    #=======================================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Warning "OSDCLOUD IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)" -NoNewline
    Write-Host -ForegroundColor Cyan " | Manufacturer: $Manufacturer | Product: $Product"
    Write-Host -ForegroundColor Cyan "OSDCloud content can be saved to an 8GB+ NTFS USB Volume"
    Write-Host -ForegroundColor White "Windows 10 will require about 4GB, and DriverPacks up to 2GB"
    #=======================================================================
    #   Get-Volume.usb
    #=======================================================================
    $GetUSBVolume = Get-Volume.usb | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if (-NOT ($GetUSBVolume)) {
        Write-Warning                           "Unfortunately, I don't see any USB Volumes that will work"
        Write-Warning                           "OSDCloud Failed!"
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Break
    }

    Write-Warning                               "USB Free Space is not verified before downloading yet, so this is on you!"
    Write-Host -ForegroundColor DarkGray        "========================================================================="
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
    #=======================================================================
    #	Autopilot Profiles
    #=======================================================================
    Write-Host -ForegroundColor DarkGray        "========================================================================="
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
    #=======================================================================
    #	OSBuild
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 OSBuild " -NoNewline
    
    if ($OSBuild) {
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
    #	Offline OS
    #=======================================================================
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
    #=======================================================================
    #	Save-MyDriverPack
    #=======================================================================
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Cyan        "Save-MyDriverPack"

    Save-MyDriverPack -DownloadPath "$OSDCloudOfflineFullName\DriverPacks\$Manufacturer" -Manufacturer $Manufacturer -Product $Product
    #=======================================================================
    #	PSGallery Modules
    #=======================================================================
    Write-Host -ForegroundColor DarkGray    "========================================================================="
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
    #=======================================================================
    #	Save-OSDCloud.usb Complete
    #=======================================================================
    $Global:OSDCloudEndTime = Get-Date
    $Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    explorer $OSDCloudOfflineFullName
    #=======================================================================
}
function Update-OSDCloud.usb {
    [CmdletBinding()]
    param (
        [switch]$Mirror
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-PowerShellVersionLt5
    Block-StandardUser
    #=======================================================================
    #	USBBOOT
    #=======================================================================
    $OSDCloudWorkspace = Get-OSDCloud.workspace

    if ($OSDCloudWorkspace){
        #=======================================================================
        #	USBBOOT
        #=======================================================================
        $USBBOOT = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'USBBOOT'}
    
        if ($USBBOOT) {
            Write-Verbose -Verbose "Setting NewFileSystemLabel to OSDBoot"
            Set-Volume -DriveLetter $USBBOOT.DriveLetter -NewFileSystemLabel 'OSDBoot' -ErrorAction Ignore
        }
        #=======================================================================
        #	OSDBoot
        #=======================================================================
        $OSDBoot = (Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDBoot'}).DriveLetter
    
        if ($OSDBoot) {
            Write-Verbose -Verbose "Updating Volume OSDBoot with content from $OSDCloudWorkspace\Media"
            
            if ($PSBoundParameters.ContainsKey('Mirror')) {
                Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\Media to $($OSDBoot):\"
                robocopy "$OSDCloudWorkspace\Media" "$($OSDBoot):\" *.* /mir /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
            else {
                Write-Verbose -Verbose "Copying $OSDCloudWorkspace\Media to $($OSDBoot):\"
                robocopy "$OSDCloudWorkspace\Media" "$($OSDBoot):\" *.* /e /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
        #=======================================================================
        #	OSDCloud
        #=======================================================================
        $OSDCloud = (Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}).DriveLetter
    
        if ($OSDCloud) {
            if ($PSBoundParameters.ContainsKey('Mirror')) {
                if (Test-Path "$OSDCloudWorkspace\Autopilot") {
                    Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\Autopilot to $($OSDCloud):\OSDCloud\Autopilot"
                    robocopy "$OSDCloudWorkspace\Autopilot" "$($OSDCloud):\OSDCloud\Autopilot" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                    Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\DriverPacks to $($OSDCloud):\OSDCloud\DriverPacks"
                    robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloud):\OSDCloud\DriverPacks" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\ODT") {
                    Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\ODT to $($OSDCloud):\OSDCloud\ODT"
                    robocopy "$OSDCloudWorkspace\ODT" "$($OSDCloud):\OSDCloud\ODT" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\OS") {
                    Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\OS to $($OSDCloud):\OSDCloud\OS"
                    robocopy "$OSDCloudWorkspace\OS" "$($OSDCloud):\OSDCloud\OS" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                    Write-Verbose -Verbose "Mirroring $OSDCloudWorkspace\PowerShell to $($OSDCloud):\OSDCloud\PowerShell"
                    robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloud):\OSDCloud\PowerShell" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
            else {
                if (Test-Path "$OSDCloudWorkspace\Autopilot") {
                    if (Test-Path "$OSDCloudWorkspace\Autopilot") {
                        Write-Verbose -Verbose "Copying $OSDCloudWorkspace\Autopilot to $($OSDCloud):\OSDCloud\Autopilot"
                        robocopy "$OSDCloudWorkspace\Autopilot" "$($OSDCloud):\OSDCloud\Autopilot" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                    
                    if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                        Write-Verbose -Verbose "Copying $OSDCloudWorkspace\DriverPacks to $($OSDCloud):\OSDCloud\DriverPacks"
                        robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloud):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                    
                    if (Test-Path "$OSDCloudWorkspace\ODT") {
                        Write-Verbose -Verbose "Copying $OSDCloudWorkspace\ODT to $($OSDCloud):\OSDCloud\ODT"
                        robocopy "$OSDCloudWorkspace\ODT" "$($OSDCloud):\OSDCloud\ODT" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                    
                    if (Test-Path "$OSDCloudWorkspace\OS") {
                        Write-Verbose -Verbose "Copying $OSDCloudWorkspace\OS to $($OSDCloud):\OSDCloud\OS"
                        robocopy "$OSDCloudWorkspace\OS" "$($OSDCloud):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                    
                    if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                        Write-Verbose -Verbose "Copying $OSDCloudWorkspace\PowerShell to $($OSDCloud):\OSDCloud\PowerShell"
                        robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloud):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
            }
        }
        #=======================================================================
    }
    else {
        Write-Warning "Could not find the path to OSDCloud.workspace"
    }
    #=======================================================================
}