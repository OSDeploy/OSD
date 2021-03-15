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
[Version]$OSDVersionMin = '21.3.15.1'

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
$BuildName      = 'OSDCloud'
$RequiresWinPE  = $true
#===================================================================================================
#   HEADER
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -Foregroundcolor Cyan        $Global:GitHubUrl
Write-Warning                           "THIS IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
#===================================================================================================
#   MENU EXAMPLE
#===================================================================================================
if (-NOT ($Global:OSDCloudOSEdition)) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host "ENT " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Enterprise"
    
    Write-Host "EDU " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Education"
    
    Write-Host "PRO " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Pro"
    
    Write-Host "X   " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Exit"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    
    do {
        $BuildImage = Read-Host -Prompt "Enter an option, or X to Exit"
    }
    until (
        (
            ($BuildImage -eq 'ENT') -or
            ($BuildImage -eq 'EDU') -or
            ($BuildImage -eq 'PRO') -or
            ($BuildImage -eq 'X')
        ) 
    )
    
    Write-Host ""
    
    if ($BuildImage -eq 'X') {
        Write-Host ""
        Write-Host "Adios!" -ForegroundColor Cyan
        Write-Host ""
        Break
    }
    if ($BuildImage -eq 'ENT') {$Global:OSDCloudOSEdition = 'Enerprise'}
    if ($BuildImage -eq 'EDU') {$Global:OSDCloudOSEdition = 'Education'}
    if ($BuildImage -eq 'PRO') {$Global:OSDCloudOSEdition = 'Pro'}
}
#===================================================================================================
#	AutoPilot Profiles
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "AutoPilot Profiles"

Break

$GetOSDCloudOfflineAutoPilotProfiles = Get-OSDCloudOfflineAutoPilotProfiles

if ($GetOSDCloudOfflineAutoPilotProfiles) {
    foreach ($Item in $GetOSDCloudOfflineAutoPilotProfiles) {
        Write-Host -ForegroundColor White "$($Item.FullName)"
    }
} else {
    Write-Warning "No AutoPilot Profiles were found in any PSDrive"
    Write-Warning "AutoPilot Profiles must be located in a <PSDrive>:\OSDCloud\AutoPilot\Profiles direcory"
}
#===================================================================================================
#   Scripts/Save-AutoPilotConfiguration.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Scripts/Save-AutoPilotConfiguration.ps1"
Write-Host ""
$AutoPilotConfiguration = Select-AutoPilotJson

if ($AutoPilotConfiguration) {
    Write-Host -ForegroundColor Cyan "AutoPilotConfigurationFile.json"
    $AutoPilotConfiguration
} else {
    Write-Host "AutoPilotConfigurationFile.json will not be configured for this deployment"
}
#===================================================================================================
#   Require WinPE
#   OSDCloud won't continue past this point unless you are in WinPE
#   The reason for the late failure is so you can test the Menu
#===================================================================================================
if ($RequiresWinPE) {
    if ((Get-OSDGather -Property IsWinPE) -eq $false) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
        Write-Warning "$BuildName can only be run from WinPE"
        Write-Warning "OSDCloud Failed!"
        Start-Sleep -Seconds 5
        Break
    }
}
#===================================================================================================
#   Set the Power Plan to High Performance
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Enabling High Performance Power Plan"
Write-Host -ForegroundColor Gray "Get-OSDPower -Property High"
Get-OSDPower -Property High
#===================================================================================================
#   Remove USB Drives
#===================================================================================================
$GetUSBDisk = Get-USBDisk
if (Get-USBDisk) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    do {
        Write-Warning "Remove all attached USB Drives until Initialize-OSDisk has completed"
        pause
    }
    while (Get-USBDisk)
}
#===================================================================================================
#   Initialize OSDisk
#   Don't allow USB Drives at this time so there is no worry about Drive Letters
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Initialize OSDisk"

Clear-LocalDisk -Force
New-OSDisk -Force
Start-Sleep -Seconds 3
if (-NOT (Get-PSDrive -Name 'C')) {
    Write-Warning "Disk does not seem to be ready.  Can't continue"
    Break
}
#===================================================================================================
#   Start Transcript
#===================================================================================================
if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
    New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud\Logs'
#===================================================================================================
#   Reattach USB Drives
#===================================================================================================
if ($GetUSBDisk) {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Cyan       "Reattach any necessary USB Drives at this time"
    pause
}
#===================================================================================================
#   Screenshots
#===================================================================================================
if ($Global:Screenshots) {
    Stop-ScreenPNGProcess
    robocopy "$env:TEMP\ScreenPNG" C:\OSDCloud\ScreenPNG *.* /e /ndl /nfl /njh /njs
    Start-ScreenPNGProcess -Directory "C:\OSDCloud\ScreenPNG"
}
#===================================================================================================
#	OSDCloud Get OS
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Get-FeatureUpdate Windows 10 $Global:OSDCloudOSEdition x64 $OSBuild $OSCulture"

$GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

if ($GetFeatureUpdate) {
    $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
}
else {
    Write-Warning "Unable to locate a Windows 10 Feature Update"
    Break
}
Write-Host -ForegroundColor White "CreationDate: $($GetFeatureUpdate.CreationDate)"
Write-Host -ForegroundColor White "KBNumber: $($GetFeatureUpdate.KBNumber)"
Write-Host -ForegroundColor White "Title: $($GetFeatureUpdate.Title)"
Write-Host -ForegroundColor White "FileName: $($GetFeatureUpdate.FileName)"
Write-Host -ForegroundColor White "SizeMB: $($GetFeatureUpdate.SizeMB)"
Write-Host -ForegroundColor White "FileUri: $($GetFeatureUpdate.FileUri)"

$OSDCloudOfflineOS = Get-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1
#===================================================================================================
#	Deploy-OSDCloud Save OS
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Save-FeatureUpdate C:\OSDCloud\OS"

if ($OSDCloudOfflineOS) {
    Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineOS.FullName)"
    $Global:OSDCloudOfflineOSPresent = $true
    $OSDCloudOSFullName = $OSDCloudOfflineOS.FullName
}
elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
    $SaveFeatureUpdate = Save-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture -DownloadPath "C:\OSDCloud\OS" | Out-Null

    if (Test-Path $SaveFeatureUpdate.FullName) {
        $OSDCloudOSFullName = $SaveFeatureUpdate.FullName
        Rename-Item -Path $SaveFeatureUpdate.FullName -NewName $GetFeatureUpdate.FileName -Force
    }
    if (Test-Path "C:\OSDCloud\OS\$($GetFeatureUpdate.FileName)") {
        $OSDCloudOSFullName = "C:\OSDCloud\OS\$($GetFeatureUpdate.FileName)"
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
#	Deploy-OSDCloud Expand OS
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Expand OS to C:\"

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}

if ($OSDCloudOSFullName) {
    if ($Global:OSDCloudOSEdition -eq 'Education') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOSFullName" -Index 4 -ScratchDirectory 'C:\OSDCloud\Temp'}
    elseif ($Global:OSDCloudOSEdition -eq 'Pro') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOSFullName" -Index 8 -ScratchDirectory 'C:\OSDCloud\Temp'}
    else {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OSDCloudOSFullName" -Index 6 -ScratchDirectory 'C:\OSDCloud\Temp'}
    
    $SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
    if (-NOT (Get-PSDrive -Name S)) {
        $SystemDrive | Set-Partition -NewDriveLetter 'S'
    }
    bcdboot C:\Windows /s S: /f ALL
    Start-Sleep -Seconds 10
    $SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
}
else {
    Write-Warning "Something went wrong trying to get Windows 10"
    Write-Warning "OSDCloud cannot continue"
    Break
}
#===================================================================================================
#	Deploy-OSDCloud Get-MyDellDriverCab
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Cyan "Get-MyDellDriverCab"
    
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
            $OSDCloudDriverPackFullName = $OSDCloudOfflineDriverPack.FullName
        }
        elseif (Test-MyDellDriverCabWebConnection) {
            $SaveMyDellDriverPack = Save-MyDellDriverCab -DownloadPath "C:\OSDCloud\DriverPacks" | Out-Null
            $OSDCloudDriverPackFullName = $SaveMyDellDriverPack.FullName
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
#===================================================================================================
#	Deploy-OSDCloud Expand MyDellDriverCab
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Cyan "Expand MyDellDriverCab"

    if ($OSDCloudDriverPackFullName) {
        $ExpandPath = Join-Path 'C:\Drivers' $GetMyDellDriverCab.DriverName
        if (-NOT (Test-Path "$ExpandPath")) {
            New-Item $ExpandPath -ItemType Directory -Force | Out-Null
        }
        Expand -R "$OSDCloudDriverPackFullName" -F:* "$ExpandPath" | Out-Null
    }
}
#===================================================================================================
#	Dell BIOS Update
#===================================================================================================
<# if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Cyan "Dell BIOS Update"

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

        $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1
        if ($GetOSDCloudOfflineFile) {
            Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
        }
        else {
            Save-MyDellBios -DownloadPath "$OSDCloudOffline\BIOS"
        }

        $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
        if ($GetOSDCloudOfflineFile) {
            Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
        }
        else {
            Save-MyDellBiosFlash64W -DownloadPath "$OSDCloudOffline\BIOS"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
    }
} #>
#===================================================================================================
#   Deploy-OSDCloud Apply Unattend.xml Drivers
#===================================================================================================
Write-Host -ForegroundColor DarkGray "========================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Apply Drivers with Use-WindowsUnattend"

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
Write-Verbose -Verbose "Setting Driver $UnattendPath"
$UnattendDrivers | Out-File -FilePath $UnattendPath -Encoding utf8

Write-Verbose -Verbose "Applying Use-WindowsUnattend $UnattendPath"
Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath
#===================================================================================================
#   Deploy-OSDCloud PowerShell Modules
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan        "Saving PowerShell Modules"


if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
    Save-Module -Name WindowsAutoPilotIntune -Path 'C:\Program Files\WindowsPowerShell\Modules'
    if (-NOT (Test-Path 'C:\Program Files\WindowsPowerShell\Scripts')) {
        New-Item -Path 'C:\Program Files\WindowsPowerShell\Scripts' -ItemType Directory -Force | Out-Null
    }
    Save-Script -Name Get-WindowsAutoPilotInfo -Path 'C:\Program Files\WindowsPowerShell\Scripts'
}
else {
    $OSDCloudOfflinePath = Get-OSDCloudOfflinePath

    foreach ($Item in $OSDCloudOfflinePath) {
        Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell"
        robocopy "$($Item.FullName)\PowerShell" 'C:\Program Files\WindowsPowerShell' *.* /e /ndl /njh /njs
    }
}
#===================================================================================================
#   Scripts/Save-AutoPilotConfiguration.ps1
#===================================================================================================
$PathAutoPilot = 'C:\Windows\Provisioning\AutoPilot'
if (-NOT (Test-Path $PathAutoPilot)) {
    New-Item -Path $PathAutoPilot -ItemType Directory -Force | Out-Null
}
$AutoPilotConfigurationFile = Join-Path $PathAutoPilot 'AutoPilotConfigurationFile.json'
if ($AutoPilotConfiguration) {
    Write-Verbose -Verbose "Setting $AutoPilotConfigurationFile"
    $AutoPilotConfiguration | ConvertTo-Json | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
}
#===================================================================================================
#	Deploy-OSDCloud Complete
#===================================================================================================
$Global:OSDCloudEndTime = Get-Date
$Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
Write-Host -ForegroundColor DarkGray    "========================================================================="
Write-Host -ForegroundColor Cyan        "Deploy-OSDCloud completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
Write-Host -ForegroundColor Cyan        "You can run additional steps or reboot at this time"
Write-Host -ForegroundColor DarkGray    "========================================================================="
#===================================================================================================
Break







































#===================================================================================================
#   Scripts/Get-WindowsESD.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkGray "================================================================="
Write-Host -ForegroundColor White "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Cyan "Scripts/Save-WindowsESD.ps1"

#Install-Module OSDSUS -Force
#Import-Module OSDSUS -Force

if (-NOT ($Global:OSDCloudOSCulture)) {
    $Global:OSDCloudOSCulture = 'en-us'
}

$WindowsESD = Get-OSDSUS -Catalog FeatureUpdate -UpdateArch x64 -UpdateBuild 2009 -UpdateOS "Windows 10" | Where-Object {$_.Title -match 'business'} | Where-Object {$_.Title -match $Global:OSDCloudOSCulture} | Sort-Object CreationDate -Descending | Select-Object -First 1



if (-NOT ($WindowsESD)) {
    Write-Warning "Could not find a Windows 10 $Global:OSDCloudOSCulture download"
    Break
} else {
    $WindowsESD = $WindowsESD | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName,Size,FileUri,OriginUri,Hash
}

$WindowsESD | Out-GridView

Pause

if (-NOT (Test-Path 'C:\OSDCloud\ESD')) {
    New-Item 'C:\OSDCloud\ESD' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud'





$Source = ($WindowsESD | Select-Object -ExpandProperty OriginUri).AbsoluteUri
$OutFile = Join-Path 'C:\OSDCloud\ESD' $WindowsESD.FileName

if (-NOT (Test-Path $OutFile)) {
    Write-Host "Downloading Windows 10 $Global:OSDCloudOSCulture using cURL" -Foregroundcolor Cyan
    Write-Host "Source: $Source" -Foregroundcolor Cyan
    Write-Host "Destination: $OutFile" -Foregroundcolor Cyan
    #cmd /c curl.exe -o "$Destination" $Source
    & curl.exe --location --output "$OutFile" --url $Source
    #& curl.exe --location --output "$OutFile" --progress-bar --url $Source
}

if (-NOT (Test-Path $OutFile)) {
    Write-Warning "Something went wrong in the download"
    Break
}










#===================================================================================================
#   Scripts/Update-BIOS.ps1
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkGray    "================================================================="
    Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Green       "Scripts/Update-BIOS.ps1"
    Update-MyDellBIOS
}
#===================================================================================================
#   Scripts/Save-WindowsESD.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Save-WindowsESD.ps1"
if (-NOT (Test-Path 'C:\OSDCloud\ESD')) {
    New-Item 'C:\OSDCloud\ESD' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud'

Install-Module OSDSUS -Force
Import-Module OSDSUS -Force

if (-NOT ($Global:OSDCloudOSCulture)) {
    $Global:OSDCloudOSCulture = 'en-us'
}


$WindowsESD = Get-OSDSUS -Catalog FeatureUpdate -UpdateArch x64 -UpdateBuild 2009 -UpdateOS "Windows 10" | Where-Object {$_.Title -match 'business'} | Where-Object {$_.Title -match $Global:OSDCloudOSCulture} | Select-Object -First 1

if (-NOT ($WindowsESD)) {
    Write-Warning "Could not find a Windows 10 $Global:OSDCloudOSCulture download"
    Break
}

$Source = ($WindowsESD | Select-Object -ExpandProperty OriginUri).AbsoluteUri
$OutFile = Join-Path 'C:\OSDCloud\ESD' $WindowsESD.FileName

if (-NOT (Test-Path $OutFile)) {
    Write-Host "Downloading Windows 10 $Global:OSDCloudOSCulture using cURL" -Foregroundcolor Cyan
    Write-Host "Source: $Source" -Foregroundcolor Cyan
    Write-Host "Destination: $OutFile" -Foregroundcolor Cyan
    #cmd /c curl.exe -o "$Destination" $Source
    & curl.exe --location --output "$OutFile" --url $Source
    #& curl.exe --location --output "$OutFile" --progress-bar --url $Source
}

if (-NOT (Test-Path $OutFile)) {
    Write-Warning "Something went wrong in the download"
    Break
}
#===================================================================================================
#   Scripts/Expand-WindowsESD.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Expand-WindowsESD.ps1"

if (-NOT ($Global:OSDCloudOSEdition)) {
    $Global:OSDCloudOSEdition = 'Enerprise'
}
Write-Host "OSEdition is set to $Global:OSDCloudOSEdition" -ForegroundColor Cyan

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}
if ($Global:OSDCloudOSEdition -eq 'Education') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 4 -ScratchDirectory 'C:\OSDCloud\Temp'}
elseif ($Global:OSDCloudOSEdition -eq 'Pro') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 8 -ScratchDirectory 'C:\OSDCloud\Temp'}
else {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 6 -ScratchDirectory 'C:\OSDCloud\Temp'}

$SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
if (-NOT (Get-PSDrive -Name S)) {
    $SystemDrive | Set-Partition -NewDriveLetter 'S'
}
bcdboot C:\Windows /s S: /f ALL
Start-Sleep -Seconds 10
$SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
