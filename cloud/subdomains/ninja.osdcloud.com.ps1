<#PSScriptInfo
.VERSION 24.9.6.1
.GUID 3066fde0-75e9-4b35-9038-3e5781a34228
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2024 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri ninja.osdcloud.com)
This is abbreviated as
powershell iex (irm ninja.osdcloud.com)
#>
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PowerShell Script which supports the OSDCloud environment
.DESCRIPTION
    PowerShell Script which supports the OSDCloud environment
.NOTES
    Version 24.9.6.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/ninja.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm ninja.osdcloud.com)
#>
[CmdletBinding()]
$ScriptName = 'ninja.osdcloud.com'
$ScriptVersion = '24.9.6.1'

#region Initialize
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$ScriptName.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

if ($env:SystemDrive -eq 'X:') {
    $WindowsPhase = 'WinPE'
}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

Write-Host -ForegroundColor Green "[+] $ScriptName $ScriptVersion ($WindowsPhase Phase)"
#Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#region Admin Elevation
$whoiam = [system.security.principal.windowsidentity]::getcurrent().name
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($isElevated) {
    Write-Host -ForegroundColor Green "[+] Running as $whoiam (Admin Elevated)"
}
else {
    Write-Host -ForegroundColor Red "[!] Running as $whoiam (NOT Admin Elevated)"
    Break
}
#endregion

#region Transport Layer Security (TLS) 1.2
Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
#endregion

#region WinPE
if ($WindowsPhase -eq 'WinPE') {

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Specialize
if ($WindowsPhase -eq 'Specialize') {

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region OOBE
if ($WindowsPhase -eq 'OOBE') {

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region PowerShell Prompt
<#
Since these functions are temporarily loaded, the PowerShell Prompt is changed to make it visual if the functions are loaded or not
[WPNinja]: PS C:\>

You can read more about how to make the change here
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1
#>
function Prompt {
    $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
    else { "[WPNinja]: " }
    ) + 'PS ' + $(Get-Location) +
    $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
#endregion
function ninja-WinGetInstallADK21H2 {
    [CmdletBinding()]
    param ()
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        # Show package information
        # winget show --id Microsoft.WindowsADK
        
        # Show version information
        # winget show --id Microsoft.WindowsADK --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.WindowsADK --version 10.1.22000.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.WindowsADK --version 10.1.22000.1 --exact --accept-source-agreements --accept-package-agreements
    
        # Show package information
        # winget show --id Microsoft.ADKPEAddon
        
        # Show version information
        # winget show --id Microsoft.ADKPEAddon --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.ADKPEAddon --version 10.1.22000.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.ADKPEAddon --version 10.1.22000.1 --exact --accept-source-agreements --accept-package-agreements
        
        # Resolves issue with MDT locking up without this directory present on WinPE x86 tab
        Write-Host 'New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force' -ForegroundColor Cyan
        New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force
    }
    else {
        Write-Error -Message 'WinGet is not installed.'
    }
}
function ninja-WinGetInstallADK22H2 {
    [CmdletBinding()]
    param ()
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        # Show package information
        # winget show --id Microsoft.WindowsADK
    
        # Show version information
        # winget show --id Microsoft.WindowsADK --versions
    
        # Install
        Write-Host 'winget install --id Microsoft.WindowsADK --version 10.1.22621.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.WindowsADK --version 10.1.22621.1 --exact --accept-source-agreements --accept-package-agreements
        
        # Show package information
        # winget show --id Microsoft.ADKPEAddon
        
        # Show version information
        # winget show --id Microsoft.ADKPEAddon --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.ADKPEAddon --version 10.1.22621.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.ADKPEAddon --version 10.1.22621.1 --exact --accept-source-agreements --accept-package-agreements
        
        # Resolves issue with MDT locking up without this directory present on WinPE x86 tab
        Write-Host 'New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force' -ForegroundColor Cyan
        New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force
    }
    else {
        Write-Error -Message 'WinGet is not installed.'
    }
}
function ninja-WinGetInstallADK23H2 {
    [CmdletBinding()]
    param ()
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        # Show package information
        # winget show --id Microsoft.WindowsADK
        
        # Show version information
        # winget show --id Microsoft.WindowsADK --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.WindowsADK --version 10.1.25398.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.WindowsADK --version 10.1.25398.1 --exact --accept-source-agreements --accept-package-agreements
    
        # Show package information
        # winget show --id Microsoft.ADKPEAddon
        
        # Show version information
        # winget show --id Microsoft.ADKPEAddon --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.ADKPEAddon --version 10.1.25398.1 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.ADKPEAddon --version 10.1.25398.1 --exact --accept-source-agreements --accept-package-agreements
        
        # Resolves issue with MDT locking up without this directory present on WinPE x86 tab
        Write-Host 'New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force' -ForegroundColor Cyan
        New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" -ItemType Directory -Force
    }
    else {
        Write-Error -Message 'WinGet is not installed.'
    }
}
function ninja-WinGetInstallMDT {
    [CmdletBinding()]
    param ()
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        # Show package information
        # winget show --id Microsoft.DeploymentToolkit
        
        # Show version information
        # winget show --id Microsoft.DeploymentToolkit --versions
        
        # Install
        Write-Host 'winget install --id Microsoft.DeploymentToolkit --version 6.3.8456.1000 --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Microsoft.DeploymentToolkit --version 6.3.8456.1000 --exact --accept-source-agreements --accept-package-agreements
    }
    else {
        Write-Error -Message 'WinGet is not installed.'
    }
}
function ninja-WinGetInstallGit {
    [CmdletBinding()]
    param ()
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        # Show package information
        # winget show --id Git.Git
        
        # Show version information
        # winget show --id Git.Git --versions
        
        # Install
        Write-Host 'winget install --id Git.Git --exact --accept-source-agreements --accept-package-agreements' -ForegroundColor Cyan
        winget install --id Git.Git --exact --accept-source-agreements --accept-package-agreements
    }
    else {
        Write-Error -Message 'WinGet is not installed.'
    }
}
function ninja-CloneMicrosoftDaRT {
    Write-Host 'git clone https://github.com/OSDeploy/MicrosoftDaRT.git "C:\Program Files\Microsoft DaRT\v10"' -ForegroundColor Cyan
    git clone https://github.com/OSDeploy/MicrosoftDaRT.git "C:\Program Files\Microsoft DaRT\v10"
}
function ninja-BuildTemplates {
    Write-Host 'New-OSDCloudTemplate -Name VM' -ForegroundColor Cyan
    New-OSDCloudTemplate -Name VM
    Write-Host 'New-OSDCloudTemplate -Name Wireless -WinRE' -ForegroundColor Cyan
    New-OSDCloudTemplate -Name Wireless -WinRE
}