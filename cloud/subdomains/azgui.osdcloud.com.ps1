<#PSScriptInfo
.VERSION 22.9.13.1
.GUID aa123d2c-3cd3-4ef4-91f0-0c2139473991
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
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri azgui.osdcloud.com)
This is abbreviated as
powershell iex (irm azgui.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at azgui.osdcloud.com
.DESCRIPTION
    PSCloudScript at azgui.osdcloud.com
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/azgui.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm azgui.osdcloud.com)
#>
[CmdletBinding()]
param()
#=================================================
#Script Information
$ScriptName = 'azgui.osdcloud.com'
$ScriptVersion = '22.9.13.1'
#TODO: Exclude Windows Images smaller than 3GB
#=================================================
#region Initialize

#Start the Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Determine the proper Windows environment
if ($env:SystemDrive -eq 'X:') {$WindowsPhase = 'WinPE'}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

#Finish initialization
Write-Host -ForegroundColor DarkGray "$ScriptName $ScriptVersion $WindowsPhase"

#Load OSDCloud Functions
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)

#endregion
#=================================================
#region WinPE
if ($WindowsPhase -eq 'WinPE') {
    osdcloud-StartWinPE -OSDCloud
    Connect-OSDCloudAzure
    Get-OSDCloudAzureResources
    #Stop the startup Transcript.  OSDCloud will create its own
    $null = Stop-Transcript -ErrorAction Ignore
    Start-OSDCloudAzure
}
#endregion
#=================================================
#region Specialize
if ($WindowsPhase -eq 'Specialize') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region OOBE
if ($WindowsPhase -eq 'OOBE') {
    osdcloud-StartOOBE -Display -Language -DateTime -Autopilot -KeyVault
    Connect-OSDCloudAzure
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region Windows
if ($WindowsPhase -eq 'Windows') {
    Connect-OSDCloudAzure
    Get-OSDCloudAzureResources
    $null = Stop-Transcript -ErrorAction Ignore
    Start-OSDCloudAzure
}
#endregion
#=================================================