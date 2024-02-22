<#PSScriptInfo
.VERSION 22.9.13.1
.GUID 7a3671f6-485b-443e-8e86-b60fdcea1419
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2022 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
This is abbreviated as
powershell iex (irm functions.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at functions.osdcloud.com
.DESCRIPTION
    PSCloudScript at functions.osdcloud.com
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/functions.ps1
.EXAMPLE
    powershell iex (irm functions.osdcloud.com)
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/functions.ps1')
#>
[CmdletBinding()]
param()
$ScriptName = 'functions.osdcloud.com'
$ScriptVersion = '23.6.10.1'

#region Initialize
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
#endregion

#region Transport Layer Security (TLS) 1.2
#Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
#endregion

#region Gary Blok
function Test-HPIASupport {
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $Platforms = $XML.ImagePal.Platform.SystemID
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    if ($MachinePlatform -in $Platforms){$HPIASupport = $true}
    else {$HPIASupport = $false}
    return $HPIASupport
    }

function Test-DCUSupport {
    $SystemSKUNumber = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
    $CabPathIndex = "$env:temp\DellCabDownloads\CatalogIndexPC.cab"
    $DellCabExtractPath = "$env:temp\DellCabDownloads\DellCabExtract"
    # Pull down Dell XML CAB used in Dell Command Update ,extract and Load
    if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
    Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -ErrorAction SilentlyContinue
    New-Item -Path $DellCabExtractPath -ItemType Directory -Force | Out-Null
    $Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml
    [xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -ErrorAction SilentlyContinue
    #Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
    $XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
    if ($XMLModel){$DCUSupportedDevice = $true}
    else {$DCUSupportedDevice = $false}
    Return $DCUSupportedDevice
    }
    


$Manufacturer = (Get-CimInstance -Class:Win32_ComputerSystem).Manufacturer
$Model = (Get-CimInstance -Class:Win32_ComputerSystem).Model
if ($Manufacturer -match "HP" -or $Manufacturer -match "Hewlett-Packard"){
    $Manufacturer = "HP"
    $HPEnterprise = Test-HPIASupport
}
if ($Manufacturer -match "Dell"){
    $Manufacturer = "Dell"
    $DellEnterprise = Test-DCUSupport
}
#endregion

#region Load Modules
if ($WindowsPhase -eq 'WinPE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-winpe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-winpe-startup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
    }
    if ($DellEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
    }
}
if ($WindowsPhase -eq 'OOBE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-oobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/ne-winpe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-oobe-startup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
    }
    if ($DellEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
    }
}
if ($WindowsPhase -eq 'Specialize') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    if ($HPEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
    }
    if ($DellEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
    }
}
if ($WindowsPhase -eq 'Windows') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/ne-winpe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
    }
    if ($DellEnterprise -eq $true) {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
    }
}
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


#region PowerShell Prompt
<#
Since these functions are temporarily loaded, the PowerShell Prompt is changed to make it visual if the functions are loaded or not
[OSDCloud]: PS C:\>

You can read more about how to make the change here
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1
#>
function Prompt {
    $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
    else { "[OSDCloud]: " }
    ) + 'PS ' + $(Get-Location) +
    $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
#endregion