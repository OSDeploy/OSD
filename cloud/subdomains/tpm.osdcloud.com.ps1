<#PSScriptInfo
.VERSION 24.2.21.1
.GUID 0bf5a9ca-9bc5-4c8a-8e58-b5759c99b33d
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2024 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud TPM PowerShell
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri tpm.osdcloud.com)
This is abbreviated as
powershell iex (irm tpm.osdcloud.com)
#>
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PowerShell Script which supports TPM (Trusted Platform Module)
.DESCRIPTION
    PowerShell Script which supports TPM (Trusted Platform Module)
.NOTES
    Version 24.2.21.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/subdomains/tpm.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm tpm.osdcloud.com)
#>
[CmdletBinding()]
param()
$ScriptName = 'tpm.osdcloud.com'
$ScriptVersion = '24.2.21.1'

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


#region TPM and Autopilot
function Test-TpmCimInstance {
    <#
IsActivated_InitialValue    : True
IsEnabled_InitialValue      : True
IsOwned_InitialValue        : True
ManufacturerId              : 1314145024
ManufacturerIdTxt           : NTC
ManufacturerVersion         : 7.2.3.1
ManufacturerVersionFull20   : 7.2.3.1
ManufacturerVersionInfo     : NPCT75x 
PhysicalPresenceVersionInfo : 1.3
SpecVersion                 : 2.0, 0, 1.59
PSComputerName              : 
#>
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-CimInstance -Namespace 'root/cimv2/Security/MicrosoftTpm' -ClassName 'Win32_TPM'" -ForegroundColor Cyan
    $Win32Tpm = Get-CimInstance -Namespace 'root/cimv2/Security/MicrosoftTpm' -ClassName 'Win32_TPM' -ErrorAction SilentlyContinue
    if ($Win32Tpm) {
        $Win32Tpm
        if ($Win32Tpm.IsEnabled_InitialValue -ne $true) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) IsEnabled_InitialValue should be True for Autopilot to work properly"
        }

        if ($Win32Tpm.IsActivated_InitialValue -ne $true) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) IsActivated_InitialValue should be True"
        }
    
        if ($Win32Tpm.IsOwned_InitialValue -ne $true) {
            Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) IsOwned_InitialValue should be True"
        }
        if (!(Get-Tpm | Select-Object tpmowned).TpmOwned -eq $true) {
            Write-Warning 'Reason: TpmOwned is not owned!)'
        }

        $IsReady = $Win32Tpm | Invoke-CimMethod -MethodName 'IsReadyInformation'
        $IsReadyInformation = $IsReady.Information
        if ($IsReadyInformation -eq '0') {
            Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) IsReadyInformation $IsReadyInformation TPM is ready for attestation"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) IsReadyInformation $IsReadyInformation TPM is not ready for attestation"
        }
        if ($IsReadyInformation -eq '16777216') {
            Write-Warning 'The TPM has a Health Attestation related vulnerability'
        }
    }
    else {
        Write-Warning 'FAIL: Unable to get TPM information'
    }
}
function Test-TpmRegistryEkCert {
    $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tpm\WMI\Endorsement\EKCertStore\Certificates\*'
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Registry Test: Windows EKCert" -ForegroundColor Cyan
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $RegistryPath" -ForegroundColor DarkGray

    if (Test-Path -Path $RegistryPath) {
        $EKCert = Get-ItemProperty -Path $RegistryPath
        $EKCert | Format-List
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) EKCert was not found in the Registry"
    }
}
function Test-TpmRegistryWBCL {
    $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\IntegrityServices\*'
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Registry Test: Windows Boot Configuration Log" -ForegroundColor Cyan
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $RegistryPath -Value WBCL" -ForegroundColor DarkGray

    if (Test-Path -Path $RegistryPath) {
        $WBCL = (Get-ItemProperty -Path $RegistryPath).WBCL
        if ($null -ne $WBCL) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WBCL was not found in the Registry"
            Write-Warning 'Measured boot logs are missing.  Reboot may be required.'
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WBCL was not found in the Registry"
        Write-Warning 'Measured boot logs are missing.  Reboot may be required.'
    }
}
#endregion





#region WinPE
if ($WindowsPhase -eq 'WinPE') {

    Test-TpmCimInstance
    Test-TpmRegistryEkCert
    Test-TpmRegistryWBCL
    Write-Host -ForegroundColor Green '[+] tpm.osdcloud.com Complete'
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
    #osdcloud-SetPowerShellProfile

    Test-TpmCimInstance
    Test-TpmRegistryEkCert
    Test-TpmRegistryWBCL
    Write-Host -ForegroundColor Green '[+] tpm.osdcloud.com Complete'
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    osdcloud-SetExecutionPolicy
    #osdcloud-SetPowerShellProfile
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Test-TpmCimInstance
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Test-TpmRegistryEkCert
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Test-TpmRegistryWBCL
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host -ForegroundColor Green "[+] tpm.osdcloud.com Complete"
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion