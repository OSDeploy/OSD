<#PSScriptInfo
.VERSION 23.6.3.1
.GUID 8aa84227-ddb5-4276-95fb-ffb2d6121bf8
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2023 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinGet PowerShell
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri winget.osdcloud.com)
This is abbreviated as
powershell iex (irm winget.osdcloud.com)
#>
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PowerShell Script which supports WinGet
.DESCRIPTION
    PowerShell Script which supports WinGet
.NOTES
    Version 23.6.3.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/subdomains/winget.osdcloud.ps1
.EXAMPLE
    powershell iex (irm winget.osdcloud.com)
#>
[CmdletBinding()]
param()
$ScriptName = 'winget.osdcloud.com'
$ScriptVersion = '23.6.3.1'

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
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
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
    osdcloud-SetExecutionPolicy
    osdcloud-WinpeSetEnvironmentVariables
    osdcloud-SetPowerShellProfile
    osdcloud-InstallNuget
    osdcloud-InstallPackageManagement
    osdcloud-WinpeInstallPowerShellGet
    osdcloud-TrustPSGallery
    osdcloud-WinpeInstallCurl
    osdcloud-InstallModuleOSD
    osdcloud-InstallModulePSReadLine
    #Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    Start PowerShell
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
    osdcloud-SetExecutionPolicy
    osdcloud-SetPowerShellProfile
    osdcloud-InstallPackageManagement
    osdcloud-TrustPSGallery
    osdcloud-InstallModuleOSD
    osdcloud-InstallModulePester
    osdcloud-InstallModulePSReadLine
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    osdcloud-SetExecutionPolicy
    osdcloud-SetPowerShellProfile
    osdcloud-InstallPackageManagement
    osdcloud-TrustPSGallery
    osdcloud-InstallModulePester
    osdcloud-InstallModulePSReadLine
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion


if (($WindowsPhase -eq 'OOBE') -or ($WindowsPhase -eq 'Windows')) {

}
#region WinGet
# WinGet is not installed
if (-not (Get-Command 'WinGet' -ErrorAction SilentlyContinue)) {

    # Test if Microsoft.DesktopAppInstaller is present and install it
    if (Get-AppxPackage -Name Microsoft.DesktopAppInstaller) {
        Write-Host -ForegroundColor Yellow "[-] Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    }
}

# Get Microsoft.DesktopAppInstaller version
$AppxPkg = Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($AppxPkg.Version) {
    Write-Host -ForegroundColor Green "[+] Microsoft.DesktopAppInstaller $([string]$AppxPkg.Version)"
}

# Success
$WinGetEXE = Get-Command -Type Application -Name 'winget.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($WinGetEXE) {
    $WinGetVer = & winget.exe --version
    $WinGetVer = $WinGetVer -replace '[a-zA-Z\-]'
    Write-Host -ForegroundColor Green "[+] WinGet $([string]$WinGetVer)"
}
else {
    Write-Host -ForegroundColor Red "[!] WinGet"
}
#endregion

#region PowerShell 7
$PowerShellSeven = Get-ChildItem -Path "$env:ProgramFiles" pwsh.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($PowerShellSeven) {
    Write-Host -ForegroundColor Green "[+] PowerShell $($PowerShellSeven.VersionInfo.FileVersion)"
}
else {
    if ($WinGetEXE) {
        Write-Host -ForegroundColor Yellow "[-] winget install --id Microsoft.PowerShell --exact --scope machine --override '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1' --accept-source-agreements --accept-package-agreements"
        winget install --id Microsoft.PowerShell --exact --scope machine --override '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1' --accept-source-agreements --accept-package-agreements
    }
    else {
        Write-Host -ForegroundColor Yellow "[-] Invoke-Expression (Invoke-RestMethod https://aka.ms/install-powershell.ps1)"
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
    }
    $PowerShellSeven = Get-ChildItem -Path "$env:ProgramFiles" pwsh.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($PowerShellSeven) {
        Write-Host -ForegroundColor Green "[+] PowerShell $($PowerShellSeven.VersionInfo.FileVersion)"
    }
}
#endregion

#region WinGet Upgrade
if ($WinGetEXE) {
    Write-Host -ForegroundColor Green "[+] winget upgrade --all --accept-source-agreements --accept-package-agreements"
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}
#endregion

#Write-Host -ForegroundColor Green "[+] opening PowerShell in a new window"
#start PowerShell

if ($PowerShellSeven) {
    #Write-Host -ForegroundColor Green "[+] opening PowerShell 7 in a new window"
    #start $($PowerShellSeven.FullName)
}

Write-Host -ForegroundColor Green "[+] pwsh.osdcloud.com Complete"
Stop-Transcript