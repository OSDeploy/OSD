#===================================================================================================
#   VERSIONING
#   Scripts/Test-OSDModule.ps1
#   OSD Module Minimum Version
#   Since the OSD Module is doing much of the heavy lifting, it is important to ensure that old
#   OSD Module versions are not used long term as the OSDCloud script can change
#   This example allows you to control the Minimum Version allowed.  A Maximum Version can also be
#   controlled in a similar method
#   In WinPE, the latest version will be installed automatically
#   In Windows, this script is stopped and you will need to update manually
#===================================================================================================
[Version]$OSDVersionMin = '21.3.17.1'

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
#===================================================================================================
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
#===================================================================================================
$Global:OSDCloudVariables = Get-Variable
$BuildName = 'OSDCloud'
#===================================================================================================
#   HEADER
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Warning                           "THIS IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
#===================================================================================================
#	AutoPilot Profiles
#   This should have been selected by Start-OSDCloud
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "AutoPilot Profiles"

if ($Global:OSDCloudAutoPilotProfile) {
    Write-Host -ForegroundColor Cyan "OSDCloud will apply the following AutoPilot Profile as AutoPilotConfigurationFile.json"
    $Global:OSDCloudAutoPilotProfile | Format-List
} else {
    Write-Warning "AutoPilotConfigurationFile.json will not be configured for this deployment"
}
#===================================================================================================
#   Require WinPE
#   OSDCloud won't continue past this point unless you are in WinPE
#   The reason for the late failure is so you can test the Menu
#===================================================================================================
if ((Get-OSDGather -Property IsWinPE) -eq $false) {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Warning "$BuildName can only be run from WinPE"
    Write-Warning "OSDCloud Failed!"
    Start-Sleep -Seconds 5
    Break
}
#===================================================================================================
#   Set the Power Plan to High Performance
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Enabling High Performance Power Plan"
Write-Host -ForegroundColor Gray        "Get-OSDPower -Property High"
Get-OSDPower -Property High
#===================================================================================================
#   Remove USB Drives
#===================================================================================================
$GetUSBDisk = Get-USBDisk
if (Get-USBDisk) {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    do {
        Write-Warning "Remove all attached USB Drives until OSDisk has been prepared"
        pause
    }
    while (Get-USBDisk)
}
#===================================================================================================
#   Prepare OSDisk
#   Don't allow USB Drives at this time so there is no worry about Drive Letters
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Prepare OSDisk"

Clear-LocalDisk -Force
New-OSDisk -Force
Start-Sleep -Seconds 3
if (-NOT (Get-PSDrive -Name 'C')) {
    Write-Warning "Disk does not seem to be ready.  Can't continue"
    Break
}
#===================================================================================================
#   Screenshot
#===================================================================================================
if ($Global:OSDCloudScreenshot) {
    Stop-ScreenPNGProcess
    
    robocopy "$Global:OSDCloudScreenshot" C:\OSDCloud\ScreenPNG *.* /e /ndl /nfl /njh /njs
    
    Start-ScreenPNGProcess -Directory 'C:\OSDCloud\ScreenPNG'
    $Global:OSDCloudScreenshot = 'C:\OSDCloud\ScreenPNG'
}
#===================================================================================================
#   Start Transcript
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Start-Transcript"

if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
    New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud\Logs'
#===================================================================================================
#   Reattach USB Drives
#===================================================================================================
if ($GetUSBDisk) {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Reattach any necessary USB Drives at this time"
    pause
    #Give some time for the drive to be initialized
    Start-Sleep -Seconds 10
}
#===================================================================================================
#	Get-FeatureUpdate
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Get-FeatureUpdate Windows 10 $Global:OSDCloudOSEdition x64 $OSBuild $OSCulture"

$GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

if (-NOT ($GetFeatureUpdate)) {
    Write-Warning "Unable to locate a Windows 10 Feature Update"
    Write-Warning "OSDCloud cannot continue"
    Break
}
$GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
Write-Host -ForegroundColor White "CreationDate: $($GetFeatureUpdate.CreationDate)"
Write-Host -ForegroundColor White "KBNumber: $($GetFeatureUpdate.KBNumber)"
Write-Host -ForegroundColor White "Title: $($GetFeatureUpdate.Title)"
Write-Host -ForegroundColor White "FileName: $($GetFeatureUpdate.FileName)"
Write-Host -ForegroundColor White "SizeMB: $($GetFeatureUpdate.SizeMB)"
Write-Host -ForegroundColor White "FileUri: $($GetFeatureUpdate.FileUri)"
#===================================================================================================
#	Get OS
#===================================================================================================
$OSDCloudOfflineOS = Get-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

if ($OSDCloudOfflineOS) {
    $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
    Write-Host -ForegroundColor Cyan "Offline: $OSDCloudOfflineOSFullName"
}
elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
    $SaveFeatureUpdate = Save-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture -DownloadPath 'C:\OSDCloud\OS'
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
#===================================================================================================
#	Expand OS
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Expand OS to C:\"

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}

if ($OSDCloudOfflineOSFullName) {
    if ($Global:OSDCloudOSEdition -eq 'Education') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 4 -ScratchDirectory 'C:\OSDCloud\Temp'}
    elseif ($Global:OSDCloudOSEdition -eq 'Pro') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 8 -ScratchDirectory 'C:\OSDCloud\Temp'}
    else {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index 6 -ScratchDirectory 'C:\OSDCloud\Temp'}
    
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
#===================================================================================================
#	Get Dell Driver Pack
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Get-MyDellDriverCab"
    
    $GetMyDellDriverCab = Get-MyDellDriverCab

    if ($GetMyDellDriverCab) {
        Write-Host -ForegroundColor White "LastUpdate: $($GetMyDellDriverCab.LastUpdate)"
        Write-Host -ForegroundColor White "DriverName: $($GetMyDellDriverCab.DriverName)"
        Write-Host -ForegroundColor White "Generation: $($GetMyDellDriverCab.Generation)"
        Write-Host -ForegroundColor White "Model: $($GetMyDellDriverCab.Model)"
        Write-Host -ForegroundColor White "SystemSku: $($GetMyDellDriverCab.SystemSku)"
        Write-Host -ForegroundColor White "DriverVersion: $($GetMyDellDriverCab.DriverVersion)"
        Write-Host -ForegroundColor White "DriverReleaseId: $($GetMyDellDriverCab.DriverReleaseId)"
        Write-Host -ForegroundColor White "OsVersion: $($GetMyDellDriverCab.OsVersion)"
        Write-Host -ForegroundColor White "OsArch: $($GetMyDellDriverCab.OsArch)"
        Write-Host -ForegroundColor White "DownloadFile: $($GetMyDellDriverCab.DownloadFile)"
        Write-Host -ForegroundColor White "SizeMB: $($GetMyDellDriverCab.SizeMB)"
        Write-Host -ForegroundColor White "DriverUrl: $($GetMyDellDriverCab.DriverUrl)"
        Write-Host -ForegroundColor White "DriverInfo: $($GetMyDellDriverCab.DriverInfo)"

        $OSDCloudOfflineDriverPack = Get-OSDCloudOfflineFile -Name $GetMyDellDriverCab.DownloadFile | Select-Object -First 1
    
        if ($OSDCloudOfflineDriverPack) {
            Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineDriverPack.FullName)"
            $Global:OSDCloudOfflineDriverPackPresent = $true
            $OSDCloudOfflineDriverPackFullName = $OSDCloudOfflineDriverPack.FullName
        }
        elseif (Test-MyDellDriverCabWebConnection) {
            $SaveMyDellDriverCab = Save-MyDellDriverCab -DownloadPath "C:\OSDCloud\DriverPacks" | Out-Null
            $OSDCloudOfflineDriverPackFullName = $SaveMyDellDriverCab.FullName
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
            Write-Warning "OSDCloud will continue, but there may be issues as Drivers will not be applied"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
    }
}
#===================================================================================================
#	Deploy-OSDCloud Expand MyDellDriverCab
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Expand MyDellDriverCab"

    if ($OSDCloudOfflineDriverPackFullName) {
        $ExpandPath = Join-Path 'C:\Drivers' $GetMyDellDriverCab.DriverName
        if (-NOT (Test-Path "$ExpandPath")) {
            New-Item $ExpandPath -ItemType Directory -Force | Out-Null
        }
        Expand -R "$OSDCloudOfflineDriverPackFullName" -F:* "$ExpandPath" | Out-Null
    }
}
#===================================================================================================
#	Dell BIOS Update
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Get-MyDellBios"

    $GetMyDellBios = Get-MyDellBios
    if ($GetMyDellBios) {
        Write-Host -ForegroundColor White "ReleaseDate: $($GetMyDellBios.ReleaseDate)"
        Write-Host -ForegroundColor White "Name: $($GetMyDellBios.Name)"
        Write-Host -ForegroundColor White "DellVersion: $($GetMyDellBios.DellVersion)"
        Write-Host -ForegroundColor White "Url: $($GetMyDellBios.Url)"
        Write-Host -ForegroundColor White "Criticality: $($GetMyDellBios.Criticality)"
        Write-Host -ForegroundColor White "FileName: $($GetMyDellBios.FileName)"
        Write-Host -ForegroundColor White "SizeMB: $($GetMyDellBios.SizeMB)"
        Write-Host -ForegroundColor White "PackageID: $($GetMyDellBios.PackageID)"
        Write-Host -ForegroundColor White "SupportedModel: $($GetMyDellBios.SupportedModel)"
        Write-Host -ForegroundColor White "SupportedSystemID: $($GetMyDellBios.SupportedSystemID)"
        Write-Host -ForegroundColor White "Flash64W: $($GetMyDellBios.Flash64W)"

        $OSDCloudOfflineBios = Get-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1
        if ($OSDCloudOfflineBios) {
            Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineBios.FullName)"
        }
        else {
            Save-MyDellBios -DownloadPath 'C:\OSDCloud\BIOS'
        }

        $OSDCloudOfflineFlash64W = Get-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
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
#===================================================================================================
#   Update-MyDellBios
#   This step is not fully tested, so commenting out
#===================================================================================================
<# if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Green       "Update-MyDellBios"
    Update-MyDellBIOS
} #>
#===================================================================================================
#   Apply Drivers with Use-WindowsUnattend
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Apply Drivers with Use-WindowsUnattend"

$PathPanther = 'C:\Windows\Panther'
if (-NOT (Test-Path $PathPanther)) {
    New-Item -Path $PathPanther -ItemType Directory -Force | Out-Null
}

$UnattendDrivers = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                    <Path>C:\Drivers</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
    </settings>
</unattend>
'@

$UnattendPath = Join-Path $PathPanther 'Unattend.xml'
Write-Host -ForegroundColor Cyan "Setting Driver $UnattendPath"
$UnattendDrivers | Out-File -FilePath $UnattendPath -Encoding utf8

Write-Host -ForegroundColor Cyan "Applying Use-WindowsUnattend $UnattendPath ... this may take a while!"
Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath
#===================================================================================================
#   PSGallery Modules
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "PowerShell Modules and Scripts"

$PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'


if (-NOT (Test-Path "$PowerShellSavePath\Configuration")) {
    New-Item -Path "$PowerShellSavePath\Configuration" -ItemType Directory -Force | Out-Null
}
if (-NOT (Test-Path "$PowerShellSavePath\Modules")) {
    New-Item -Path "$PowerShellSavePath\Modules" -ItemType Directory -Force | Out-Null
}
if (-NOT (Test-Path "$PowerShellSavePath\Scripts")) {
    New-Item -Path "$PowerShellSavePath\Scripts" -ItemType Directory -Force | Out-Null
}

if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
    Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force
    Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force
    Save-Module -Name WindowsAutoPilotIntune -Path "$PowerShellSavePath\Modules" -Force
    Save-Script -Name Get-WindowsAutoPilotInfo -Path "$PowerShellSavePath\Scripts" -Force
}
else {
    $OSDCloudOfflinePath = Get-OSDCloudOfflinePath

    foreach ($Item in $OSDCloudOfflinePath) {
        Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
        robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /e /ndl /njh /njs
    }
}
#===================================================================================================
#   AutoPilotConfigurationFile.json
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "AutoPilotConfigurationFile.json"

$PathAutoPilot = 'C:\Windows\Provisioning\AutoPilot'
if (-NOT (Test-Path $PathAutoPilot)) {
    New-Item -Path $PathAutoPilot -ItemType Directory -Force | Out-Null
}

$AutoPilotConfigurationFile = Join-Path $PathAutoPilot 'AutoPilotConfigurationFile.json'

if ($Global:OSDCloudAutoPilotProfile) {
    Write-Verbose -Verbose "Setting $AutoPilotConfigurationFile"
    $Global:OSDCloudAutoPilotProfile | ConvertTo-Json | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
} else {
    Write-Warning "AutoPilotConfigurationFile.json will not be configured for this deployment"
}
#===================================================================================================
#	Deploy-OSDCloud Complete
#===================================================================================================
$Global:OSDCloudEndTime = Get-Date
$Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
Write-Host -ForegroundColor DarkGray    "========================================================================="
#===================================================================================================
if ($Global:OSDCloudScreenshot) {
    Start-Sleep 5
    Stop-ScreenPNGProcess
    Write-Host -ForegroundColor Cyan    "Screenshots: $Global:OSDCloudScreenshot"
}
#===================================================================================================