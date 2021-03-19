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
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $TemplateStartTime = Get-Date
    #=======================================================================
    #	Require WinOS
    #=======================================================================
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
        Break
    }
    #=======================================================================
    #   Require Admin Rights
    #=======================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #=======================================================================
    #   Require cURL
    #=======================================================================
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "Get a newer Windows version!"
        Break
    }
    #=======================================================================
    #	Set VerbosePreference
    #=======================================================================
    #$CurrentVerbosePreference = $VerbosePreference
    #$VerbosePreference = 'Continue'
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
    #   Startnet
    #=======================================================================
    Write-Verbose "Adding PowerShell.exe to Startnet.cmd"
    $Startnet = Get-Content -Path "$MountPath\Windows\System32\Startnet.cmd"
    if ($Startnet -notmatch "start powershell") {
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start powershell.exe' -Force
    }
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