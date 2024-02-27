<#PSScriptInfo
.VERSION 24.2.24.1
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
    Version 24.2.24.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/subdomains/tpm.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm tpm.osdcloud.com)
#>
[CmdletBinding()]
param()
$ScriptName = 'tpm.osdcloud.com'
$ScriptVersion = '24.2.24.1'

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
            Write-Warning 'Adding SetupDisplayedEula = 1 to HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE'
            New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE' -Name 'SetupDisplayedEula' -Value 1
            Write-Warning "Reboot is required to resolve this issue."
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
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) MDMDiagnosticsTool CollectLog" -ForegroundColor Cyan
    $MDMDiagnosticsFile = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-MDMDiagnosticsTool.cab"
    Write-Host "MDMDiagnosticsTool.exe -area 'DeviceEnrollment;DeviceProvisioning;AutoPilot;TPM' -cab $(Join-Path "$env:SystemRoot\Temp" $MDMDiagnosticsFile)" -ForegroundColor DarkGray
    MDMDiagnosticsTool.exe -area 'DeviceEnrollment;DeviceProvisioning;AutoPilot;TPM' -cab (Join-Path "$env:SystemRoot\Temp" $MDMDiagnosticsFile)
}
function Get-EKCertificates {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-TpmEndorsementKeyInfo - EK Certificates" -ForegroundColor Cyan
    if (Get-Command -Name Get-TpmEndorsementKeyInfo -ErrorAction SilentlyContinue) {
        $TpmEndorsementKeyInfo = Get-TpmEndorsementKeyInfo
        if ($TpmEndorsementKeyInfo) {
            $TpmEndorsementKeyInfo
            $TpmEKCertificateFile = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-TpmEKCertificate.der"
            Write-Host "Exporting TPM EK Certificate to $env:SystemRoot\Temp\$TpmEKCertificateFile" -ForegroundColor DarkGray
            $TpmEndorsementKeyInfo.ManufacturerCertificates | Export-Certificate -FilePath "$env:SystemRoot\Temp\$TpmEKCertificateFile" -Force
        }
        else {
            Write-Warning "Get-TpmEndorsementKeyInfo returned no data"
        }
    }
    else {
        Write-Warning "Get-TpmEndorsementKeyInfo PowerShell cmdlet is not present"
    }
}
function Get-WprLoggingStatus {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-WprLoggingStatus" -ForegroundColor Cyan
    Write-Host "wpr.exe -status" -ForegroundColor DarkGray
    wpr.exe -status
}
function Stop-WprLogging {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stop-WprLogging" -ForegroundColor Cyan
    Write-Host "wpr.exe -stop $env:SystemRoot\Temp\TraceLogs\results.etl" -ForegroundColor DarkGray
    wpr.exe -stop $env:SystemRoot\Temp\TraceLogs\results.etl
    explorer $env:SystemRoot\Temp\TraceLogs
}
function Start-WprLogging {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-WprLogging" -ForegroundColor Cyan

$wprp = @'
<?xml version="1.0" encoding="utf-8"?>
<WindowsPerformanceRecorder Version="1.0" Author="Microsoft Corporation" Copyright="Microsoft Corporation" Company="Microsoft Corporation">
  <Profiles>
               <EventCollector Id="EventCollector_MDMTraceLoggingProvider" Name="MDMTraceLoggingProviderCollector">
      <BufferSize Value="8192" />
      <Buffers Value="32" />
    </EventCollector>
   

                   
    <Profile Id="MDMTraceLoggingProvider.Verbose.File" Name="MDMTraceLoggingProvider" Description="AllMDMTraceLoggingProvider" LoggingMode="File" DetailLevel="Verbose">
      <Collectors>
           <EventCollectorId Value="EventCollector_MDMTraceLoggingProvider">
             <EventProviders>
               <EventProvider Id="EventProvider_WMITraceLoggingProvider" Name="A76DBA2C-9683-4BA7-8FE4-C82601E117BB" />
               <EventProvider Id="EventProvider_CertificateStore" Name="536D7120-A8A4-4A5F-B1F8-1735DF9B78D0" />
               <EventProvider Id="EventProvider_ConfigManager2HookGuid" Name="76FA08A3-6807-48DB-855D-2C12702630EF" />
               <EventProvider Id="EventProvider_ConfigManager2" Name="0BA3FB88-9AF5-4D80-B3B3-A94AC136B6C5" />
               <EventProvider Id="EventProvider_DeviceManagementSettings" Name="a8fd7a5b-4323-4172-b85b-f5b78c3c0f9c" />
               <EventProvider Id="EventProvider_DevInfoCSP" Name="FE5A93CC-0B38-424A-83B0-3C3FE2ACB8C9" />
               <EventProvider Id="EventProvider_DMAccXperfGuid" Name="E1A8D70D-11F0-420E-A170-29C6B686342D" />
               <EventProvider Id="EventProvider_DMCmnUtils" Name="0A8E17FD-ED19-4C54-A1E7-5A2829BF507F" />
               <EventProvider Id="EventProvider_DMSvc" Name="8CC7D9C9-09AF-45CA-86CE-4CECF680F2B7" />
               <EventProvider Id="EventProvider_SampledEnrollmentProvider" Name="e74efd1a-b62d-4b83-ab00-66f4a166a2d3" />
               <EventProvider Id="EventProvider_UnsampledEnrollmentProvider" Name="F9E3B648-9AF1-4DC3-9A8E-BF42C0FBCE9A" />
               <EventProvider Id="EventProvider_EnrollmentEtwProvider" Name="9FBF7B95-0697-4935-ADA2-887BE9DF12BC" />
               <EventProvider Id="EventProvider_EDPCleanupTraceLoggingProvider" Name="e42598b4-b399-41cd-a67c-a6b1b6007e07" />
               <EventProvider Id="EventProvider_OmadmClient" Name="0EC685CD-64E4-4375-92AD-4086B6AF5F1D" />
               <EventProvider Id="EventProvider_OmacpClient" Name="FF036693-0480-41DD-AC12-ED3C6A936A5F" />
               <EventProvider Id="EventProvider_OMADMAPI" Name="7D85C2D0-6490-4BB4-BAC1-247D0BD06F10" />
               <EventProvider Id="EventProvider_OmadmPrc" Name="797C5746-634F-4C59-8AE9-93F900670DCC" />
               <EventProvider Id="EventProvider_PolicyManagerXperfGuid" Name="FFDB0CFD-833C-4F16-AD3F-EC4BE3CC1AF5" />
               <EventProvider Id="EventProvider_PushRouterCore" Name="0E316AA7-3B31-4D58-9B8B-10B3B2C0F2ED" />
               <EventProvider Id="EventProvider_PushRouterProxy" Name="83AFAF72-DF00-4584-8F4C-ADED166F72B1" />
               <EventProvider Id="EventProvider_PushRouterAuth" Name="455FEFE7-5B3D-485A-BCBB-D0F09A47D1AE" />
               <EventProvider Id="EventProvider_ResourceMgr" Name="6B865228-DEFA-455A-9E25-27D71E8FE5FA" />
               <EventProvider Id="EventProvider_SCEP" Name="D5A5B540-C580-4DEE-8BB4-185E34AA00C5" />
               <EventProvider Id="EventProvider_SecurityPolicyCSP" Name="F058515F-DBB8-4C0D-9E21-A6BC2C422EAB" />
               <EventProvider Id="EventProvider_UnenrollHook" Name="6222F3F1-237E-4B0F-8D12-C20072D42197" />
               <EventProvider Id="EventProvider_WapXperfGuid" Name="18F2AB69-92B9-47E4-B9DB-B4AC2E4C7115" />
               <EventProvider Id="EventProvider_WMICSP" Name="C37BB754-DC5C-45AD-9D00-A42CFCF137A8" />
               <EventProvider Id="EventProvider_WMIBridge" Name="A76DBA2C-9683-4BA7-8FE4-C82601E117BB" />
               <EventProvider Id="EventProvider_W7NodeProcessor" Name="33466AA0-09A2-4C47-9B7B-1B8A4DC3A9C9" />
               <EventProvider Id="EventProvider_DMClient" Name="36a529a2-7cba-4370-8c3d-d113f552b138" />
               <EventProvider Id="EventProvider_NodeCache" Name="24a7f60e-e0cb-5bdc-99a5-0ba8e8c018bd" />
               <EventProvider Id="EventProvider_MdmPush" Name="6e7d2591-6d94-5b84-02a1-c74c54de1719" />
               <EventProvider Id="EventProvider_MdmEvaluatorTraceProvider" Name="8F453BA5-F19E-531D-071B-72BA1C501406" />
               <EventProvider Id="EventProvider_EdpConfigurationTraceProvider" Name="6BE7190D-DBA0-5E9C-8B69-C5A9AED40FB9" />
               <EventProvider Id="EventProvider_OmaDMApi" Name="86625C04-72E1-4D36-9C86-CA142FD0A946" />
               <EventProvider Id="EventProvider_OmaDMAgent" Name="ACCA0101-AE51-4D60-A32A-552A6B1DEABE" />
               <EventProvider Id="EventProvider_ADMXIngestion" Name="64E05266-27B6-4F6B-AB9E-AB7CC9497089" />
               <EventProvider Id="EventProvider_Dynamo" Name="C15421A9-1A99-474E-9E1B-F16AC98E173D" />
               <EventProvider Id="EventProvider_AADCorePlugin" Name="4DE9BC9C-B27A-43C9-8994-0915F1A5E24F" />
               <EventProvider Id="EventProvider_MDMDiagnostics" Name="bf5f1ee5-5dc0-4836-9f23-889294c42a54" />
               <EventProvider Id="EventProvider_DeclaredConfiguration" Name="5AFBA129-D6B7-4A6F-8FC0-B92EC134C86C" />
               <EventProvider Id="EventProvider_Container" Name="E1235DFE-7622-4B39-810A-4B78D3E48E36" />
               <EventProvider Id="EventProvider_RemoteFind" Name="11838EF3-69E8-4FF0-8116-B2FFDDF289C9" />
               <EventProvider Id="EventProvider_Microsoft-WindowsPhone-OmaDm-Client-Provider" Name="3B9602FF-E09B-4C6C-BC19-1A3DFA8F2250" />
               <EventProvider Id="EventProvider_EnterpriseDesktopAppManagement" Name="16EAA7BB-5B6E-4615-BF44-B8195B5BF873" />
               <EventProvider Id="EventProvider_Microsoft.Windows.EnterpriseModernAppManagement" Name="0e71a49b-ca69-5999-a395-626493eb0cbd" />
               <EventProvider Id="EventProvider_WindowsAttestation" Name="0a611b27-ba1a-4acf-9c91-ea1611e24c38" />
               <EventProvider Id="EventProvider_Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider" Name="3DA494E4-0FE2-415C-B895-FB5265C5C83B" />
               <EventProvider Id="EventProvider_microsoft-windows-tpm-wmi" Name="7d5387b0-cbe0-11da-a94d-0800200c9a66" />
               <EventProvider Id="EventProvider-Microsoft.Tpm.ProvisioningTask" Name="470baa67-2d7f-4c9c-8bf4-b1b3226f7b17"" />
               <EventProvider Id="EventProvider-Microsoft.Tpm.HealthAttestationCSP" Name="a935c211-645a-5f5a-4527-778da45bbba5" />
               <EventProvider Id="EventProvider-Microsoft.Tpm.DebugTracing" Name="3a8d6942-b034-48e2-b314-f69c2b4655a3" />
               <EventProvider 
                    Id="EventProvider_Microsoft.Windows.Security.TokenBroker" 
                    Name="*Microsoft.Windows.Security.TokenBroker" >
                    <Keywords>
                     <Keyword Value="0x0000600000000000"/> 
                       </Keywords>
               </EventProvider>
          </EventProviders>
        </EventCollectorId>
      </Collectors>
    </Profile>
    <Profile Id="MDMTraceLoggingProvider.Verbose.Memory" Name="MDMTraceLoggingProvider" Description="AllMDMTraceLoggingProvider" Base="MDMTraceLoggingProvider.Verbose.File" LoggingMode="Memory" DetailLevel="Verbose" />
    
    <Profile Id="MDMTraceLoggingProvider.Light.Memory" Name="MDMTraceLoggingProvider" Description="AllMDMTraceLoggingProvider" Base="MDMTraceLoggingProvider.Verbose.File" LoggingMode="Memory" DetailLevel="Light" />
    
    <Profile Id="MDMTraceLoggingProvider.Light.File" Name="MDMTraceLoggingProvider" Description="AllMDMTraceLoggingProvider" Base="MDMTraceLoggingProvider.Verbose.File" LoggingMode="File" DetailLevel="Light" />
    
 
  </Profiles>
</WindowsPerformanceRecorder>
'@

    if (!(Test-Path -Path "$env:SystemRoot\Temp\TraceLogs")) {
        New-Item -Path "$env:SystemRoot\Temp\TraceLogs" -ItemType Directory -Force -ErrorAction Stop
    }

    $wprp | Out-File -FilePath "$env:SystemRoot\Temp\TraceLogs\TraceLog.wprp" -Force -Encoding utf8

    wpr.exe -start $env:SystemRoot\Temp\TraceLogs\TraceLog.wprp
    wpr.exe -status
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

Export-TpmRegistry {
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Export TPM Registry" -ForegroundColor Cyan
    $TpmRegistryFile = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-TpmRegistry.reg"
    Write-Host "Exporting TPM Registry to $env:SystemRoot\Temp\$TpmRegistryFile" -ForegroundColor DarkGray
    reg export 'HKLM\SYSTEM\CurrentControlSet\Services\TPM' "$env:SystemRoot\Temp\$TpmRegistryFile" -Force
}
function Start-TPMTest {
    #https://gerhart01.github.io/msdn.microsoft.com/en-us/library/windows/hardware/hh998628.html
    reg add HKLM\System\CurrentControlSet\Control\WMI\Autologger\Tpm /v Start /t REG_DWORD /d 1 /f
    reg add HKLM\System\CurrentControlSet\Control\WMI\Autologger\Tpm /v LogFileMode /t REG_DWORD /d 0x10000004 /f
    reg delete HKLM\System\CurrentControlSet\Control\WMI\Autologger\Tpm /v FileMax  
    reg delete HKLM\System\CurrentControlSet\Control\WMI\Autologger\Tpm /v FileCounter
}
function Stop-TPMTest {
    Change to the log directory: cd %SystemRoot%\System32\LogFiles\WMI
    Stop the logging: logman stop tpm -ets
    reg add HKLM\System\CurrentControlSet\Control\WMI\Autologger\Tpm /v Start /t REG_DWORD /d 0 /f
}
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
        Get-EKCertificates
        Export-TpmRegistry
        Write-Host -ForegroundColor DarkGray '========================================================================='
        Write-Host -ForegroundColor Cyan 'Additional Commands'
        Write-Host -ForegroundColor Gray 'Start-WprLogging'
        Write-Host -ForegroundColor Gray 'Get-WprLoggingStatus'
        Write-Host -ForegroundColor Gray 'Stop-WprLogging'
        Write-Host -ForegroundColor Gray 'Start-TPMTest'
        Write-Host -ForegroundColor Gray 'Stop-TPMTest'
        Start-Sleep -Seconds 3
        explorer.exe "$env:SystemRoot\Temp"
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
        Get-EKCertificates
        Export-TpmRegistry
        Write-Host -ForegroundColor DarkGray '========================================================================='
        Write-Host -ForegroundColor Cyan "Additional Commands"
        Write-Host -ForegroundColor Gray 'Start-WprLogging'
        Write-Host -ForegroundColor Gray 'Get-WprLoggingStatus'
        Write-Host -ForegroundColor Gray 'Stop-WprLogging'
        Write-Host -ForegroundColor Gray 'Start-TPMTest'
        Write-Host -ForegroundColor Gray 'Stop-TPMTest'
        Start-Sleep -Seconds 3
        explorer.exe "$env:SystemRoot\Temp"
    }
    Write-Host -ForegroundColor DarkGray '========================================================================='
    Write-Host -ForegroundColor Green "[+] tpm.osdcloud.com Complete"
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion