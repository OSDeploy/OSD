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
[Version]$OSDVersionMin = '21.4.9.4'

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
#   $Global:OSDCloudOSLanguage = $OSLanguage
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
#=======================================================================
if ($Global:OSDCloudSkipAutoPilot -eq $false) {
    $GetOSDCloudAutopilotFile = Find-OSDCloudAutopilotFile
    
    if ($GetOSDCloudAutopilotFile) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select-OSDCloudAutopilotFile"
    
        $Global:OSDCloudAutoPilotProfile = Select-OSDCloudAutopilotFile
        if ($Global:OSDCloudAutoPilotProfile) {
            Write-Host -ForegroundColor Cyan "OSDCloud will apply the following AutoPilot Profile as AutoPilotConfigurationFile.json"
            $Global:OSDCloudAutoPilotProfile | Format-List
        } else {
            Write-Warning "AutoPilotConfigurationFile.json will not be configured for this deployment"
        }
    }
}
#=======================================================================
#	Office Configuration 
#=======================================================================
if ($Global:OSDCloudSkipODT -eq $false) {
    $GetOSDCloudODT = Find-OSDCloudODTFile
    
    if ($GetOSDCloudODT) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select-OSDCloudODTFile"
    
        $Global:OSDCloudODTConfig = Select-OSDCloudODTFile
        if ($Global:OSDCloudODTConfig) {
            Write-Host -ForegroundColor Cyan "Office Config: $($Global:OSDCloudODTConfig.FullName)"
        } else {
            Write-Warning "OSDCloud Office Config will not be configured for this deployment"
        }
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
$GetDisk = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
if (($Global:OSDCloudZTI -eq $true) -and (($GetDisk | Measure-Object).Count -lt 2)) {
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults -Confirm:$false"
    Clear-Disk.fixed -Force -NoResults -Confirm:$false -ErrorAction Stop
}
else {
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults"
    Clear-Disk.fixed -Force -NoResults -ErrorAction Stop
}
#=======================================================================
#   New-OSDisk
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -Force"
if (Test-IsVM) {
    New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
    Write-Host "=========================================================================" -ForegroundColor Cyan
}
else {
    New-OSDisk -Force -ErrorAction Stop
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
    Write-Host "=========================================================================" -ForegroundColor Cyan
}
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
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Reattach any necessary USB Drives at this time"
    pause
    #Give some time for the drive to be initialized
    Start-Sleep -Seconds 10
}
#=======================================================================
#   Set the Power Plan to High Performance
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-OSDPower -Property High"
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
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"

if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
    New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud\Logs' -ErrorAction Ignore
#=======================================================================
#	Get-FeatureUpdate
#=======================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-FeatureUpdate"

$GetFeatureUpdate = Get-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage

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
$OSDCloudOfflineOS = Find-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

if ($OSDCloudOfflineOS) {
    $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
    Write-Host -ForegroundColor DarkGray "$OSDCloudOfflineOSFullName"
}
elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
    $SaveFeatureUpdate = Save-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage -DownloadPath 'C:\OSDCloud\OS' -ErrorAction Stop
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
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expand-WindowsImage"

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}

if ($OSDCloudOfflineOSFullName) {
    Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOfflineOSFullName" -Index $Global:OSDCloudOSImageIndex -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop
    
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
if ($Global:OSDCloudProduct -ne 'None') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDriverPack"
    
    if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Product $Global:OSDCloudProduct
    }
    
    if ($GetMyDriverPack) {
        Write-Host -ForegroundColor DarkGray "Name: $($GetMyDriverPack.Name)"
        Write-Host -ForegroundColor DarkGray "Product: $($GetMyDriverPack.Product)"
        Write-Host -ForegroundColor DarkGray "FileName: $($GetMyDriverPack.FileName)"
        Write-Host -ForegroundColor DarkGray "DriverPackUrl: $($GetMyDriverPack.DriverPackUrl)"
    
        $GetOSDCloudOfflineFile = Find-OSDCloudOfflineFile -Name $GetMyDriverPack.FileName | Select-Object -First 1
        if ($GetOSDCloudOfflineFile) {
            Write-Host -ForegroundColor DarkGray "$($GetOSDCloudOfflineFile.FullName)"
            Copy-Item -Path $GetOSDCloudOfflineFile.FullName -Destination 'C:\Drivers' -Force
            if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
            }
            else {
                $SaveMyDriverPack = Save-MyDriverPack -DownloadPath "C:\Drivers" -Expand -Product $Global:OSDCloudProduct
            }
        }
        elseif (Test-WebConnection -Uri $GetMyDriverPack.DriverPackUrl) {
            Write-Host -ForegroundColor Yellow "$($GetMyDriverPack.DriverPackUrl)"
            if ($Global:OSDCloudManufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
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
}
#=======================================================================
#	Dell BIOS Update
#=======================================================================
if ($Global:OSDCloudManufacturer -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDellBios"
    Write-Warning "This step is currently under development"

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

        $OSDCloudOfflineBios = Find-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1
        if ($OSDCloudOfflineBios) {
            Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineBios.FullName)"
        }
        else {
            Save-MyDellBios -DownloadPath 'C:\OSDCloud\BIOS'
        }

        $OSDCloudOfflineFlash64W = Find-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
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
Write-Host -ForegroundColor DarkGray "================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add-WindowsDriver.offlineservicing"
Write-Host -ForegroundColor DarkGray "Apply Drivers with Use-WindowsUnattend"
Add-WindowsDriver.offlineservicing
#=======================================================================
#   Set-OSDCloudUnattendSpecialize
#=======================================================================
Write-Host -ForegroundColor DarkGray "================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-OSDCloudUnattendSpecialize"
Write-Host -ForegroundColor DarkGray "Enables Start-OSDCloudSpecialize"
Set-OSDCloudUnattendSpecialize
#=======================================================================
#   AutoPilotConfigurationFile.json
#=======================================================================
if ($Global:OSDCloudAutoPilotProfile) {
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutoPilotConfigurationFile.json"

    $PathAutoPilot = 'C:\Windows\Provisioning\AutoPilot'

    $AutoPilotConfigurationFile = Join-Path $PathAutoPilot 'AutoPilotConfigurationFile.json'

    Write-Verbose -Verbose "Setting $AutoPilotConfigurationFile"
    $Global:OSDCloudAutoPilotProfile | ConvertTo-Json | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
}
#=======================================================================
#   Stage Office Config
#=======================================================================
if ($Global:OSDCloudODTConfig) {
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stage Office Config"

    if (!(Test-Path "C:\OSDCloud\ODT")) {
        New-Item -Path "C:\OSDCloud\ODT" -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $Global:OSDCloudODTConfig.FullName) {
        Copy-Item -Path $Global:OSDCloudODTConfig.FullName -Destination "C:\OSDCloud\ODT\Config.xml" -Force
    }

    $OfficeSetup = Join-Path $Global:OSDCloudODTConfig.Directory 'setup.exe'
    Write-Verbose -Verbose "OfficeSetup: $OfficeSetup"
    if (Test-Path $OfficeSetup) {
        Copy-Item -Path $OfficeSetup -Destination "C:\OSDCloud\ODT" -Force
    }


    $OfficeData = Join-Path $Global:OSDCloudODTConfig.Directory 'Office'
    Write-Verbose -Verbose "OfficeData: $OfficeData"
    if (Test-Path $OfficeData) {
        robocopy "$OfficeData" "C:\OSDCloud\ODT\Office" *.* /e /ndl /nfl /z /b
    }
}
#=======================================================================
#   Save-OSDCloudOfflineModules
#=======================================================================
Write-Host -ForegroundColor DarkGray "================================================================="
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-OSDCloudOfflineModules"
Write-Host -ForegroundColor DarkGray "PowerShell Modules and Scripts"
Save-OSDCloudOfflineModules
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
Write-Warning "WinPE is restarting in 30 seconds"
Write-Warning "Press CTRL + C to cancel"
Start-Sleep 30
wpeutil reboot
#=======================================================================