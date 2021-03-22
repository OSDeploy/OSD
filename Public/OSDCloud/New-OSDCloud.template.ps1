<#
.SYNOPSIS
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

.Description
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.17     Initial Release
#>
function New-OSDCloud.template {
    [CmdletBinding()]
    param ()

$RegistryAdditions = @'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Console]
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
"FaceName"="__DefaultTTFont__"
"FilterOnPaste"=dword:00000001
"FontFamily"=dword:00000000
"FontSize"=dword:00100000
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

[HKEY_CURRENT_USER\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00120008
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowPosition"=dword:00050005
"WindowSize"=dword:0023006e

[HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00120008
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowPosition"=dword:00050005
"WindowSize"=dword:0023006e
'@

    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $TemplateStartTime = Get-Date
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #   Get Adk Paths
    #=======================================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Warning "Could not get ADK going, sorry"
        Break
    }
    #=======================================================================
    #   Get WinPE.wim
    #=======================================================================
    $TemplatePath = "$env:ProgramData\OSDCloud"
    $WimSourcePath = $AdkPaths.WimSourcePath
    if (-NOT (Test-Path $WimSourcePath)) {
        Write-Warning "Could not find $WimSourcePath, sorry"
        Break
    }
    $PathWinPEMedia = $AdkPaths.PathWinPEMedia
    $DestinationMedia = Join-Path $TemplatePath 'Media'
    Write-Verbose "Copying ADK Media to $DestinationMedia"
    robocopy "$PathWinPEMedia" "$DestinationMedia" *.* /e /ndl /xj /ndl /np /nfl /njh /njs

    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path "$DestinationSources")) {
        New-Item -Path "$DestinationSources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $BootWim = Join-Path $DestinationSources 'boot.wim'
    Write-Verbose "Copying ADK Boot.wim to $BootWim"
    Copy-Item -Path $WimSourcePath -Destination $BootWim -Force
    #=======================================================================
    #   Download wgl4_boot.ttf
    #   This is used to resolve issues with WinPE Resolutions in 2004/2009
    #=======================================================================
    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf') {
        Write-Verbose "Repairing bad WinPE resolution by replacing wgl4_boot.ttf"
        Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf' -DestinationDirectory "$DestinationMedia\boot\fonts" -Overwrite
    }
    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf') {
        Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf' -DestinationDirectory "$DestinationMedia\efi\microsoft\boot\fonts" -Overwrite
    }
    #=======================================================================
    #   Mount-MyWindowsImage
    #=======================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
    $MountPath = $MountMyWindowsImage.Path
    #=======================================================================
    #   Add Packages
    #=======================================================================
    $ErrorActionPreference = 'Ignore'
    $WinPEOCs = $AdkPaths.WinPEOCs

    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-WMI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-WMI_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-HTA.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-HTA_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-NetFx.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-NetFx_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-Scripting.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-Scripting_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PowerShell.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PowerShell_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-SecureStartup.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-SecureStartup_en-us.cab"

    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-DismCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-DismCmdlets_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-Dot3Svc.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-Dot3Svc_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-EnhancedStorage.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-EnhancedStorage_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-FMAPI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-GamingPeripherals.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PPPoE.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PPPoE_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PlatformId.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PmemCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PmemCmdlets_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-RNDIS.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-RNDIS_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-SecureBootCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-StorageWMI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-StorageWMI_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-WDS-Tools.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-WDS-Tools_en-us.cab"
    #=======================================================================
    #	cURL
    #=======================================================================
    Write-Verbose "Adding curl.exe to $MountPath"
    if (Test-Path "$env:SystemRoot\System32\curl.exe") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "You must be using an old version of Windows"
    }
    #=======================================================================
    #	PowerShell Execution Policy
    #=======================================================================
    Write-Verbose "Setting PowerShell ExecutionPolicy to Bypass in $MountPath"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass
    #=======================================================================
    #   Enable PowerShell Gallery
    #=======================================================================
    Write-Verbose "Enabling PowerShell Gallery support in $MountPath"
    Enable-PEWindowsImagePSGallery -Path $MountPath
    #=======================================================================
    #   Adding Microsoft DaRT
    #=======================================================================
    if (Test-Path "C:\Program Files\Microsoft DaRT\v10\Toolsx64.cab") {
        Write-Verbose "Adding Microsoft DaRT"
        expand.exe "C:\Program Files\Microsoft DaRT\v10\Toolsx64.cab" -F:*.* "$MountPath" | Out-Null

        if (Test-Path "$MountPath\Windows\System32\winpeshl.ini") {
            Write-Verbose "Removing $MountPath\Windows\System32\winpeshl.ini"
            Remove-Item -Path "$MountPath\Windows\System32\winpeshl.ini" -Force
        }

        if (Test-Path "C:\Program Files\Microsoft Deployment Toolkit\Templates\DartConfig8.dat") {
            Write-Verbose "Adding Microsoft DaRT Config"
            Copy-Item -Path "C:\Program Files\Microsoft Deployment Toolkit\Templates\DartConfig8.dat" -Destination "$MountPath\Windows\System32\DartConfig.dat" -Force
        }
    }
    #=======================================================================
    #   Registry Fix
    #=======================================================================
    $RegistryAdditions | Out-File -FilePath "$env:TEMP\RegistryAdditions.reg" -Encoding ascii -Force
    reg import "$env:TEMP\RegistryAdditions.reg" | Out-Null
    #=======================================================================
    #   Save WIM
    #=======================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=======================================================================
    #   Directories
    #=======================================================================
    if (-NOT (Test-Path "$TemplatePath\AutoPilot\Profiles")) {
        New-Item -Path "$TemplatePath\AutoPilot\Profiles" -ItemType Directory -Force | Out-Null
    }
    #=======================================================================
    #   Restore VerbosePreference
    #=======================================================================
    #$VerbosePreference = $CurrentVerbosePreference
    #=======================================================================
    #	Complete
    #=======================================================================
    $TemplateEndTime = Get-Date
    $TemplateTimeSpan = New-TimeSpan -Start $TemplateStartTime -End $TemplateEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TemplateTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
    #	Return
    #=======================================================================
    Write-Host -ForegroundColor Cyan        "OSDCloud Template created at $TemplatePath"
    Write-Host -ForegroundColor Cyan        "Get-OSDCloud.template will return $TemplatePath"
    #Return $TemplatePath
    #=======================================================================
}