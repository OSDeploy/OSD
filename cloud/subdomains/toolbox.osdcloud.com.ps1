<#PSScriptInfo
.VERSION 23.5.25.1
.GUID e3d1ff59-7fd0-4615-9016-ca081344a592
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2023 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri toolbox.osdcloud.com)
This is abbreviated as
powershell iex (irm toolbox.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at toolbox.osdcloud.com
.DESCRIPTION
    PSCloudScript at toolbox.osdcloud.com
.NOTES
    Version 23.5.25.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/toolbox.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm toolbox.osdcloud.com)
#>
[CmdletBinding()]
param()
#=================================================
#Script Information
$ScriptName = 'toolbox.osdcloud.com'
$ScriptVersion = '23.5.25.1'
#=================================================
#region Initialize

#Start the Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Toolbox.log"
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

$OSDPadParams = @{
    Brand           = "OSDCloud Toolbox - $RepoFolder"
    RepoOwner       = 'OSDeploy'
    RepoName        = 'OSDCloudToolbox'
    RepoFolder      = $WindowsPhase
}
Start-OSDPad @OSDPadParams

#Stop the startup Transcript
$null = Stop-Transcript -ErrorAction Ignore