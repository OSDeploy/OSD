#=======================================================================
#   VERSIONING
#   Scripts/Test-OSDModule.ps1
#   OSD Module Minimum Version
#   Since the OSD Module is doing much of the heavy lifting, it is important to ensure that old
#   OSD Module versions are not used long term as the OSDCloud script can change
#   This example allows you to control the Minimum Version allowed.  A Maximum Version can also be
#   controlled in a similar method
#   In WinPE, the latest version will be installed automatically
#   In Windows, this script is stopped and you will need to update manually
#=======================================================================
[Version]$OSDVersionMin = '21.3.27.1'

if ((Get-Module -Name OSD -ListAvailable | `Sort-Object Version -Descending | Select-Object -First 1).Version -lt $OSDVersionMin) {
    Write-Warning "OSDCloud requires OSD $OSDVersionMin or newer"

    if ($env:SystemDrive -eq 'X:') {
        Write-Warning "Updating OSD PowerShell Module, you will need to restart OSDCloud"
        Install-Module OSD -Force
        Import-Module OSD -Force
        Break
    } else {
        Write-Warning "Run the following PowerShell command to update the OSD PowerShell Module"
        Write-Warning "Install-Module OSD -Force -Verbose"
        Break
    }
}
if ((Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version -lt $OSDVersionMin) {
    Write-Warning "OSDCloud requires OSD $OSDVersionMin or newer"
    Break
}
#=======================================================================
#   VARIABLES
#   These are set automatically by the OSD Module 21.3.11+ when executing Start-OSDCloud
#   $Global:GitHubBase = 'https://raw.githubusercontent.com'
#   $Global:GitHubUser = $User
#   $Global:GitHubRepository = $Repository
#   $Global:GitHubBranch = $Branch
#   $Global:GitHubScript = $Script
#   $Global:GitHubToken = $Token
#   $Global:GitHubUrl
#   $Global:OSDCloudOSEdition = $OSEdition
#   $Global:OSDCloudOSCulture = $OSCulture
#   As a backup, $Global:OSDCloudVariables is created with Get-Variable
#=======================================================================
$Global:OSDCloudVariables = Get-Variable
$BuildName = 'OSDCloud'

if (-NOT ($Global:OSDCloudManufacturer)) {
    $Global:OSDCloudManufacturer = (Get-MyComputerManufacturer -Brief)
}

if (-NOT ($Global:OSDCloudProduct)) {
    $Global:OSDCloudProduct = (Get-MyComputerProduct)
}
#=======================================================================
#   Start
#   Important to display the location so you know which script is executing
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Source)"
#=======================================================================
#	AutoPilot Profiles
#   This should have been selected by Start-OSDCloud
#=======================================================================
$GetOSDCloudautopilotprofiles = Get-OSDCloud.autopilotprofiles

if ($GetOSDCloudautopilotprofiles) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Select-OSDCloud.autopilotprofiles"

    $Global:OSDCloudAutoPilotProfile = Select-OSDCloud.autopilotprofiles
    if ($Global:OSDCloudAutoPilotProfile) {
        Write-Host -ForegroundColor Cyan "OSDCloud will apply the following AutoPilot Profile as AutoPilotConfigurationFile.json"
        $Global:OSDCloudAutoPilotProfile | Format-List
    } else {
        Write-Warning "AutoPilotConfigurationFile.json will not be configured for this deployment"
    }
}
#=======================================================================
#   Require WinPE
#   OSDCloud won't continue past this point unless you are in WinPE
#   The reason for the late failure is so you can test the Menu
#=======================================================================
if ((Get-OSDGather -Property IsWinPE) -eq $false) {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Warning "$BuildName can only be run from WinPE"
    Write-Warning "OSDCloud Failed!"
    Start-Sleep -Seconds 5
    Break
}
#=======================================================================
#   Remove USB Drives
#   Don't allow USB Drives at this time so there is no worry about Drive Letters
#=======================================================================
$GetUSBDisk = Get-Disk.usb
if (Get-Disk.usb) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    do {
        Write-Warning "Remove all attached USB Drives until OSDisk has been prepared"
        pause
    }
    while (Get-Disk.usb)
}
#=======================================================================
#   Clear-Disk.fixed
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Clear-Disk.fixed -Force"
Clear-Disk.fixed -Force -ErrorAction Stop
#=======================================================================
#   New-OSDisk
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "New-OSDisk -Force"
New-OSDisk -Force -ErrorAction Stop
Start-Sleep -Seconds 5
if (-NOT (Get-PSDrive -Name 'C')) {
    Write-Warning "Disk does not seem to be ready.  Can't continue"
    Break
}
#=======================================================================
#   Reattach USB Drives
#=======================================================================
if ($GetUSBDisk) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Reattach any necessary USB Drives at this time"
    pause
    #Give some time for the drive to be initialized
    Start-Sleep -Seconds 10
}
#=======================================================================
#   Set the Power Plan to High Performance
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Get-OSDPower -Property High"
Write-Host -ForegroundColor DarkGray "Enable High Performance Power Plan"
Get-OSDPower -Property High
#=======================================================================
#   Screenshot
#=======================================================================
if ($Global:OSDCloudScreenshot) {
    Stop-ScreenPNGProcess
    robocopy "$Global:OSDCloudScreenshot" C:\OSDCloud\ScreenPNG *.* /e /ndl /nfl /njh /njs
    Start-ScreenPNGProcess -Directory 'C:\OSDCloud\ScreenPNG'
    $Global:OSDCloudScreenshot = 'C:\OSDCloud\ScreenPNG'
}
#=======================================================================
#   Start Transcript
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Start-Transcript"

if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
    New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud\Logs' -ErrorAction Ignore
#=======================================================================
#	Get-FeatureUpdate
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Save-FeatureUpdate"

$GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

if (-NOT ($GetFeatureUpdate)) {
    Write-Warning "Unable to locate a Windows 10 Feature Update"
    Write-Warning "OSDCloud cannot continue"
    Break
}
$GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
Write-Host -ForegroundColor DarkGray "CreationDate: $($GetFeatureUpdate.CreationDate)"
Write-Host -ForegroundColor DarkGray "KBNumber: $($GetFeatureUpdate.KBNumber)"
Write-Host -ForegroundColor DarkGray "Title: $($GetFeatureUpdate.Title)"
Write-Host -ForegroundColor DarkGray "FileName: $($GetFeatureUpdate.FileName)"
Write-Host -ForegroundColor DarkGray "SizeMB: $($GetFeatureUpdate.SizeMB)"
Write-Host -ForegroundColor DarkGray "FileUri: $($GetFeatureUpdate.FileUri)"
#=======================================================================
#	Get OS
#=======================================================================
$OSDCloudOfflineOS = Get-OSDCloud.offline.file -Name $GetFeatureUpdate.FileName | Select-Object -First 1

if ($OSDCloudOfflineOS) {
    $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
    Write-Host -ForegroundColor DarkGray "$OSDCloudOfflineOSFullName"
}
elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
    $SaveFeatureUpdate = Save-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture -DownloadPath 'C:\OSDCloud\OS' -ErrorAction Stop
    $Global:SaveFeatureUpdate = $SaveFeatureUpdate
    if (Test-Path $($SaveFeatureUpdate.FullName)) {
        $OSDCloudOfflineOSFullName = $SaveFeatureUpdate.FullName
    }
    else {
        Write-Warning "Something went wrong trying to get the Windows Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
}
else {
    Write-Warning "Could not verify an Internet connection for the Windows Feature Update"
    Write-Warning "OSDCloud cannot continue"
    Break
}
#=======================================================================
#	Expand OS
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Expand-WindowsImage"

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}

if ($OSDCloudOfflineOSFullName) {
    if ($Global:OSDCloudOSEdition -eq 'Education') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 4 -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop}
    elseif ($Global:OSDCloudOSEdition -eq 'Pro') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 8 -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop}
    else {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 6 -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop}
    
    $SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
    if (-NOT (Get-PSDrive -Name S)) {
        $SystemDrive | Set-Partition -NewDriveLetter 'S'
    }
    bcdboot C:\Windows /s S: /f ALL
    Start-Sleep -Seconds 10
    $SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
}
else {
    Write-Warning "Something went wrong trying to expand the OS"
    Write-Warning "OSDCloud cannot continue"
    Break
}
#=======================================================================
#	Required Directories
#=======================================================================
if (-NOT (Test-Path 'C:\Drivers')) {
    New-Item -Path 'C:\Drivers'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}
if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}
if (-NOT (Test-Path 'C:\Windows\Provisioning\AutoPilot')) {
    New-Item -Path 'C:\Windows\Provisioning\AutoPilot'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}
if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
    New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
#=======================================================================
#	Get-MyDriverPack
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Save-MyDriverPack"

if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo')) {
    $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
}
else {
    $GetMyDriverPack = Get-MyDriverPack -Product $Global:OSDCloudProduct
}

if ($GetMyDriverPack) {
    Write-Host -ForegroundColor DarkGray "Name: $($GetMyDriverPack.Name)"
    Write-Host -ForegroundColor DarkGray "Product: $($GetMyDriverPack.Product)"
    Write-Host -ForegroundColor DarkGray "FileName: $($GetMyDriverPack.Product)"
    Write-Host -ForegroundColor DarkGray "DriverPackUrl: $($GetMyDriverPack.Product)"

    $GetOSDCloudOfflineFile = Get-OSDCloud.offline.file -Name $GetMyDriverPack.FileName | Select-Object -First 1
    if ($GetOSDCloudOfflineFile) {
        Write-Host -ForegroundColor DarkGray "$($GetOSDCloudOfflineFile.FullName)"
        Copy-Item -Path $GetOSDCloudOfflineFile.FullName -Destination 'C:\Drivers' -Force
        if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo')) {
            $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
        }
        else {
            $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Product $Global:OSDCloudProduct
        }
    }
    elseif (Test-WebConnection -Uri $GetMyDriverPack.DriverPackUrl) {
        Write-Host -ForegroundColor Yellow "$($GetMyDriverPack.DriverPackUrl)"
        if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo')) {
            $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
        }
        else {
            $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Product $Global:OSDCloudProduct
        }
    }
    else {
        Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
        Write-Warning "OSDCloud will continue, but there may be issues as Drivers will not be applied"
    }
}
else {
    Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
}
#=======================================================================
#	Dell BIOS Update
#=======================================================================
if ($Global:OSDCloudManufacturer -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Save-MyDellBios"

    $GetMyDellBios = Get-MyDellBios
    if ($GetMyDellBios) {
        Write-Host -ForegroundColor DarkGray "ReleaseDate: $($GetMyDellBios.ReleaseDate)"
        Write-Host -ForegroundColor DarkGray "Name: $($GetMyDellBios.Name)"
        Write-Host -ForegroundColor DarkGray "DellVersion: $($GetMyDellBios.DellVersion)"
        Write-Host -ForegroundColor DarkGray "Url: $($GetMyDellBios.Url)"
        Write-Host -ForegroundColor DarkGray "Criticality: $($GetMyDellBios.Criticality)"
        Write-Host -ForegroundColor DarkGray "FileName: $($GetMyDellBios.FileName)"
        Write-Host -ForegroundColor DarkGray "SizeMB: $($GetMyDellBios.SizeMB)"
        Write-Host -ForegroundColor DarkGray "PackageID: $($GetMyDellBios.PackageID)"
        Write-Host -ForegroundColor DarkGray "SupportedModel: $($GetMyDellBios.SupportedModel)"
        Write-Host -ForegroundColor DarkGray "SupportedSystemID: $($GetMyDellBios.SupportedSystemID)"
        Write-Host -ForegroundColor DarkGray "Flash64W: $($GetMyDellBios.Flash64W)"

        $OSDCloudOfflineBios = Get-OSDCloud.offline.file -Name $GetMyDellBios.FileName | Select-Object -First 1
        if ($OSDCloudOfflineBios) {
            Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineBios.FullName)"
        }
        else {
            Save-MyDellBios -DownloadPath 'C:\OSDCloud\BIOS'
        }

        $OSDCloudOfflineFlash64W = Get-OSDCloud.offline.file -Name 'Flash64W.exe' | Select-Object -First 1
        if ($OSDCloudOfflineFlash64W) {
            Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineFlash64W.FullName)"
        }
        else {
            Save-MyDellBiosFlash64W -DownloadPath 'C:\OSDCloud\BIOS'
        }
    }
    else {
        Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
    }
}
#=======================================================================
#   Update-MyDellBios
#   This step is not fully tested, so commenting out
#=======================================================================
<# if ($Global:OSDCloudManufacturer -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "================================================================="
    Write-Host -ForegroundColor Green       "Update-MyDellBios"
    Update-MyDellBIOS -DownloadPath 'C:\OSDCloud\BIOS'
} #>
#=======================================================================
#   Add-WindowsDriver.offlineservicing
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "Add-WindowsDriver.offlineservicing"
Write-Host -ForegroundColor DarkGray "Apply Drivers with Use-WindowsUnattend"
Add-WindowsDriver.offlineservicing
#=======================================================================
#   Add-StagedDriverPack.specialize
#=======================================================================
if ($Global:OSDCloudManufacturer -in ('HP','Lenovo')) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Add-StagedDriverPack.specialize"
    Write-Host -ForegroundColor DarkGray "Required for HP and Lenovo devices"
    Add-StagedDriverPack.specialize
}
#=======================================================================
#   Save-OSDCloud.offlineos.modules
#=======================================================================
Write-Host -ForegroundColor DarkGray "================================================================="
Write-Host -ForegroundColor Cyan "Save-OSDCloud.offlineos.modules"
Write-Host -ForegroundColor DarkGray "PowerShell Modules and Scripts"
Save-OSDCloud.offlineos.modules
#=======================================================================
#   AutoPilotConfigurationFile.json
#=======================================================================
if ($Global:OSDCloudAutoPilotProfile) {
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "AutoPilotConfigurationFile.json"

    $PathAutoPilot = 'C:\Windows\Provisioning\AutoPilot'

    $AutoPilotConfigurationFile = Join-Path $PathAutoPilot 'AutoPilotConfigurationFile.json'

    Write-Verbose -Verbose "Setting $AutoPilotConfigurationFile"
    $Global:OSDCloudAutoPilotProfile | ConvertTo-Json | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
}
#=======================================================================
#	Deploy-OSDCloud Complete
#=======================================================================
$Global:OSDCloudEndTime = Get-Date
$Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
Write-Host -ForegroundColor DarkGray    "========================================================================="
#=======================================================================
if ($Global:OSDCloudScreenshot) {
    Start-Sleep 5
    Stop-ScreenPNGProcess
    Write-Host -ForegroundColor Cyan    "Screenshots: $Global:OSDCloudScreenshot"
}
#=======================================================================