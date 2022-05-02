<#PSScriptInfo
.VERSION 22.5.1.1
.GUID c480a6f6-f482-45af-9ba6-28b2a409101d
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdeploy.com
.COPYRIGHT (c) 2022 David Segura osdeploy.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri 'https://go.osdcloud.com/hash')
This is abbreviated as
powershell iex (irm go.osdcloud.com/hash)
#>
<#
.SYNOPSIS
    PSCloudScript at go.osdcloud.com/hash
.DESCRIPTION
    PSCloudScript at go.osdcloud.com/hash
.NOTES
    Version 22.5.1.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/examples/hash.ps1
.EXAMPLE
    powershell iex (irm go.osdcloud.com/hash)
#>
if ($env:SystemDrive -eq 'X:') {
    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) go.osdcloud.com/hash cannot be run from WinPE"
}
elseif (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) go.osdcloud.com/hash requires elevated Admin Rights"
}
else {
    $TempSession = New-CimSession
    $Global:serialNumber = (Get-CimInstance -CimSession $TempSession -Class Win32_BIOS).SerialNumber
    Write-Verbose -Verbose 'The device serial number is stored in the Global variable $Global:serialNumber'
    $devDetail = (Get-CimInstance -CimSession $TempSession -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
    if ($devDetail) {
        $Global:hardwareIdentifier = $devDetail.DeviceHardwareData
        Write-Verbose -Verbose 'The device hardware hash is stored in the Global variable $Global:hardwareIdentifier'
        $Global:hardwareIdentifier
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) go.osdcloud.com/hash is unable to retrieve device hardware data (hash) from computer"
    }

    Remove-CimSession $TempSession
    Remove-Variable -Name devDetail,TempSession
}