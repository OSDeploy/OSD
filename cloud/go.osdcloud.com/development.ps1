<#PSScriptInfo
.VERSION 22.9.13.1
.GUID ea8ddb28-f77d-4977-a49f-4ff35b752d83
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
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri go.osdcloud.com/development)
This is abbreviated as
powershell iex(irm go.osdcloud.com/development)
#>
<#
.SYNOPSIS
    PSCloudScript at go.osdcloud.com/development
.DESCRIPTION
    PSCloudScript at go.osdcloud.com/development
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/tasksequences/development.ps1
.EXAMPLE
    powershell iex (irm go.osdcloud.com/development)
#>
[CmdletBinding()]
param()
#=================================================
#Script Information
$ScriptName = 'go.osdcloud.com/development'
$ScriptVersion = '22.9.13.1'
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

    #Process OSDCloud startup and load Azure KeyVault dependencies
    osdcloud-StartWinPE -OSDCloud -KeyVault

    #Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    #Write-Host -ForegroundColor Cyan "Start-OSDCloud or Start-OSDCloudGUI can be run in the new PowerShell session"
    #Stop the startup Transcript.  OSDCloud will create its own
    $null = Stop-Transcript -ErrorAction Ignore

    #Start OSDCloud and pass all the parameters except the Language to allow for prompting
    Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 21H2 -OSEdition Development -OSActivation Volume -SkipAutopilot -SkipODT -Restart
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

    #Load everything needed to run AutoPilot and Azure KeyVault
    osdcloud-StartOOBE -Display -Language -DateTime -Autopilot -KeyVault

    #Get Autopilot information from the device
    $TestAutopilotProfile = osdcloud-TestAutopilotProfile

    #If the device has an Autopilot Profile
    if ($TestAutopilotProfile -eq $true) {
        #osdcloud-ShowAutopilotProfile
    }
    #If not, need to register the device using the Development GroupTag and Assign it
    elseif ($TestAutopilotProfile -eq $false) {
        $AutopilotRegisterCommand = 'Get-WindowsAutopilotInfo -Online -GroupTag Development -Assign'
        $AutopilotRegisterProcess = osdcloud-AutopilotRegisterCommand -Command $AutopilotRegisterCommand;Start-Sleep -Seconds 30
    }
    #Or maybe we just can't figure it out
    else {
        Write-Warning 'Unable to determine if device is Autopilot registered'
    }
    osdcloud-RemoveAppx -Basic
    osdcloud-Rsat -Basic
    osdcloud-NetFX
    osdcloud-UpdateDrivers
    osdcloud-UpdateWindows
    osdcloud-UpdateDefender
    if ($AutopilotRegisterProcess) {
        Write-Host -ForegroundColor Cyan 'Waiting for Autopilot Registration to complete'
        #$AutopilotRegisterProcess.WaitForExit()
        if (Get-Process -Id $AutopilotRegisterProcess.Id -ErrorAction Ignore) {
            Wait-Process -Id $AutopilotRegisterProcess.Id
        }
    }
    $null = Stop-Transcript -ErrorAction Ignore
    osdcloud-RestartComputer
}
#endregion
#=================================================
#region Windows
if ($WindowsPhase -eq 'Windows') {

    #Load OSD and Azure stuff
    osdcloud-SetExecutionPolicy
    osdcloud-InstallPackageManagement
    osdcloud-InstallModuleKeyVault
    osdcloud-InstallPowerShellModule -Name OSD
    osdcloud-InstallPowerShellModule -Name 'AzureAD'
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================