<#PSScriptInfo
.VERSION 24.2.23.1
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
    Version 24.2.23.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/subdomains/tpm.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm tpm.osdcloud.com)
#>
[CmdletBinding()]
param()
$ScriptName = 'tpm.osdcloud.com'
$ScriptVersion = '24.2.23.1'

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

Autopilot Known Issues
https://learn.microsoft.com/en-us/autopilot/known-issues

TPM Key Attestation
https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/tpm-key-attestation

https://techcommunity.microsoft.com/t5/microsoft-intune/device-certificate-for-hybrid-azure-ad-join/m-p/3748571
#>

#region TpmCloud Configuration
$Global:TpmCloudConfig = $null
$Global:TpmCloudConfig = [ordered]@{
    TpmNamespace                = 'root/cimv2/Security/MicrosoftTpm'
    TpmClass                    = 'Win32_Tpm'
    MicrosoftConnectionUri      = 'http://www.msftconnecttest.com/connecttest.txt'
    EKCertificatesRegPath       = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tpm\WMI\Endorsement\EKCertStore\Certificates\*'
    MeasuredBootRegPath         = 'HKLM:\SYSTEM\CurrentControlSet\Control\IntegrityServices'
    MeasuredBootRegProperty     = 'WBCL'
}
$Global:TpmCloud = $null
$Global:TpmCloud = [ordered]@{
    IsTpmPresent                    = $null
    IsAutopilotReady                = $true
    IsTpmReady                      = $true
    IsTpmV2                         = $null
    GetTpmIsReadyInformation        = $null
    TestMicrosoftConnection         = $true
    ResultMicrosoftConnection       = $null
    EKCertificatesRegData           = $null
    MeasuredBootRegData             = $null
    TpmToolGetDeviceInformation     = $null
    GetTpmEndorsementKeyInfo        = $null
    Win32Tpm                        = $null
    TpmMaintenanceTaskComplete      = $null
}
#endregion

function Get-Win32Tpm {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get Win32_Tpm" -ForegroundColor Cyan
    Write-Host "Get-CimInstance -Namespace $($Global:TpmCloudConfig.TpmNamespace) -ClassName $($Global:TpmCloudConfig.TpmClass)" -ForegroundColor DarkGray

    $Global:TpmCloud.Win32Tpm = Get-CimInstance -Namespace $($Global:TpmCloudConfig.TpmNamespace) -ClassName $($Global:TpmCloudConfig.TpmClass) -ErrorAction SilentlyContinue

    if ($Global:TpmCloud.Win32Tpm) {
        $Global:TpmCloud.IsTpmPresent = [bool]$true
        $Global:TpmCloud.Win32Tpm
    }
    else {
        Write-Warning "Unable to get TPM information."
        Write-Warning "Autopilot will fail."
        $Global:TpmCloud.IsTpmPresent = [bool]$false
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
}
function Test-Win32Tpm {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Win32_Tpm" -ForegroundColor Cyan

    if ($Global:TpmCloud.Win32Tpm.IsEnabled_InitialValue -ne $true) {
        Write-Warning "TPM is not enabled."
        Write-Warning "Autopilot will fail."
        $Global:TpmCloud.Win32Tpm.IsTpmReady = [bool]$false
        $Global:TpmCloud.Win32Tpm.IsAutopilotReady = [bool]$false
    }
    if ($Global:TpmCloud.Win32Tpm.IsActivated_InitialValue -ne $true) {
        Write-Warning "TPM is not yet activated."
    }
    if ($Global:TpmCloud.Win32Tpm.IsOwned_InitialValue -ne $true) {
        Write-Host "TPM is not owned." -ForegroundColor DarkGray
        Write-Host "Windows automatically initializes and takes ownership of the TPM. There's no need for you to initialize the TPM and create an owner password." -ForegroundColor DarkGray
        Write-Host 'https://learn.microsoft.com/en-us/windows/security/hardware-security/tpm/initialize-and-configure-ownership-of-the-tpm' -ForegroundColor DarkGray
    }
    if ($Global:TpmCloud.Win32Tpm.SpecVersion -like '*2.0*') {
        Write-Host "TPM version is 2.0." -ForegroundColor DarkGray
        Write-Host "Attestation requires TPM 2.0." -ForegroundColor DarkGray
        $Global:TpmCloud.IsTpmV2 = [bool]$true
    }
    elseif ($Global:TpmCloud.Win32Tpm.SpecVersion -like '*1.2*') {
        Write-Host "TPM version is 1.2." -ForegroundColor DarkGray
        Write-Host "Attestation requires TPM 2.0." -ForegroundColor DarkGray
        $Global:TpmCloud.IsTpmV2 = [bool]$true
    }
    elseif ($Global:TpmCloud.Win32Tpm.SpecVersion -like '*1.15*') {
        Write-Host 'TPM version is 1.15.' -ForegroundColor DarkGray
        Write-Host 'Attestation requires TPM 2.0.' -ForegroundColor DarkGray
        $Global:TpmCloud.IsTpmV2 = [bool]$true
    }
    else {
        Write-Warning "TPM version is not supported."
        Write-Warning "Attestation requires TPM 2.0."
        Write-Warning "Autopilot will fail."
        $Global:TpmCloud.IsTpmV2 = [bool]$false
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
}
function Test-Win32TpmIsReady {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get Win32_Tpm IsReadyInformation" -ForegroundColor Cyan
    $Global:TpmCloud.GetTpmIsReadyInformation = Get-CimInstance -Namespace $($Global:TpmCloudConfig.TpmNamespace) -ClassName $($Global:TpmCloudConfig.TpmClass) -ErrorAction SilentlyContinue | Invoke-CimMethod -MethodName 'IsReadyInformation'
    $Global:TpmCloud.GetTpmIsReadyInformation
    if ($Global:TpmCloud.GetTpmIsReadyInformation.Information -eq '0') {
        Write-Host 'TPM is ready for attestation.' -ForegroundColor DarkGray
    }
    else {
        Write-Warning 'TPM is not ready for attestation.'
        Write-Host 'Win32_Tpm::IsReadyInformation method' -ForegroundColor DarkGray
        Write-Host 'https://docs.microsoft.com/en-us/windows/win32/tpm/tpm-is-ready-information' -ForegroundColor DarkGray
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
    if ($Global:TpmCloud.GetTpmIsReadyInformation.Information -eq '262144') {
        Write-Warning 'Information: 262144 (0x00040000)'
        Write-Warning 'INFORMATION_EK_CERTIFICATE'
        Write-Warning 'The EK Certificate was not read from the TPM NV Ram and stored in the registry.'
        Write-Warning 'Autopilot will fail.'
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
    if ($Global:TpmCloud.GetTpmIsReadyInformation.Information -eq '16777216') {
        Write-Warning 'Information: 16777216 (0x01000000)'
        Write-Warning 'INFORMATION_ATTESTATION_VULNERABILITY'
        Write-Warning 'The TPM has a Health Attestation related vulnerability.'
        Write-Warning 'Autopilot will fail.'
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
}

function Test-TpmToolGetDeviceInformation {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test tpmtool.exe GetDeviceInformation" -ForegroundColor Cyan
    $Global:TpmCloud.TpmToolGetDeviceInformation = tpmtool.exe GetDeviceInformation
    if ($Global:TpmCloud.TpmToolGetDeviceInformation) {
        $Global:TpmCloud.TpmToolGetDeviceInformation

        if ($Global:TpmCloud.TpmToolGetDeviceInformation -match 'Maintenance Task Complete: True') {
            $Global:TpmCloud.TpmMaintenanceTaskComplete = [bool]$true
        }
        else {
            $Global:TpmCloud.TpmMaintenanceTaskComplete = [bool]$false
        }
    }
    else {
        Write-Warning "tpmtool.exe GetDeviceInformation failed"
    }
}
function Test-TpmMaintenanceTaskComplete {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test TPM Maintenance Task Complete" -ForegroundColor Cyan
    if ($Global:TpmCloud.TpmMaintenanceTaskComplete) {
        Write-Host 'Maintenance Task Complete: True' -ForegroundColor DarkGray
    }
    else {
        Write-Warning 'Maintenance Task Complete: False'
        Write-Warning 'The TPM Maintenance Task is not complete.'
        Write-Warning 'Autopilot will fail.'
        $Global:TpmCloud.IsTpmReady = [bool]$false
        $Global:TpmCloud.IsAutopilotReady = [bool]$false
    }
}

function Test-RegistryEKCertificates {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    $RegistryPath = $Global:TpmCloudConfig.EKCertificatesRegPath
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test EKCert in the Registry" -ForegroundColor Cyan
    Write-Host "$RegistryPath" -ForegroundColor DarkGray

    if (Test-Path -Path $RegistryPath) {
        $EKCert = Get-ItemProperty -Path $RegistryPath
        $EKCert | Format-List
    }
    else {
        Write-Warning "EKCert key was not found in the Registry"
    }
}
function Test-RegistryWBCL {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\IntegrityServices'
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Windows Boot Configuration Log in the Registry" -ForegroundColor Cyan
    Write-Host "$RegistryPath" -ForegroundColor DarkGray

    if (Test-Path -Path $RegistryPath) {
        $WBCL = Get-ItemProperty -Path $RegistryPath
        $WBCL | Format-List

        $WBCL = (Get-ItemProperty -Path $RegistryPath).WBCL
        if ($null -ne $WBCL) {
            Write-Host "WBCL was found in the Registry" -ForegroundColor DarkGray
        }
        else {
            Write-Warning "WBCL was not found in the Registry"
            Write-Warning "Measured boot logs are missing.  A Reboot may be required"
        }
    }
    else {
        Write-Warning "IntegrityServices key was not found in the Registry"
        Write-Warning "Measured boot logs are missing.  A Reboot may be required"
    }
}
function Test-RegistrySetupDisplayedEula {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE'
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Windows OOBE SetupDisplayedEula in the Registry" -ForegroundColor Cyan
    Write-Host "$RegistryPath" -ForegroundColor DarkGray

    if (Test-Path -Path $RegistryPath) {
        $WBCL = Get-ItemProperty -Path $RegistryPath
        $WBCL | Format-List

        $SetupDisplayedEulaValue = (Get-ItemProperty -Path $RegistryPath).SetupDisplayedEula
        if ($null -ne $SetupDisplayedEulaValue) {
            Write-Host 'SetupDisplayedEula was found in the Registry' -ForegroundColor DarkGray
        }
        else {
            Write-Warning 'SetupDisplayedEula was not found in the Registry'
            Write-Warning 'Manually SetupDisplayedEula = 1 to HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE'
            New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE' -Name 'SetupDisplayedEula' -Value 1
            Write-Warning "A Reboot may be required to resolve this issue."
        }
    }
    else {
        Write-Warning "Setup OOBE key was not found in the Registry"
    }
    
}
function Test-AutopilotWindowsLicense {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Windows License for Autopilot" -ForegroundColor Cyan

    $WindowsProductKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    $WindowsProductType = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKeyDescription
    if ($WindowsProductKey) {
        Write-Host "PASS: BIOS OA3 Windows ProductKey is $WindowsProductKey" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "BIOS OA3 Windows ProductKey is not present"
    }
    if ($WindowsProductType) {
        Write-Host "PASS: BIOS OA3 Windows ProductKeyDescription is $WindowsProductType" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "FAIL: BIOS OA3 Windows ProductKeyDescription is $WindowsProductType"
    }

    if ($WindowsProductType -like '*Professional*' -or $WindowsProductType -eq 'Windows 10 Pro' -or $WindowsProductType -like '*Enterprise*') {
        Write-Host "PASS: BIOS Windows license is valid for Microsoft 365" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "FAIL: BIOS Windows license is not valid for Microsoft 365"
        $WindowsProductType = Get-ComputerInfo | Select-Object WindowsProductName 
        $WindowsProductType = $WindowsProductType.WindowsProductName
    
        if ($WindowsProductType -like '*Professional*' -or $WindowsProductType -eq 'Windows 10 Pro' -or $WindowsProductType -like '*Enterprise*') {
            Write-Host "PASS: Software Windows license is valid for Microsoft 365" -ForegroundColor DarkGray
        }
        else {
            Write-Warning "FAIL: Software Windows license is not valid for Microsoft 365"
        }
    }
}


function Get-MDMDiagnosticsTool {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) MDMDiagnosticsTool export to C:\" -ForegroundColor Cyan
    $MDMDiagnosticsFile = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-MDMDiagnosticsTool.cab"
    MDMDiagnosticsTool.exe -area 'DeviceEnrollment;DeviceProvisioning;AutoPilot;TPM' -cab (Join-Path "$env:SystemRoot" $MDMDiagnosticsFile)
}

#region TpmCloud Tests
function Test-MicrosoftConnection {
    try {
        if ($null = Invoke-WebRequest -Uri 'http://www.msftconnecttest.com/connecttest.txt' -Method Head -UseBasicParsing -ErrorAction Stop) {
            $true
        }
        else {
            $false
        }
    }
    catch {
        $false
    }
}
#endregion
#region TPM and Autopilot
function Test-AutopilotUrl {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Autopilot URLs" -ForegroundColor Cyan
    $Server = 'ztd.dds.microsoft.com'
    $Port = 443
    $Message = "Test port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }

    $Server = 'cs.dds.microsoft.com'
    $Port = 443
    $Message = "Test port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }

    $Server = 'login.live.com'
    $Port = 443
    $Message = "Test port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }
}
function Test-AzuretUrl {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Azure URLs" -ForegroundColor Cyan
    $Server = 'azure.net'
    $Port = 443
    $Message = "Test port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }

    $Uri = 'https://portal.manage.microsoft.com'
    $Message = "Test URL $Uri"
    try {
        $response = Invoke-WebRequest -Uri $Uri
    }
    catch {
        $response = $null
    }
    if ($response.StatusCode -eq 200) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }
}
function Test-TpmUrl {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test TPM URLs" -ForegroundColor Cyan
    $Server = 'ekop.intel.com'
    $Port = 443
    $Message = "Test Intel port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }

    $Server = 'ekcert.spserv.microsoft.com'
    $Port = 443
    $Message = "Test Qualcomm port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }

    $Server = 'ftpm.amd.com'
    $Port = 443
    $Message = "Test AMD port $Port on $Server"
    $NetConnection = (Test-NetConnection -ComputerName $Server -Port $Port).TcpTestSucceeded
    if ($NetConnection -eq $true) {
        Write-Host "$Message" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "$Message"
    }
}
function Test-WindowsTimeService {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Windows Time Service" -ForegroundColor Cyan
    Write-Host "Get-Service -Name W32time" -ForegroundColor DarkGray
    $W32Time = Get-Service -Name W32time
    if ($W32Time.Status -eq 'Running') {
        Write-Host "Windows Time Service is $($W32Time.Status)" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "Windows Time Service is $($W32Time.Status)"
        Write-Warning "To sync Windows Time, enter the following commands in an elevated PowerShell window"
        Write-Host "Stop-Service W32Time" -ForegroundColor DarkGray
        Write-Host "cmd /c 'w32tm /unregister'" -ForegroundColor DarkGray
        Write-Host "cmd /c 'w32tm /register'" -ForegroundColor DarkGray
        Write-Host "Start-Service W32Time" -ForegroundColor DarkGray
        Write-Host "cmd /c 'w32tm /resync'" -ForegroundColor DarkGray
        Write-Host "cmd /c 'w32tm /config /update /manualpeerlist:0.pool.ntp.org;1.pool.ntp.org;2.pool.ntp.org;3.pool.ntp.org;0x8 /syncfromflags:MANUAL /reliable:yes'" -ForegroundColor DarkGray
    }
}

#endregion

#region WinPE
if ($WindowsPhase -eq 'WinPE') {
    #osdcloud-SetPowerShellProfile

    Get-Win32Tpm
    if ($Global:TpmCloud.IsTpmPresent) {
        Test-Win32Tpm
        Test-Win32TpmIsReady
        Test-TpmToolGetDeviceInformation
        Test-TpmMaintenanceTaskComplete
    }
    Write-Host -ForegroundColor DarkGray '========================================================================='
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

    Get-Win32Tpm
    if ($Global:TpmCloud.IsTpmPresent) {
        Test-Win32Tpm
        Test-Win32TpmIsReady
        Test-TpmToolGetDeviceInformation
        Test-TpmMaintenanceTaskComplete
        Test-RegistryEKCertificates
        Test-RegistryWBCL
        Test-RegistrySetupDisplayedEula
        Test-AutopilotWindowsLicense
        Get-MDMDiagnosticsTool
    }
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host -ForegroundColor Green '[+] tpm.osdcloud.com Complete'
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    osdcloud-SetExecutionPolicy
    #osdcloud-SetPowerShellProfile

    Get-Win32Tpm
    if ($Global:TpmCloud.IsTpmPresent) {
        Test-Win32Tpm
        Test-Win32TpmIsReady
        Test-TpmToolGetDeviceInformation
        Test-TpmMaintenanceTaskComplete
        Test-RegistryEKCertificates
        Test-RegistryWBCL
        Test-RegistrySetupDisplayedEula
        Test-AutopilotWindowsLicense
        Get-MDMDiagnosticsTool
    }
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host -ForegroundColor Green "[+] tpm.osdcloud.com Complete"
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion