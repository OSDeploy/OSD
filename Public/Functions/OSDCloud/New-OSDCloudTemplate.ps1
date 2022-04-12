function New-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Creates an OSDCloud Template in $env:ProgramData\OSDCloud

    .DESCRIPTION
    Creates an OSDCloud Template in $env:ProgramData\OSDCloud

    .EXAMPLE
    New-OSDCloudTemplate

    .EXAMPLE
    New-OSDCloudTemplate -WinRE

    .LINK
    https://www.osdcloud.com/setup/osdcloud-template
    #>

    [CmdletBinding()]
    param (
        [System.String]
        #Name of the OSDCloud Template. This determines the OSDCloud Template Path
        $Name = 'default',

        [ValidateSet (
            '*','ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String[]]
        #Adds additional language ADK Packages
        $Language,

        [System.String]
        #Sets all International settings in WinPE to the specified setting
        $SetAllIntl,

        [System.String]
        #Sets the default InputLocale in WinPE to the specified Input Locale
        $SetInputLocale,

        [System.Management.Automation.SwitchParameter]
        #Uses Windows 10 WinRE.wim instead of the ADK Boot.wim
        $WinRE
    )
#=================================================
#   WinREDriver
#=================================================
$WinREDriver = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 07/20/2021,2021.07.20.0

[DefaultInstall] 
AddReg      = AddReg 

[AddReg]
;rootkey,[subkey],[value],[flags],[data]
;0x00000    REG_SZ
;0x00001    REG_BINARY
;0x10000    REG_MULTI_SZ
;0x20000    REG_EXPAND_SZ
;0x10001    REG_DWORD
;0x20001    REG_NONE
HKLM,"Software\Microsoft\Windows NT\CurrentVersion\WinPE",CustomBackground,0x10000,"X:\Windows\System32\winpe.jpg"
'@
#=================================================
#   WinPE Console Registry Settings
#=================================================
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
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontSize"=dword:00100000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00000000
"WindowSize"=dword:00110054

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
"WindowSize"=dword:0020006c

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
"WindowSize"=dword:0020006c
'@
    #=================================================
    #	Start the Clock
    #=================================================
    $TemplateStartTime = Get-Date
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #   Get Adk Paths
    #=================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not get ADK going, sorry"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Test WinRE
    #=================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        if ((Get-WinREPartition).OperationalStatus -ne 'Online') {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You can't use WinRE because of some issue.  Sorry!"
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Break
        }
        if ((Get-RegCurrentVersion).CurrentBuild -gt 20000) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows 11 WinRE does not support booting Virtual Machines"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) It is recommended that you remove the -WinRE parameter if you need Virtual Machine support"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Press Ctrl+C to cancel in the next 10 seconds"
            Start-Sleep -Seconds 10
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
    }
    #=================================================
    #   Test WimSourcePath
    #=================================================
    $WimSourcePath = $AdkPaths.WimSourcePath
    if (-NOT (Test-Path $WimSourcePath)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not find the ADK WimSourcePath: $WimSourcePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Template
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($Name -eq 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
    }
    else {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud\Templates\$Name"
    }

    if (-NOT (Test-Path $OSDCloudTemplate)) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Template: $OSDCloudTemplate"
        $null = New-Item -Path $OSDCloudTemplate -ItemType Directory -Force
    }
    #=================================================
    #   Logs
    #=================================================
    $TemplateLogs = "$OSDCloudTemplate\Logs\Template"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Template Logs at $TemplateLogs"

    if (Test-Path $TemplateLogs) {
        $null = Remove-Item -Path "$TemplateLogs\*" -Recurse -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path $TemplateLogs)) {
        $null = New-Item -Path $TemplateLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-New-OSDCloudTemplate.log"
    Start-Transcript -Path (Join-Path $TemplateLogs $Transcript) -ErrorAction Ignore
    #=================================================
    #   Mirror ADK Media
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring ADK Media using Robocopy"
    Write-Host -ForegroundColor Yellow 'Mirroring will remove any previous WinPE and will force a full rebuild'
    
    $PathWinPEMedia = $AdkPaths.PathWinPEMedia
    Write-Host -ForegroundColor DarkGray "Source: $PathWinPEMedia"

    $DestinationMedia = Join-Path $OSDCloudTemplate 'Media'
    Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia"

    $null = robocopy "$PathWinPEMedia" "$DestinationMedia" *.* /mir /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    #=================================================
    #   Copy Boot.wim
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path "$DestinationSources")) {
        New-Item -Path "$DestinationSources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying WinRE.wim"
        Write-Host -ForegroundColor Yellow "OSD Function: Copy-WinREWIM"

        $BootWim = Join-Path $DestinationSources 'winre.wim'
        Write-Host -ForegroundColor DarkGray "Destination: $BootWim"

        Copy-WinREWIM -DestinationDirectory $DestinationSources -DestinationFileName 'winre.wim' -ErrorAction Stop | Out-Null
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying ADK WinPE.wim"
        $BootWim = Join-Path $DestinationSources 'boot.wim'
        Write-Host -ForegroundColor DarkGray "Source: $WimSourcePath"
        Write-Host -ForegroundColor DarkGray "Destination: $BootWim"

        Copy-Item -Path $WimSourcePath -Destination $BootWim -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Test BootWim
    #=================================================
    if (!(Test-Path $BootWim)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "I'm not sure what happened, but I can't find $BootWim"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    attrib -s -h -r $DestinationSources
    attrib -s -h -r $BootWim
    #=================================================
    #   Download wgl4_boot.ttf
    #   This is used to resolve issues with WinPE Resolutions in 2004/20H2
    #=================================================
    if ((Get-RegCurrentVersion).CurrentBuild -lt 20000) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Replacing Boot Media font wgl4_boot.ttf"
        Write-Host -ForegroundColor Yellow "Replacing this file resolves an issue where WinPE does not boot to the proper display resolution"
    
        $SourceUrl = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $SourceUrl) {
            Write-Host -ForegroundColor DarkGray "Source: $SourceUrl"
            Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia\boot\fonts\wgl4_boot.ttf"
            Save-WebFile -SourceUrl $SourceUrl -DestinationDirectory "$DestinationMedia\boot\fonts" -Overwrite | Out-Null
        }
    
        $SourceUrl = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $SourceUrl) {
            Write-Host -ForegroundColor DarkGray "Source: $SourceUrl"
            Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia\efi\microsoft\boot\fonts\wgl4_boot.ttf"
            Save-WebFile -SourceUrl $SourceUrl -DestinationDirectory "$DestinationMedia\efi\microsoft\boot\fonts" -Overwrite | Out-Null
        }
    }
    #=================================================
    #   Mount-MyWindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mount Boot.wim"
    Write-Host -ForegroundColor Yellow "OSD Function: Mount-MyWindowsImage"
    $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
    $MountPath = $MountMyWindowsImage.Path
    Write-Host -ForegroundColor DarkGray "MountPath: $MountPath"
    #=================================================
    #   WinRE
    #=================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        #=================================================
        #	Wallpaper
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinRE Wallpaper"
        Write-Host -ForegroundColor Yellow "WinRE does not use the standard winpe.jpg and uses an all black winre.jpg"
        Write-Host -ForegroundColor Yellow "This step adds the default WinPE Wallpaper and modifies the Registry to point to winpe.jpg"

        $Wallpaper = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAgACADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5vooor+sD+KwooooAKKKKACiiigD/2Q=='
        [byte[]]$Bytes = [convert]::FromBase64String($Wallpaper)
        [System.IO.File]::WriteAllBytes("$env:TEMP\winpe.jpg",$Bytes)
        #[System.IO.File]::WriteAllBytes("$env:TEMP\winre.jpg",$Bytes)

        Write-Host -ForegroundColor DarkGray "Injecting $MountPath\Windows\System32\winpe.jpg"
        $null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log

        #Write-Host -ForegroundColor DarkGray "Injecting $MountPath\Windows\System32\winre.jpg"
        #$null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        #=================================================
        #   Build Driver
        #=================================================
        $InfFile = "$env:Temp\Set-WinREWallpaper.inf"
        New-Item -Path $InfFile -Force
        Set-Content -Path $InfFile -Value $WinREDriver -Encoding Unicode -Force
        #=================================================
        #   Add Driver
        #=================================================
        Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
        #=================================================
        #	Wireless
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinRE Wireless"
        Write-Host -ForegroundColor Yellow "These files need to be added to support Wireless"

        $SourceFile = "$env:SystemRoot\System32\dmcmnutils.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" dmcmnutils.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        $SourceFile = "$env:SystemRoot\System32\mdmpostprocessevaluator.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmpostprocessevaluator.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        $SourceFile = "$env:SystemRoot\System32\mdmregistration.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmregistration.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        Write-Host -ForegroundColor DarkGray "Downloading https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe"
        Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory "$MountPath\Windows" | Out-Null
    }
    #=================================================
    #   ADK Packages
    #=================================================
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
    #=================================================
    #   Install Default en-us Language
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding default en-US ADK Packages"
    Write-Host -ForegroundColor Yellow "Dism Function: Add-WindowsPackage"
    $Lang = 'en-us'

    foreach ($Package in $OCPackages) {
        $SourceFile = "$WinPEOCs\WinPE-$Package.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-$Package"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
            
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
    }

    $SourceFile = "$WinPEOCs\$Lang\lp.cab"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray "$SourceFile"
        $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"

        Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
        Catch {Write-Host -ForegroundColor Red $CurrentLog}
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }

    foreach ($Package in $OCPackages) {
        $SourceFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
            
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
    }
    #=================================================
    #   Save-WindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
    Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"

    $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
    Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    #=================================================
    #   Install Selected Language
    #=================================================
    if ($Language -contains '*') {
        $Language = Get-ChildItem $WinPEOCs -Directory | Where-Object {$_.Name -ne 'en-us'} | Select-Object -ExpandProperty Name
    }

    foreach ($Lang in $Language) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding $Lang ADK Packages"
        Write-Host -ForegroundColor Yellow "Dism Function: Add-WindowsPackage"

        $SourceFile = "$WinPEOCs\$Lang\lp.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
    
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        foreach ($Package in $OCPackages) {
            $SourceFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
            if (Test-Path $SourceFile) {
                Write-Host -ForegroundColor DarkGray "$SourceFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
                
                Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
                Catch {Write-Host -ForegroundColor Red $CurrentLog}
            }
        }
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
        Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
        Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    }
    #=================================================
    #   International Settings
    #=================================================
    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Current Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }

    if ($SetAllIntl) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying Set-AllIntl"
        Dism /image:"$MountPath" /Set-AllIntl:$SetAllIntl
    }

    if ($SetInputLocale) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying Set-InputLocale"
        Dism /image:"$MountPath" /Set-InputLocale:$SetInputLocale
    }

    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updated Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }
    #=================================================
    #	Additional Files
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinPE Additional Files"
    #=================================================
    #	curl.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "cURL is required for downloading files in WinPE"
    $SourceFile = "$env:SystemRoot\System32\curl.exe"
    Write-Host -ForegroundColor DarkGray $SourceFile
    if (Test-Path $SourceFile) {
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	setx.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "Setx is required for setting System Variables"
    $SourceFile = "$env:SystemRoot\System32\setx.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" setx.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	msinfo32.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "MSInfo32 is helpful for verifying Hardware in WinPE"
    $SourceFile = "$env:SystemRoot\System32\msinfo32.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        Write-Host -ForegroundColor DarkGray "$env:SystemRoot\System32\*\msinfo32.exe.mui"
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" msinfo32.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" msinfo32.exe.mui /s /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	osk.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "OSK adds WinPE On Screen Keyboard"
    $SourceFile = "$env:SystemRoot\System32\osk.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osk.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osksupport.dll /s /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    $SourceFile = "$env:SystemRoot\System32\osksupport.dll"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osksupport.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #   Adding Microsoft DartConfig from MDT
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft DaRT Config from MDT"
    $SourceFile = "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\DartConfig8.dat"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        Copy-Item -Path $SourceFile -Destination "$MountPath\Windows\System32\DartConfig.dat" -Force
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #   Adding Microsoft DaRT
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft DaRT"
    $SourceFile = "$env:ProgramFiles\Microsoft DaRT\v10\Toolsx64.cab"
    if ($Name -match 'public') {
        Write-Host -ForegroundColor DarkGray 'Skipping Microsoft DaRT for Public Template'
    }
    elseif (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        expand.exe "$SourceFile" -F:*.* "$MountPath" | Out-Null
        if (!(Test-Path "$MountPath\Windows\System32\DartConfig.dat")) {
            Write-Warning "Microsoft DaRT requires MDT to be installed so DartConfig.dat can be copied"
        }
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	Save-WindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
    Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"

    $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
    Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    #=================================================
    #	PowerShell Execution Policy
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set WinPE PowerShell ExecutionPolicy to Bypass"
    Write-Host -ForegroundColor Yellow "OSD Function: Set-WindowsImageExecutionPolicy"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass | Out-Null
    #=================================================
    #   Enable PowerShell Gallery
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Enable WinPE PowerShell Gallery"
    Write-Host -ForegroundColor Yellow "OSD Function: Enable-PEWindowsImagePSGallery"
    Enable-PEWindowsImagePSGallery -Path $MountPath | Out-Null
    #=================================================
    #   Remove winpeshl
    #=================================================
    $SourceFile = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Removing WinRE $SourceFile"
        Write-Host -ForegroundColor Yellow "This file is present when using WinRE.wim and needs to be removed for WinPE compatibility"
        Remove-Item -Path $SourceFile -Force
    }
    #=================================================
    #   Registry Fixes
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Modifying WinPE CMD and PowerShell Console settings"
    Write-Host -ForegroundColor Yellow "This increases the buffer and sets the window metrics and default fonts"
    $RegistryConsole | Out-File -FilePath "$env:TEMP\RegistryConsole.reg" -Encoding ascii -Width 2000 -Force

    #Mount Registry
    Invoke-Exe reg load HKLM\Default "$MountPath\Windows\System32\Config\DEFAULT"
    Invoke-Exe reg import "$env:TEMP\RegistryConsole.reg"

    #Scaling
<#     reg add "HKLM\Default\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /t REG_SZ /v "X:\Windows\System32\WirelessConnect.exe" /d "~ HIGHDPIAWARE" /f
    reg add "HKLM\Default\Control Panel\Desktop" /t REG_DWORD /v LogPixels /d 96 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v DpiScalingVer /t REG_DWORD /d 0x00001018 /f #>

    #Unload Registry
    Invoke-Exe reg unload HKLM\Default | Out-Null
    #=================================================
    #   Save WIM
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting and Saving Windows Image"
    Write-Host -ForegroundColor Yellow "OSD Function: Dismount-MyWindowsImage"
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=================================================
    #   Save WIM
    #=================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting WinRE Boot.wim"
        $BootWim = Join-Path $DestinationSources 'boot.wim'
        $WinREWim = Join-Path $DestinationSources 'winre.wim'

        if (Test-Path $BootWim) {
            Remove-Item -Path $BootWim -Force -ErrorAction Stop | Out-Null
        }
        Write-Host -ForegroundColor Yellow "Dism Function: Export-WindowsImage"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-WindowsImage.log"
        Export-WindowsImage -SourceImagePath $WinREWim -SourceIndex 1 -DestinationImagePath $BootWim -DestinationName 'Microsoft Windows PE (x64)' -LogPath $CurrentLog | Out-Null
        Remove-Item -Path $WinREWim -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Directories
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Create Config Directories"

    $CreateDirectories = @(
        'Config\AutopilotJSON',
        'Config\AutopilotOOBE',
        'Config\OOBEDeploy'
    )
    
    if ($Name -match 'public') {
        Write-Host -ForegroundColor DarkGray 'Skipping Config Directories for Public Template'
    }
    else {
        foreach ($Item in $CreateDirectories) {
            $SourcePath = "$OSDCloudTemplate\$Item"
            if (-NOT (Test-Path $SourcePath)) {
                Write-Host -ForegroundColor DarkGray $SourcePath
                New-Item -Path $SourcePath -ItemType Directory -Force | Out-Null
            }
        }
    }
    #=================================================
    #   New-OSDCloudISO
    #=================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    $NewADKiso = New-AdkISO -MediaPath "$OSDCloudTemplate\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=================================================
    #	OSDCloud Template Version
    #=================================================
    $WinPE = [PSCustomObject]@{
        BuildDate = (Get-Date).ToString('yyyy.MM.dd.HHmmss')
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    }

    $WinPE | ConvertTo-Json | Out-File "$OSDCloudTemplate\winpe.json" -Encoding ascii -Width 2000 -Force
    #=================================================
    #	Set-OSDCloudTemplate
    #=================================================
    Set-OSDCloudTemplate -Name $Name
    #=================================================
    #	Complete
    #=================================================
    $TemplateEndTime = Get-Date
    $TemplateTimeSpan = New-TimeSpan -Start $TemplateStartTime -End $TemplateEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TemplateTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Write-Host -ForegroundColor Cyan        "OSDCloud Template created at $OSDCloudTemplate"
    Write-Host -ForegroundColor DarkGray    "================================================"
    Stop-Transcript
    #=================================================
}