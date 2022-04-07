<#PSScriptInfo
.VERSION 22.4.1.1
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
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri go.osdcloud.com/companydemo)
This is abbreviated as
powershell iex(irm go.osdcloud.com/companydemo)
#>
<#
.SYNOPSIS
    PSCloudScript at go.osdcloud.com/companydemo
.DESCRIPTION
    PSCloudScript at go.osdcloud.com/companydemo
.NOTES
    Version 22.4.1.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/company.ps1
.EXAMPLE
    powershell iex (irm go.osdcloud.com/companydemo)
#>
[CmdletBinding()]
param()

#region Initialize
Write-Host -ForegroundColor DarkGray "go.osdcloud.com/companydemo 22.4.1.1"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
#endregion

#region WinPE
if ($env:SystemDrive -eq 'X:') {
    osdcloud-StartWinPE -OSDCloud -KeyVault
    #Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    #Write-Host -ForegroundColor Cyan "Start-OSDCloud or Start-OSDCloudGUI can be run in the new PowerShell session"
    $null = Stop-Transcript
    Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 21H2 -OSEdition Enterprise -OSLicense Volume -SkipAutopilot -SkipODT -Restart
}
#endregion

#region OOBE
if ($env:UserName -eq 'defaultuser0') {
    osdcloud-StartOOBE -Display -Language -DateTime -Autopilot -KeyVault
    $null = Stop-Transcript
    
    $TestAutopilotProfile = osdcloud-TestAutopilotProfile
    if ($TestAutopilotProfile -eq $true) {
        osdcloud-ShowAutopilotProfile
    }
    elseif ($TestAutopilotProfile -eq $false) {
        $AutopilotRegisterCommand = 'Get-WindowsAutopilotInfo -Online -GroupTag Enterprise -Assign'
        $AutopilotRegisterProcess = osdcloud-AutopilotRegisterCommand -Command $AutopilotRegisterCommand;Start-Sleep -Seconds 30
    }
    else {
        Write-Warning 'Unable to determine if device is Autopilot registered'
    }
    RemoveAppx -Basic
    Rsat -Basic
    NetFX
    UpdateDrivers
    UpdateWindows
    osdcloud-UpdateDefender
    if ($AutopilotRegisterProcess) {
        Write-Host -ForegroundColor Cyan 'Waiting for Autopilot Registration to complete'
        #$AutopilotRegisterProcess.WaitForExit()
        if (Get-Process -Id $AutopilotRegisterProcess.Id -ErrorAction Ignore) {
            Wait-Process -Id $AutopilotRegisterProcess.Id
        }
    }
    osdcloud-RestartComputer
}
#endregion

#region FullOS
if (($env:SystemDrive -ne 'X:') -and ($env:UserName -ne 'defaultuser0')) {
    #Do something
    $null = Stop-Transcript
}
#endregion