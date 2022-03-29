<#PSScriptInfo
.VERSION 22.3.28.1
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
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/hash.ps1')
This is abbreviated as
powershell iex (irm raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/hash.ps1)
#>
<#
.SYNOPSIS
    PSCloudScript at go.osdcloud.com/hash
.DESCRIPTION
    PSCloudScript at go.osdcloud.com/hash
.NOTES
    Version 22.3.28.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/hash.ps1
.EXAMPLE
    powershell iex (irm go.osdcloud.com/hash)
#>
if ($env:SystemDrive -eq 'X:') {
    Write-Warning "This script cannot be run from WinPE"
}
else {
    $bad = $false
    $session = New-CimSession
    $serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
    $devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
    if ($devDetail) {
        $hash = $devDetail.DeviceHardwareData
    }
    else {
        $bad = $true
        $hash = ""
    }

    if ($bad) {
        Write-Error -Message "Unable to retrieve device hardware data (hash) from computer $comp" -Category DeviceError
    }
    else {
        $hash
    }
    Remove-CimSession $session
}