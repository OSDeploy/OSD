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
[Version]$OSDVersionMin = '21.3.11.6'

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
#   As a backup, $Global:OSDCloudVariables is created with Get-Variable
#===================================================================================================
$Global:OSDCloudVariables = Get-Variable
#===================================================================================================
#   Build Variables
#   Set these Variables to control the Build Process
#===================================================================================================
$BuildName      = 'OSDCloud'
$RequiresWinPE  = $true
#===================================================================================================
#   HEADER
#   Start-OSDCloud
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Start OSDCloud"
Write-Host -Foregroundcolor Cyan        $Global:GitHubUrl
Write-Warning "THIS IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
#===================================================================================================
#   MENU EXAMPLE
#===================================================================================================
if (-NOT ($Global:OSEdition)) {
    Write-Host -ForegroundColor DarkCyan "================================================================="
    Write-Host "ENT " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Enterprise"
    
    Write-Host "EDU " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Education"
    
    Write-Host "PRO " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Windows 10 x64 20H1 Pro"
    
    Write-Host "X   " -ForegroundColor Green -BackgroundColor Black -NoNewline
    Write-Host "    Exit"
    Write-Host -ForegroundColor DarkCyan "================================================================="
    
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
    if ($BuildImage -eq 'ENT') {$Global:OSEdition = 'Enerprise'}
    if ($BuildImage -eq 'EDU') {$Global:OSEdition = 'Education'}
    if ($BuildImage -eq 'PRO') {$Global:OSEdition = 'Pro'}
}
#===================================================================================================
#   Scripts/Save-AutoPilotConfiguration.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Save-AutoPilotConfiguration.ps1"
Write-Host ""
$AutoPilotConfiguration = Select-AutoPilotJson

if ($AutoPilotConfiguration) {
    Write-Host -ForegroundColor Cyan "AutoPilotConfigurationFile.json"
    $AutoPilotConfiguration
} else {
    Write-Host "AutoPilotConfigurationFile.json will not be configured for this deployment"
}
#===================================================================================================
#   Require cURL
#   Without cURL, we can't download the ESD, so if it's not present, then we need to exit
#===================================================================================================
if (-NOT (Test-CommandCurlExe)) {
    Write-Host -ForegroundColor DarkCyan    "================================================================="
    Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Warning "cURL is required for this process to work"
    Write-Warning "Abort!"
    Start-Sleep -Seconds 5
    Break
}
#===================================================================================================
#   Scripts/Get-WindowsESD.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Save-WindowsESD.ps1"

#Install-Module OSDSUS -Force
#Import-Module OSDSUS -Force

if (-NOT ($Global:OSCulture)) {
    $Global:OSCulture = 'en-us'
}

$WindowsESD = Get-OSDSUS -Catalog FeatureUpdate -UpdateArch x64 -UpdateBuild 2009 -UpdateOS "Windows 10" | Where-Object {$_.Title -match 'business'} | Where-Object {$_.Title -match $Global:OSCulture} | Sort-Object CreationDate -Descending | Select-Object -First 1



if (-NOT ($WindowsESD)) {
    Write-Warning "Could not find a Windows 10 $Global:OSCulture download"
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
    Write-Host "Downloading Windows 10 $Global:OSCulture using cURL" -Foregroundcolor Cyan
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
#   Require WinPE
#   OSDCloud won't continue past this point unless you are in WinPE
#   The reason for the late failure is so you can test the Menu
#===================================================================================================
if ($RequiresWinPE) {
    if ((Get-OSDGather -Property IsWinPE) -eq $false) {
        Write-Host -ForegroundColor DarkCyan    "================================================================="
        Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
        Write-Warning "$BuildName can only be run from WinPE"
        Write-Warning "Abort!"
        Start-Sleep -Seconds 5
        Break
    }
}







#===================================================================================================
#   Scripts/Update-BIOS.ps1
#===================================================================================================
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Write-Host -ForegroundColor DarkCyan    "================================================================="
    Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    Write-Host -ForegroundColor Green       "Scripts/Update-BIOS.ps1"
    Update-MyDellBIOS
}
#===================================================================================================
#   Set the Power Plan to High Performance
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Enabling High Performance Power Plan"
Write-Host -ForegroundColor Gray        "Get-OSDPower -Property High"
Get-OSDPower -Property High
#===================================================================================================
#   Scripts/Initialize-OSDisk.ps1
#   Don't allow USB Drives at this time so there is no worry about Drive Letters
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Initialize-OSDisk.ps1"

$RemoveUSBDrive = $true
if ($RemoveUSBDrive) {
    if (Get-USBDisk) {
        do {
            Write-Warning "Remove all attached USB Drives until Initialize-OSDisk has completed"
            $RemoveUSB = $true
            pause
        }
        while (Get-USBDisk)
    }
}

Clear-LocalDisk -Force
New-OSDisk -Force
Start-Sleep -Seconds 3
if (-NOT (Get-PSDrive -Name 'C')) {
    Write-Warning "Disk does not seem to be ready.  Can't continue"
    Break
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
#   Scripts/Save-WindowsESD.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Save-WindowsESD.ps1"
if (-NOT (Test-Path 'C:\OSDCloud\ESD')) {
    New-Item 'C:\OSDCloud\ESD' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
Start-Transcript -Path 'C:\OSDCloud'

Install-Module OSDSUS -Force
Import-Module OSDSUS -Force

if (-NOT ($Global:OSCulture)) {
    $Global:OSCulture = 'en-us'
}


$WindowsESD = Get-OSDSUS -Catalog FeatureUpdate -UpdateArch x64 -UpdateBuild 2009 -UpdateOS "Windows 10" | Where-Object {$_.Title -match 'business'} | Where-Object {$_.Title -match $Global:OSCulture} | Select-Object -First 1

if (-NOT ($WindowsESD)) {
    Write-Warning "Could not find a Windows 10 $Global:OSCulture download"
    Break
}

$Source = ($WindowsESD | Select-Object -ExpandProperty OriginUri).AbsoluteUri
$OutFile = Join-Path 'C:\OSDCloud\ESD' $WindowsESD.FileName

if (-NOT (Test-Path $OutFile)) {
    Write-Host "Downloading Windows 10 $Global:OSCulture using cURL" -Foregroundcolor Cyan
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
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Expand-WindowsESD.ps1"

if (-NOT ($Global:OSEdition)) {
    $Global:OSEdition = 'Enerprise'
}
Write-Host "OSEdition is set to $Global:OSEdition" -ForegroundColor Cyan

if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
    New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
}
if ($Global:OSEdition -eq 'Education') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 4 -ScratchDirectory 'C:\OSDCloud\Temp'}
elseif ($Global:OSEdition -eq 'Pro') {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 8 -ScratchDirectory 'C:\OSDCloud\Temp'}
else {Expand-WindowsImage -ApplyPath 'C:\' -ImagePath "$OutFile" -Index 6 -ScratchDirectory 'C:\OSDCloud\Temp'}

$SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
if (-NOT (Get-PSDrive -Name S)) {
    $SystemDrive | Set-Partition -NewDriveLetter 'S'
}
bcdboot C:\Windows /s S: /f ALL
Start-Sleep -Seconds 10
$SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
#===================================================================================================
#   Scripts/Apply-Drivers.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Apply-Drivers.ps1"
if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
    Save-MyDellDriverCab
}

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
#   Scripts/Save-AutoPilotModules.ps1
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "Scripts/Save-AutoPilotModules.ps1"

Save-Module -Name WindowsAutoPilotIntune -Path 'C:\Program Files\WindowsPowerShell\Modules'
if (-NOT (Test-Path 'C:\Program Files\WindowsPowerShell\Scripts')) {
    New-Item -Path 'C:\Program Files\WindowsPowerShell\Scripts' -ItemType Directory -Force | Out-Null
}
Save-Script -Name Get-WindowsAutoPilotInfo -Path 'C:\Program Files\WindowsPowerShell\Scripts'
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
#   COMPLETE
#===================================================================================================
Write-Host -ForegroundColor DarkCyan    "================================================================="
Write-Host -ForegroundColor White       "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
Write-Host -ForegroundColor Green       "OSDCloud is complete"
Write-Host -ForegroundColor Green       "You can run additional steps or reboot at this time"
Write-Host -ForegroundColor DarkCyan    "================================================================="