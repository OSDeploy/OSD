<#PSScriptInfo
.VERSION 22.3.25.2
.GUID e9ff19c4-655f-40c9-b0d9-6aa4542b3342
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
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri bh.osdcloud.com)
This is abbreviated as
powershell iex(irm bh.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at bh.osdcloud.com
.DESCRIPTION
    PSCloudScript at bh.osdcloud.com
.NOTES
    Version 22.3.25.2
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/company.ps1
.EXAMPLE
    powershell iex(irm bh.osdcloud.com)
#>
[CmdletBinding()]
param()
#=================================================
#   Initialize
#=================================================
Write-Host -ForegroundColor DarkGray "bh.osdcloud.com 22.3.25.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

if ($env:SystemDrive -eq 'X:') {
    $OSDCloudPhase = 'WinPE'
    Start-WinPE -OSDCloud
    #Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    #Write-Host -ForegroundColor Cyan "Start-OSDCloud or Start-OSDCloudGUI can be run in the new PowerShell session"
}
elseif ($env:UserName -eq 'defaultuser0') {
    $OSDCloudPhase = 'OOBE'
    Start-OOBE -Display -Language -DateTime -Autopilot -KeyVault
}
else {
    $OSDCloudPhase = 'WinPE'
}
#=================================================
#  BH WinPE
#=================================================
if ($OSDCloudPhase -eq 'WinPE') {
    Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 21H2 -OSEdition Enterprise -OSLicense Volume -SkipAutopilot -SkipODT -Restart
}
#=================================================
#   BH OOBE
#=================================================
if ($OSDCloudPhase -eq 'OOBE') {
    $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot' 
    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
    }
    else {
        $oobeRegisterAutopilotCommand = 'Get-WindowsAutopilotInfo -Online -GroupTag Enterprise -Assign'
        $oobeRegisterAutopilotProcess = Step-oobeRegisterAutopilot -Command $oobeRegisterAutopilotCommand;Start-Sleep -Seconds 30
    }
    RemoveAppx -Basic
    Rsat -Basic
    NetFX
    UpdateDrivers
    UpdateWindows
    #& 'C:\Program Files\Windows Defender\MpCmdRun.exe' -removedefinitions -dynamicsignatures
    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -signatureupdate
    if ($oobeRegisterAutopilotProcess) {
        Write-Host -ForegroundColor Cyan 'Waiting for Autopilot Registration to complete'
        if (Get-Process -Id $oobeRegisterAutopilotProcess.Id -ErrorAction Ignore)
        {
            Wait-Process -Id $oobeRegisterAutopilotProcess.Id
        }
    }
    Step-oobeRestartComputer
}
#=================================================
#   Complete
#=================================================
$null = Stop-Transcript
#=================================================