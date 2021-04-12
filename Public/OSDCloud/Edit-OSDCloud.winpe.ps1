<#
.SYNOPSIS
Edits the boot.wim in an OSDCloud.workspace

.Description
Edits the boot.wim in an OSDCloud.workspace

.PARAMETER WorkspacePath
Directory for the OSDCloud.workspace which contains Media directory
This is optional as the OSDCloud.workspace is returned by Get-OSDCloud.workspace automatically

.PARAMETER DriverPath
Path to additional Drivers you want to install

.PARAMETER CloudDriver
Download and install in WinPE drivers from Dell,HP,Nutanix,VMware

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.16     Initial Release
#>
function Edit-OSDCloud.winpe {
    [CmdletBinding()]
    param (
        [string]$WorkspacePath,

        [string[]]$DriverPath,

        [ValidateSet('Dell','HP','IntelWiFi','Nutanix','VMware')]
        [string[]]$CloudDriver,

        [string[]]$Modules,

        [switch]$CopyOSDModule,

        [string]$WebPSScript,
        [string]$Wallpaper
    )

$RegistryConsole = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\Default\Console]
"ColorTable00"=dword:000c0c0c
"ColorTable01"=dword:00da3700
"ColorTable02"=dword:000ea113
"ColorTable03"=dword:00dd963a
"ColorTable04"=dword:001f0fc5
"ColorTable05"=dword:00981788
"ColorTable06"=dword:00009cc1
"ColorTable07"=dword:00cccccc
"ColorTable08"=dword:00767676
"ColorTable09"=dword:00ff783b
"ColorTable10"=dword:000cc616
"ColorTable11"=dword:00d6d661
"ColorTable12"=dword:005648e7
"ColorTable13"=dword:009e00b4
"ColorTable14"=dword:00a5f1f9
"ColorTable15"=dword:00f2f2f2
"CtrlKeyShortcutsDisabled"=dword:00000000
"CursorColor"=dword:ffffffff
"CursorSize"=dword:00000019
"DefaultBackground"=dword:ffffffff
"DefaultForeground"=dword:ffffffff
"EnableColorSelection"=dword:00000000
"ExtendedEditKey"=dword:00000001
"ExtendedEditKeyCustom"=dword:00000000
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000001
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000000
"ForceV2"=dword:00000000
"FullScreen"=dword:00000000
"HistoryBufferSize"=dword:00000032
"HistoryNoDup"=dword:00000000
"InsertMode"=dword:00000001
"LineSelection"=dword:00000001
"LineWrap"=dword:00000001
"LoadConIme"=dword:00000001
"NumberOfHistoryBuffers"=dword:00000004
"PopupColors"=dword:000000f5
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:23290078
"ScreenColors"=dword:00000007
"ScrollScale"=dword:00000001
"TerminalScrolling"=dword:00000000
"TrimLeadingZeros"=dword:00000000
"WindowAlpha"=dword:000000ff
"WindowSize"=dword:001e0078
"WordDelimiters"=dword:00000000

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_cmd.exe]
"FilterOnPaste"=dword:00000000
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00000000
"WindowSize"=dword:0012004e

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00060005
"WindowSize"=dword:001d005f

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00060005
"WindowSize"=dword:001d005f
'@

    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $WinpeStartTime = Get-Date
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #	Get-OSDCloud.template
    #=======================================================================
    if (-NOT (Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
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
    #   Mount-MyWindowsImage
    #=======================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath "$WorkspacePath\Media\Sources\boot.wim"
    $MountPath = $MountMyWindowsImage.Path
    #=======================================================================
    #   Add AutoPilot Profiles
    #=======================================================================
    if (Test-Path "$WorkspacePath\AutoPilot") {
        robocopy "$WorkspacePath\AutoPilot" "$MountPath\OSDCloud\AutoPilot" *.* /mir /ndl /njh /njs /b /np
    }
    #=======================================================================
    #   Add ODT Config
    #=======================================================================
    if (Test-Path "$WorkspacePath\ODT") {
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" *.xml /mir /ndl /njh /njs /b /np
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" setup.exe /mir /ndl /njh /njs /b /np
    }
    #=======================================================================
    #   DriverPath
    #=======================================================================
    foreach ($Driver in $DriverPath) {
        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned
    }
    #=======================================================================
    #   CloudDriver
    #=======================================================================
    foreach ($Driver in $CloudDriver) {
        if ($Driver -eq 'Dell'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB') {
                $SaveWebFile = Save-WebFile -SourceUrl 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                }
            }
        }
        if ($Driver -eq 'HP'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://ftp.hp.com/pub/softpaq/sp110001-110500/sp110326.exe') {
                $SaveWebFile = Save-WebFile -SourceUrl 'https://ftp.hp.com/pub/softpaq/sp110001-110500/sp110326.exe'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName

                    Write-Verbose -Verbose "Expanding HP Client Windows PE Driver Pack to $ExpandPath"
                    Start-Process -FilePath $DriverCab -ArgumentList "/s /e /f `"$ExpandPath`"" -Wait
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                }
            }
        }
        if ($Driver -eq 'IntelWiFi'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://downloadmirror.intel.com/30280/a08/WiFi_22.40.0_Driver64_Win10.zip') {
                #$IntelWiFiDownloads = (Invoke-WebRequest -Uri 'https://downloadmirror.intel.com/30280/a08/WiFi_22.40.0_Driver64_Win10.zip' -UseBasicParsing).Links
                #$IntelWiFiDownloads = $IntelWiFiDownloads | Where-Object {$_.download -match 'Driver64_Win10.zip'} | Sort-Object Download -Unique | Select-Object Download, Title -First 1
                #$SaveWebFile = Save-WebFile -SourceUrl $IntelWiFiDownloads.download
                $SaveWebFile = Save-WebFile -SourceUrl 'https://downloadmirror.intel.com/30280/a08/WiFi_22.40.0_Driver64_Win10.zip'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    Write-Verbose -Verbose "Expanding Intel Wireless Drivers to $ExpandPath"

                    Expand-Archive -Path $DriverCab -DestinationPath $ExpandPath -Force
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                }
            }
            else {
                Write-Warning "Unable to connect to https://downloadmirror.intel.com/30280/a08/WiFi_22.40.0_Driver64_Win10.zip"
            }
        }
        if ($Driver -eq 'Nutanix'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab') {
                $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                }
            }
        }
        if ($Driver -eq 'VMware'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab') {
                $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose
                }
            }
        }
    }
    #=======================================================================
    #   Startnet
    #=======================================================================
    Write-Verbose "Startnet.cmd: wpeinit"
$Startnet = @'
wpeinit
'@
    $Startnet | Out-File -FilePath "$MountPath\Windows\System32\Startnet.cmd" -Force -Encoding ascii

    if (Test-Path "$MountPath\Windows\WirelessConnect.exe") {
        Write-Verbose "Startnet.cmd: net start wlansvc"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'net start wlansvc' -Force

        Write-Verbose "Startnet.cmd: start PowerShell.exe -Command Start-OSDWireless"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell.exe -Command Start-OSDWireless" -Force
    }

    if ($WebPSScript) {
        Write-Warning "The WebPSScript parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe as this will revert to 'start PowerShell.exe'"

        Write-Verbose "Startnet.cmd: start PowerShell.exe -Command Invoke-WebPSScript -WebPSScript $WebPSScript"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start PowerShell.exe -Command Invoke-WebPSScript -WebPSScript $WebPSScript" -Force
    }
    else {
        Write-Verbose "Startnet.cmd: start PowerShell.exe"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start PowerShell.exe' -Force
    }
    #=======================================================================
    #   Wallpaper
    #=======================================================================
    if ($Wallpaper) {
        Write-Verbose "Wallpaper: $Wallpaper"
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winpe.jpg" -Force | Out-Null
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winre.jpg" -Force | Out-Null
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /b /np /r:0 /w:0
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /b /np /r:0 /w:0
    }
    #=======================================================================
    #   Modules
    #=======================================================================
    foreach ($Module in $Modules) {
        if ($Module -eq 'DellBiosProvider') {
            if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                Write-Verbose "Copying $env:SystemRoot\System32\msvcp140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\msvcp140.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\vcruntime140.dll") {
                Write-Verbose "Copying $env:SystemRoot\System32\vcruntime140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                Write-Verbose "Copying $env:SystemRoot\System32\vcruntime140_1.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140_1.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
        }
        Write-Verbose -Verbose "Saving $Module to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #=======================================================================
    #   Install OSD Module
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('CopyOSDModule')) {
        Write-Verbose -Verbose "Copy-PSModuleToWindowsImage -Name OSD -Path $MountPath"
        Copy-PSModuleToWindowsImage -Name OSD -Path $MountPath
    }
    else {
        Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #=======================================================================
    #   Registry Fixes
    #=======================================================================
    $RegistryConsole | Out-File -FilePath "$env:TEMP\RegistryConsole.reg" -Encoding ascii -Force

    #Mount Registry
    reg load HKLM\Default "$MountPath\Windows\System32\Config\DEFAULT"
    reg import "$env:TEMP\RegistryConsole.reg" | Out-Null

    #Unload Registry
    reg unload HKLM\Default
    #=======================================================================
    #   Save WIM
    #=======================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=======================================================================
    #	Complete
    #=======================================================================
    $WinpeEndTime = Get-Date
    $WinpeTimeSpan = New-TimeSpan -Start $WinpeStartTime -End $WinpeEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WinpeTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
}