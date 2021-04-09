<#
.SYNOPSIS
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

.Description
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

.PARAMETER Language
Adds additional language ADK Packages

.PARAMETER SetAllIntl
Sets all International settings in WinPE to the specified setting

.PARAMETER SetInputLocale
Sets the default InputLocale in WinPE to the specified Input Locale

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function New-OSDCloud.template {
    [CmdletBinding()]
    param (
        [ValidateSet (
            '*','ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [string[]]$Language,

        [string]$SetAllIntl,
        [string]$SetInputLocale,

        [switch]$WinRE
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

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]
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

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]
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

    if ($PSBoundParameters.ContainsKey('WinRE')) {
        Write-Verbose "Copying WinRE.wim to $BootWim"
        Copy-WinRE -DestinationDirectory $DestinationSources -DestinationFileName 'boot.wim' -Verbose
    }
    else {
        Write-Verbose "Copying ADK Boot.wim to $BootWim"
        Copy-Item -Path $WimSourcePath -Destination $BootWim -Force
    }
    #=======================================================================
    #   Download wgl4_boot.ttf
    #   This is used to resolve issues with WinPE Resolutions in 2004/20H2
    #=======================================================================
    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf') {
        Write-Verbose "Repairing bad WinPE resolution by replacing wgl4_boot.ttf"
        Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf' -DestinationDirectory "$DestinationMedia\boot\fonts" -Overwrite | Out-Null
    }
    if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf') {
        Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf' -DestinationDirectory "$DestinationMedia\efi\microsoft\boot\fonts" -Overwrite | Out-Null
    }
    #=======================================================================
    #   Mount-MyWindowsImage
    #=======================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
    $MountPath = $MountMyWindowsImage.Path
    #=======================================================================
    #   WinRE
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        #=======================================================================
        #	Wallpaper
        #=======================================================================
        $Wallpaper = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAgACADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5vooor+sD+KwooooAKKKKACiiigD/2Q=='
        [byte[]]$Bytes = [convert]::FromBase64String($Wallpaper)
        [System.IO.File]::WriteAllBytes("$env:TEMP\winre.jpg",$Bytes)
        [System.IO.File]::WriteAllBytes("$env:TEMP\winpe.jpg",$Bytes)

        robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /r:0 /w:0 /b
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /r:0 /w:0 /b
        #=======================================================================
        #	Wireless
        #=======================================================================
        Write-Verbose "Adding Wireless support to $MountPath"
        if (Test-Path "$env:SystemRoot\System32\dmcmnutils.dll") {
            robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" dmcmnutils.dll /ndl /njh /njs /r:0 /w:0 /b
        } else {
            Write-Warning "Could not find $env:SystemRoot\System32\dmcmnutils.dll"
        }
        
<#         if (Test-Path "$env:SystemRoot\System32\mdmpostprocessevaluator.dll") {
            robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmpostprocessevaluator.dll /ndl /njh /njs /r:0 /w:0 /b
        } else {
            Write-Warning "Could not find $env:SystemRoot\System32\mdmpostprocessevaluator.dll"
        } #>

        if (Test-Path "$env:SystemRoot\System32\mdmregistration.dll") {
            robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmregistration.dll /ndl /njh /njs /r:0 /w:0 /b
        } else {
            Write-Warning "Could not find $env:SystemRoot\System32\mdmregistration.dll"
        }

        Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory "$MountPath\Windows"
    }
    #=======================================================================
    #   Packages
    #=======================================================================
    $ErrorActionPreference = 'Ignore'
    $WinPEOCs = $AdkPaths.WinPEOCs

    $OCPackages = @(
        'WMI'
        'HTA'
        'NetFx'
        'Scripting'
        'PowerShell'
        'SecureStartup'
        'DismCmdlets'
        'Dot3Svc'
        'EnhancedStorage'
        'FMAPI'
        'GamingPeripherals'
        'PPPoE'
        'PlatformId'
        'PmemCmdlets'
        'RNDIS'
        'SecureBootCmdlets'
        'StorageWMI'
        'WDS-Tools'
    )
    #=======================================================================
    #   Install Default en-us Language
    #=======================================================================
    $Lang = 'en-us'

    if (Test-Path "$WinPEOCs\$Lang\lp.cab") {
        Write-Verbose -Verbose "$WinPEOCs\$Lang\lp.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\$Lang\lp.cab" -Verbose
    }

    foreach ($Package in $OCPackages) {
        if (Test-Path "$WinPEOCs\WinPE-$Package.cab") {
            Write-Verbose -Verbose "$WinPEOCs\WinPE-$Package.cab"
            Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-$Package.cab" -Verbose
        }

        if (Test-Path "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab") {
            Write-Verbose -Verbose "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
            Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab" -Verbose
        }
    }
    #=======================================================================
    #   Install Selected Language
    #=======================================================================
    if ($Language -contains '*') {
        Write-Verbose -Verbose "Installing all available ADK Languages"
        $Language = Get-ChildItem $WinPEOCs -Directory | Where-Object {$_.Name -ne 'en-us'} | Select-Object -ExpandProperty Name
    }

    foreach ($Lang in $Language) {
        if (Test-Path "$WinPEOCs\$Lang\lp.cab") {
            Write-Verbose -Verbose "$WinPEOCs\$Lang\lp.cab"
            Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\$Lang\lp.cab" -Verbose
        }

        foreach ($Package in $OCPackages) {
            if (Test-Path "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab") {
                Write-Verbose -Verbose "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
                Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab" -Verbose
            }
        }
        Save-WindowsImage -Path $MountPath
    }
    #=======================================================================
    #   International Settings
    #=======================================================================
    if ($SetAllIntl -or $SetInputLocale) {
        Write-Verbose -Verbose "Current Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }

    if ($SetAllIntl) {
        Write-Verbose -Verbose "Applying Set-AllIntl"
        Dism /image:"$MountPath" /Set-AllIntl:$SetAllIntl
    }

    if ($SetInputLocale) {
        Write-Verbose -Verbose "Applying Set-InputLocale"
        Dism /image:"$MountPath" /Set-InputLocale:$SetInputLocale
    }

    if ($SetAllIntl -or $SetInputLocale) {
        Write-Verbose -Verbose "Updated Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }
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
    #	21.3.24 Setx
    #   Required for Chocolatey support
    #=======================================================================
    Write-Verbose "Adding setx.exe to $MountPath"
    if (Test-Path "$env:SystemRoot\System32\setx.exe") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" setx.exe /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\setx.exe"
        Write-Warning "You must be using an old version of Windows"
    }
    #=======================================================================
    #	OSK 21.3.25.2
    #=======================================================================
    Write-Verbose "Adding On Screen Keyboard support to $MountPath"
    if (Test-Path "$env:SystemRoot\System32\osk.exe") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osk.exe /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\osk.exe"
    }
    if (Test-Path "$env:SystemRoot\System32\osksupport.dll") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osksupport.dll /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\osksupport.dll"
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
    #   Registry Fixes
    #=======================================================================
    $RegistryConsole | Out-File -FilePath "$env:TEMP\RegistryConsole.reg" -Encoding ascii -Force

    #Mount Registry
    reg load HKLM\Default "$MountPath\Windows\System32\Config\DEFAULT"
    reg import "$env:TEMP\RegistryConsole.reg" | Out-Null

    #Scaling
<#     reg add "HKLM\Default\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /t REG_SZ /v "X:\Windows\System32\WirelessConnect.exe" /d "~ HIGHDPIAWARE" /f
    reg add "HKLM\Default\Control Panel\Desktop" /t REG_DWORD /v LogPixels /d 96 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v DpiScalingVer /t REG_DWORD /d 0x00001018 /f #>

    #Unload Registry
    reg unload HKLM\Default
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
    if (-NOT (Test-Path "$TemplatePath\DriverPacks\Dell")) {
        New-Item -Path "$TemplatePath\DriverPacks\Dell" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$TemplatePath\DriverPacks\HP")) {
        New-Item -Path "$TemplatePath\DriverPacks\HP" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$TemplatePath\DriverPacks\Lenovo")) {
        New-Item -Path "$TemplatePath\DriverPacks\Lenovo" -ItemType Directory -Force | Out-Null
    }
    #=======================================================================
    #   Restore VerbosePreference
    #=======================================================================
    #$VerbosePreference = $CurrentVerbosePreference
    #=======================================================================
    #	OSDCloud Template Version
    #=======================================================================
    $WinPE = [PSCustomObject]@{
        BuildDate = (Get-Date).ToString('yyyy.MM.dd.HHmmss')
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    }

    $WinPE | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\winpe.json" -Encoding ASCII
    #=======================================================================
    #	Complete
    #=======================================================================
    $TemplateEndTime = Get-Date
    $TemplateTimeSpan = New-TimeSpan -Start $TemplateStartTime -End $TemplateEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TemplateTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Write-Host -ForegroundColor Cyan        "OSDCloud Template created at $TemplatePath"
    Write-Host -ForegroundColor Cyan        "Get-OSDCloud.template will return $TemplatePath"
    #=======================================================================
}