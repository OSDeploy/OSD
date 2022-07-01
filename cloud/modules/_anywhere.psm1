<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
#>
#=================================================

#region Functions
function osdcloud-InstallPackageManagement {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $InstalledModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            Write-Host -ForegroundColor DarkGray 'Install PackageManagement'
            $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
            Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
            $null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
            Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
            $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
            Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
            Import-Module PackageManagement -Force -Scope Global
        }
    }
    else {
        if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
            Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
            Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null
    
            Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
            Import-Module PackageManagement,PowerShellGet -Force -Scope Global
        }
    }
}
function osdcloud-InstallModuleAutopilot {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
    if (-not $InstalledModule) {
        Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune [CurrentUser]'
        Install-Module WindowsAutopilotIntune -Force -Scope CurrentUser
    }
}
function osdcloud-EjectCD {
    [CmdletBinding()]
    param ()   
    (New-Object -ComObject 'Shell.Application').Namespace(17).Items() | Where-Object { $_.Type -eq 'CD Drive' } | ForEach-Object { $_.InvokeVerb('Eject') }
}

function osdcloud-UpdateModuleFilesManually {
    #Custom Testing - Overwrites files in module with updated ones in GitHub
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet($true, $false)]
        $DEVMode = $false
        ) 
    write-host "Manually Updating Several Module Files directly from GitHub" -ForegroundColor Cyan
    $ModulePath = (Get-ChildItem -Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname
    write-host "Updating Files in $ModulePath"
    $OSDCloudGUIDevProjectPath = "Projects\OSDCloudDev"
    $OSDCloudGUIProjectPath = "Projects\OSDCloudGUI"
    $OSDCloudFunctionsPath = "Public\Functions\OSDCloud"
    $GitHubURI = "https://raw.githubusercontent.com/OSDeploy/OSD/master"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIDevProjectPath/MainWindow.ps1" -OutFile "$ModulePath/$OSDCloudGUIDevProjectPath/MainWindow.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIDevProjectPath/MainWindow.xaml" -OutFile "$ModulePath/$OSDCloudGUIDevProjectPath/MainWindow.xaml"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIProjectPath/MainWindow.ps1" -OutFile "$ModulePath/$OSDCloudGUIProjectPath/MainWindow.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIProjectPath/MainWindow.xaml" -OutFile "$ModulePath/$OSDCloudGUIProjectPath/MainWindow.xaml"
    if ($DevMode -eq $true){Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1"}
    else{Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1"}
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/Public/OSDCloud.ps1" -OutFile "$ModulePath/Public/OSDCloud.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/OSD.psd1" -OutFile "$ModulePath/OSD.psd1"
    import-module "$ModulePath/OSD.psd1" -Force
    if ($WindowsPhase -eq 'WinPE') {
        if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\osd"){
            $ModulePath = (Get-ChildItem -Path "C:\Program Files\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname
            write-host "Updating Files in $ModulePath"
            if ($DevMode -eq $true){Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1"}
            else{Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1"}
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/OSD.psd1" -OutFile "$ModulePath/OSD.psd1"
        }
    }
    if (Test-HPIASupport -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
}


function osdcloud-InstallModuleAzAccounts {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Accounts'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzKeyVault {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.KeyVault'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}

function osdcloud-InstallModuleAzResources {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Resources'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzStorage {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Storage'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzureAD {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'AzureAD'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleMSGraphAuthentication {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Microsoft.Graph.Authentication'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleMSGraphDeviceManagement {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Microsoft.Graph.DeviceManagement'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleOSD {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'OSD'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -Force
            Import-Module $PSModuleName -Force
        }
    }
}

function Get-HyperVName {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE'){
        Write-host "Unable to get HyperV Name in WinPE"
    }
    else{
        if (((Get-CimInstance Win32_ComputerSystem).Model -eq "Virtual Machine") -and ((Get-CimInstance Win32_ComputerSystem).Manufacturer -eq "Microsoft Corporation")){
            $HyperVName = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters' -Name "VirtualMachineName" -ErrorAction SilentlyContinue
        }
    return $HyperVName
    }
}

function Set-HyperVName {
    [CmdletBinding()]
    param ()
    $HyperVName = Get-HyperVName
    Write-Output "Renaming Computer to $HyperVName"
    Rename-Computer -NewName $HyperVName -Force 
}
function osdcloud-RestartComputer {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Green 'Complete!'
    Write-Warning 'Device will restart in 30 seconds.  Press Ctrl + C to cancel'
    Start-Sleep -Seconds 30
    Restart-Computer
}
function osdcloud-SetExecutionPolicy {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if ((Get-ExecutionPolicy) -ne 'Bypass') {
            Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy Bypass'
            Set-ExecutionPolicy Bypass -Force
        }
    }
    else {
        if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
            Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy RemoteSigned [CurrentUser]'
            Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
        }
    }
}
function osdcloud-StopComputer {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Green 'Complete!'
    Write-Warning 'Device will shutdown in 30 seconds.  Press Ctrl + C to cancel'
    Start-Sleep -Seconds 30
    Stop-Computer
}

function osdcloud-GetWin11Readiness {

<#
Modified for OSD by @gwblok



Changes
2022.01.28
 - Changed Get-TPM to using Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM
2022.07.01 
 - Modified for OSDCloud

#>

#=============================================================================================================================
#
#
# Script Name:     HardwareReadiness.ps1
# Description:     Verifies the hardware compliance. Return code 0 for success. 
#                  In case of failure, returns non zero error code along with error message.

# This script is not supported under any Microsoft standard support program or service and is distributed under the MIT license

# Copyright (C) 2021 Microsoft Corporation

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#=============================================================================================================================


$exitCode = 0

[int]$MinOSDiskSizeGB = 64
[int]$MinMemoryGB = 4
[Uint32]$MinClockSpeedMHz = 1000
[Uint32]$MinLogicalCores = 2
[Uint16]$RequiredAddressWidth = 64

$PASS_STRING = "PASS"
$FAIL_STRING = "FAIL"
$FAILED_TO_RUN_STRING = "FAILED TO RUN"
$UNDETERMINED_CAPS_STRING = "UNDETERMINED"
$UNDETERMINED_STRING = "Undetermined"
$CAPABLE_STRING = "Capable"
$NOT_CAPABLE_STRING = "Not capable"
$CAPABLE_CAPS_STRING = "CAPABLE"
$NOT_CAPABLE_CAPS_STRING = "NOT CAPABLE"
$STORAGE_STRING = "Storage"
$OS_DISK_SIZE_STRING = "OSDiskSize"
$MEMORY_STRING = "Memory"
$SYSTEM_MEMORY_STRING = "System_Memory"
$GB_UNIT_STRING = "GB"
$TPM_STRING = "TPM"
$TPM_VERSION_STRING = "TPMVersion"
$PROCESSOR_STRING = "Processor"
$SECUREBOOT_STRING = "SecureBoot"
$I7_7820HQ_CPU_STRING = "i7-7820hq CPU"

# 0=name of check, 1=attribute checked, 2=value, 3=PASS/FAIL/UNDETERMINED
$logFormat = '{0}: {1}={2}. {3}; '

# 0=name of check, 1=attribute checked, 2=value, 3=unit of the value, 4=PASS/FAIL/UNDETERMINED
$logFormatWithUnit = '{0}: {1}={2}{3}. {4}; '

# 0=name of check.
$logFormatReturnReason = '{0}, '

# 0=exception.
$logFormatException = '{0}; '

# 0=name of check, 1= attribute checked and its value, 2=PASS/FAIL/UNDETERMINED
$logFormatWithBlob = '{0}: {1}. {2}; '

# return returnCode is -1 when an exception is thrown. 1 if the value does not meet requirements. 0 if successful. -2 default, script didn't run.
$outObject = @{ returnCode = -2; returnResult = $FAILED_TO_RUN_STRING; returnReason = ""; logging = "" }

# NOT CAPABLE(1) state takes precedence over UNDETERMINED(-1) state
function Private:UpdateReturnCode {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(-2, 1)]
        [int] $ReturnCode
    )

    Switch ($ReturnCode) {

        0 {
            if ($outObject.returnCode -eq -2) {
                $outObject.returnCode = $ReturnCode
            }
        }
        1 {
            $outObject.returnCode = $ReturnCode
        }
        -1 {
            if ($outObject.returnCode -ne 1) {
                $outObject.returnCode = $ReturnCode
            }
        }
    }
}

$Source = @"
using Microsoft.Win32;
using System;
using System.Runtime.InteropServices;

    public class CpuFamilyResult
    {
        public bool IsValid { get; set; }
        public string Message { get; set; }
    }

    public class CpuFamily
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct SYSTEM_INFO
        {
            public ushort ProcessorArchitecture;
            ushort Reserved;
            public uint PageSize;
            public IntPtr MinimumApplicationAddress;
            public IntPtr MaximumApplicationAddress;
            public IntPtr ActiveProcessorMask;
            public uint NumberOfProcessors;
            public uint ProcessorType;
            public uint AllocationGranularity;
            public ushort ProcessorLevel;
            public ushort ProcessorRevision;
        }

        [DllImport("kernel32.dll")]
        internal static extern void GetNativeSystemInfo(ref SYSTEM_INFO lpSystemInfo);

        public enum ProcessorFeature : uint
        {
            ARM_SUPPORTED_INSTRUCTIONS = 34
        }

        [DllImport("kernel32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool IsProcessorFeaturePresent(ProcessorFeature processorFeature);

        private const ushort PROCESSOR_ARCHITECTURE_X86 = 0;
        private const ushort PROCESSOR_ARCHITECTURE_ARM64 = 12;
        private const ushort PROCESSOR_ARCHITECTURE_X64 = 9;

        private const string INTEL_MANUFACTURER = "GenuineIntel";
        private const string AMD_MANUFACTURER = "AuthenticAMD";
        private const string QUALCOMM_MANUFACTURER = "Qualcomm Technologies Inc";

        public static CpuFamilyResult Validate(string manufacturer, ushort processorArchitecture)
        {
            CpuFamilyResult cpuFamilyResult = new CpuFamilyResult();

            if (string.IsNullOrWhiteSpace(manufacturer))
            {
                cpuFamilyResult.IsValid = false;
                cpuFamilyResult.Message = "Manufacturer is null or empty";
                return cpuFamilyResult;
            }

            string registryPath = "HKEY_LOCAL_MACHINE\\Hardware\\Description\\System\\CentralProcessor\\0";
            SYSTEM_INFO sysInfo = new SYSTEM_INFO();
            GetNativeSystemInfo(ref sysInfo);

            switch (processorArchitecture)
            {
                case PROCESSOR_ARCHITECTURE_ARM64:

                    if (manufacturer.Equals(QUALCOMM_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        bool isArmv81Supported = IsProcessorFeaturePresent(ProcessorFeature.ARM_SUPPORTED_INSTRUCTIONS);

                        if (!isArmv81Supported)
                        {
                            string registryName = "CP 4030";
                            long registryValue = (long)Registry.GetValue(registryPath, registryName, -1);
                            long atomicResult = (registryValue >> 20) & 0xF;

                            if (atomicResult >= 2)
                            {
                                isArmv81Supported = true;
                            }
                        }

                        cpuFamilyResult.IsValid = isArmv81Supported;
                        cpuFamilyResult.Message = isArmv81Supported ? "" : "Processor does not implement ARM v8.1 atomic instruction";
                    }
                    else
                    {
                        cpuFamilyResult.IsValid = false;
                        cpuFamilyResult.Message = "The processor isn't currently supported for Windows 11";
                    }

                    break;

                case PROCESSOR_ARCHITECTURE_X64:
                case PROCESSOR_ARCHITECTURE_X86:

                    int cpuFamily = sysInfo.ProcessorLevel;
                    int cpuModel = (sysInfo.ProcessorRevision >> 8) & 0xFF;
                    int cpuStepping = sysInfo.ProcessorRevision & 0xFF;

                    if (manufacturer.Equals(INTEL_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        try
                        {
                            cpuFamilyResult.IsValid = true;
                            cpuFamilyResult.Message = "";

                            if (cpuFamily >= 6 && cpuModel <= 95 && !(cpuFamily == 6 && cpuModel == 85))
                            {
                                cpuFamilyResult.IsValid = false;
                                cpuFamilyResult.Message = "";
                            }
                            else if (cpuFamily == 6 && (cpuModel == 142 || cpuModel == 158) && cpuStepping == 9)
                            {
                                string registryName = "Platform Specific Field 1";
                                int registryValue = (int)Registry.GetValue(registryPath, registryName, -1);

                                if ((cpuModel == 142 && registryValue != 16) || (cpuModel == 158 && registryValue != 8))
                                {
                                    cpuFamilyResult.IsValid = false;
                                }
                                cpuFamilyResult.Message = "PlatformId " + registryValue;
                            }
                        }
                        catch (Exception ex)
                        {
                            cpuFamilyResult.IsValid = false;
                            cpuFamilyResult.Message = "Exception:" + ex.GetType().Name;
                        }
                    }
                    else if (manufacturer.Equals(AMD_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        cpuFamilyResult.IsValid = true;
                        cpuFamilyResult.Message = "";

                        if (cpuFamily < 23 || (cpuFamily == 23 && (cpuModel == 1 || cpuModel == 17)))
                        {
                            cpuFamilyResult.IsValid = false;
                        }
                    }
                    else
                    {
                        cpuFamilyResult.IsValid = false;
                        cpuFamilyResult.Message = "Unsupported Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                    }

                    break;

                default:
                    cpuFamilyResult.IsValid = false;
                    cpuFamilyResult.Message = "Unsupported CPU category. Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                    break;
            }
            return cpuFamilyResult;
        }
    }
"@

# Storage
try {

    if ($InWinPE){
        $osDrive = Get-Disk -Number 0
        $osDriveSize = $osDrive | Select-Object @{Name = "SizeGB"; Expression = { $_.Size / 1GB -as [int] } } 
        }
    else {
        $osDrive = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property SystemDrive
        $osDriveSize = Get-WmiObject -Class Win32_LogicalDisk -filter "DeviceID='$($osDrive.SystemDrive)'" | Select-Object @{Name = "SizeGB"; Expression = { $_.Size / 1GB -as [int] } } 
        }

    if ($null -eq $osDriveSize) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $STORAGE_STRING
        $outObject.logging += $logFormatWithBlob -f $STORAGE_STRING, "Storage is null", $FAIL_STRING
        $exitCode = 1
        $HR_Storage = $FAIL_STRING
    }
    elseif ($osDriveSize.SizeGB -lt $MinOSDiskSizeGB) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $STORAGE_STRING
        $outObject.logging += $logFormatWithUnit -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, ($osDriveSize.SizeGB), $GB_UNIT_STRING, $FAIL_STRING
        $exitCode = 1
        $HR_Storage = $FAIL_STRING
    }
    else {
        $outObject.logging += $logFormatWithUnit -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, ($osDriveSize.SizeGB), $GB_UNIT_STRING, $PASS_STRING
        UpdateReturnCode -ReturnCode 0
        $HR_Storage = $PASS_STRING
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_Storage = $FAIL_STRING
}

# Memory (bytes)
try {
    $memory = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object @{Name = "SizeGB"; Expression = { $_.Sum / 1GB -as [int] } }

    if ($null -eq $memory) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $MEMORY_STRING
        $outObject.logging += $logFormatWithBlob -f $MEMORY_STRING, "Memory is null", $FAIL_STRING
        $exitCode = 1
        $HR_Memory = $FAIL_STRING

    }
    elseif ($memory.SizeGB -lt $MinMemoryGB) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $MEMORY_STRING
        $outObject.logging += $logFormatWithUnit -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, ($memory.SizeGB), $GB_UNIT_STRING, $FAIL_STRING
        $exitCode = 1
        $HR_Memory = $FAIL_STRING

    }
    else {
        $outObject.logging += $logFormatWithUnit -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, ($memory.SizeGB), $GB_UNIT_STRING, $PASS_STRING
        UpdateReturnCode -ReturnCode 0
        $HR_Memory = $PASS_STRING
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_Memory = $FAIL_STRING
}

# TPM
try {
    if ($InWinPE){
        $tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM 
        }
    else {
        $tpm = Get-Tpm
        }
    
    #$tpm = Get-Tpm
    
    if ($null -eq $tpm) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
        $outObject.logging += $logFormatWithBlob -f $TPM_STRING, "TPM is null", $FAIL_STRING
        $exitCode = 1
        $HR_TPM = $FAIL_STRING
    }
    elseif ($tpm.IsOwned_InitialValue -or $tpm.TpmPresent) {
        $tpmVersion = Get-WmiObject -Class Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm | Select-Object -Property SpecVersion

        if ($null -eq $tpmVersion.SpecVersion) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, "null", $FAIL_STRING
            $exitCode = 1
            $HR_TPM = $FAIL_STRING
        }

        $majorVersion = $tpmVersion.SpecVersion.Split(",")[0] -as [int]
        if ($majorVersion -lt 2) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpmVersion.SpecVersion), $FAIL_STRING
            $exitCode = 1
            $HR_TPM = $FAIL_STRING
        }
        else {
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpmVersion.SpecVersion), $PASS_STRING
            UpdateReturnCode -ReturnCode 0
            $HR_TPM = $PASS_STRING
        }
    }
    else {
        if ($tpm.GetType().Name -eq "String") {
            UpdateReturnCode -ReturnCode -1
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
            $outObject.logging += $logFormatException -f $tpm
        }
        else {
            UpdateReturnCode -ReturnCode  1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            if ($InWinPE){
                $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, "NA", $FAIL_STRING
                }
            else {                
                $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpm.TpmPresent), $FAIL_STRING
                }
            $HR_TPM = $FAIL_STRING
        }
        $exitCode = 1
        $HR_TPM = $FAIL_STRING
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_TPM = $FAIL_STRING
}

# CPU Details

try {
    $cpuDetails = @(Get-WmiObject -Class Win32_Processor)[0]

    if ($null -eq $cpuDetails) {
        UpdateReturnCode -ReturnCode 1
        $exitCode = 1
        $outObject.returnReason += $logFormatReturnReason -f $PROCESSOR_STRING
        $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, "CpuDetails is null", $FAIL_STRING
        $HR_CPU = $FAIL_STRING
    }
    else {
        $processorCheckFailed = $false

        # AddressWidth
        if ($null -eq $cpuDetails.AddressWidth -or $cpuDetails.AddressWidth -ne $RequiredAddressWidth) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
            $HR_CPU = $FAIL_STRING
        }

        # ClockSpeed is in MHz
        if ($null -eq $cpuDetails.MaxClockSpeed -or $cpuDetails.MaxClockSpeed -le $MinClockSpeedMHz) {
            UpdateReturnCode -ReturnCode 1;
            $processorCheckFailed = $true
            $exitCode = 1
            $HR_CPU = $FAIL_STRING
        }

        # Number of Logical Cores
        if ($null -eq $cpuDetails.NumberOfLogicalProcessors -or $cpuDetails.NumberOfLogicalProcessors -lt $MinLogicalCores) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
            $HR_CPU = $FAIL_STRING
        }

        # CPU Family
        Add-Type -TypeDefinition $Source
        $cpuFamilyResult = [CpuFamily]::Validate([String]$cpuDetails.Manufacturer, [uint16]$cpuDetails.Architecture)

        $cpuDetailsLog = "{AddressWidth=$($cpuDetails.AddressWidth); MaxClockSpeed=$($cpuDetails.MaxClockSpeed); NumberOfLogicalCores=$($cpuDetails.NumberOfLogicalProcessors); Manufacturer=$($cpuDetails.Manufacturer); Caption=$($cpuDetails.Caption); $($cpuFamilyResult.Message)}"

        if (!$cpuFamilyResult.IsValid) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
            $HR_CPU = $FAIL_STRING
        }

        if ($processorCheckFailed) {
            $outObject.returnReason += $logFormatReturnReason -f $PROCESSOR_STRING
            $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, ($cpuDetailsLog), $FAIL_STRING
            $HR_CPU = $FAIL_STRING
        }
        else {
            $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, ($cpuDetailsLog), $PASS_STRING
            UpdateReturnCode -ReturnCode 0
            $HR_CPU = $PASS_STRING
        }
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $PROCESSOR_STRING, $PROCESSOR_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_CPU = $FAIL_STRING
}

# SecureBoot
try {
    $isSecureBootEnabled = Confirm-SecureBootUEFI
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $CAPABLE_STRING, $PASS_STRING
    UpdateReturnCode -ReturnCode 0
    $HR_SecureBoot = $PASS_STRING
}
catch [System.PlatformNotSupportedException] {
    # PlatformNotSupportedException "Cmdlet not supported on this platform." - SecureBoot is not supported or is non-UEFI computer.
    UpdateReturnCode -ReturnCode 1
    $outObject.returnReason += $logFormatReturnReason -f $SECUREBOOT_STRING
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $NOT_CAPABLE_STRING, $FAIL_STRING
    $exitCode = 1
    $HR_SecureBoot = $FAIL_STRING
}
catch [System.UnauthorizedAccessException] {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_SecureBoot = $FAIL_STRING
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
    $HR_SecureBoot = $FAIL_STRING
}

# i7-7820hq CPU
try {
    $supportedDevices = @('surface studio 2', 'precision 5520')
    $systemInfo = @(Get-WmiObject -Class Win32_ComputerSystem)[0]

    if ($null -ne $cpuDetails) {
        if ($cpuDetails.Name -match 'i7-7820hq cpu @ 2.90ghz'){
            $modelOrSKUCheckLog = $systemInfo.Model.Trim()
            if ($supportedDevices -contains $modelOrSKUCheckLog){
                $outObject.logging += $logFormatWithBlob -f $I7_7820HQ_CPU_STRING, $modelOrSKUCheckLog, $PASS_STRING
                $outObject.returnCode = 0
                $exitCode = 0
            }
        }
    }
}
catch {
    if ($outObject.returnCode -ne 0){
        UpdateReturnCode -ReturnCode -1
        $outObject.logging += $logFormatWithBlob -f $I7_7820HQ_CPU_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
        $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
        $exitCode = 1
    }
}

Switch ($outObject.returnCode) {

    0 { $outObject.returnResult = $CAPABLE_CAPS_STRING }
    1 { $outObject.returnResult = $NOT_CAPABLE_CAPS_STRING }
    -1 { $outObject.returnResult = $UNDETERMINED_CAPS_STRING }
    -2 { $outObject.returnResult = $FAILED_TO_RUN_STRING }
}

$Global:Readiness = $null
$Global:Readiness = [ordered]@{
Return = $null
Reason = $null
SecureBoot = $null
CPU = $null
TPM = $null
Memory = $null
Storage = $null
}


    #Write-Output "HR_ReturnResult = $($outObject.returnResult)"
    $Global:Readiness.Return = $outObject.returnResult
    if ($outObject.returnReason)
        {
        if ($outObject.returnResult -eq $NOT_CAPABLE_CAPS_STRING){
            $Reason = $outObject.returnReason
            $Reason = $Reason.Substring(0,$Reason.Length-2)
        }
        else {$Reason = $outObject.returnReason}
        #Write-Output "HR_ReturnReason = $($outObject.returnReason)"
        $Global:Readiness.Reason = $Reason 
    }
    #Write-Output "HR_SecureBoot = $HR_SecureBoot"
    $Global:Readiness.SecureBoot = $HR_SecureBoot
    #Write-Output "HR_CPU = $HR_CPU"
    $Global:Readiness.CPU = $HR_CPU
    #Write-Output "HR_TPM = $HR_TPM"
    $Global:Readiness.TPM = $HR_TPM
    #Write-Output "HR_Memory = $HR_Memory"
    $Global:Readiness.Memory = $HR_Memory
    #Write-Output "HR_Storage = $HR_Storage"
    $Global:Readiness.Storage= $HR_Storage

    return $Global:Readiness
    


$outObject | Out-File $env:TEMP\Win11Readiness.txt
}
#endregion
#=================================================
