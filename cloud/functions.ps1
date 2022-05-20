<#PSScriptInfo
.VERSION 22.5.19.1
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
    Version 22.5.19.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/functions.ps1
.EXAMPLE
    powershell iex (irm functions.osdcloud.com)
#>
#=================================================
#Script Information
$ScriptName = 'functions.osdcloud.com'
$ScriptVersion = '22.5.19.1'
#=================================================
#region Initialize Functions
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Determine the proper Windows environment
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

#Finish Initialization
Write-Host -ForegroundColor DarkGray "$ScriptName $ScriptVersion $WindowsPhase"

if ($WindowsPhase -eq 'WinPE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpestartup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloud.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1') #Development
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
}
if ($WindowsPhase -eq 'OOBE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobestartup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1') #Development
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
}
if ($WindowsPhase -eq 'Windows') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloud.psm1') #Only for testing
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1') #Only for testing
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1') #Development
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
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
#=================================================