<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 664dca13-c973-4af0-a08c-21f74ff84966
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS OSDCloud
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/PwshHub
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -RunAsAdministrator
<#
.DESCRIPTION
Creates a new OSDCloud Template using Windows 11 WinRE (Wireless support)
.LINK
https://www.osdcloud.com
#>
[CmdletBinding()]
param()

# Create an OSDCloud Template using the ADK WinPE
New-OSDCloudTemplate -Name 'WinRE'

# Create an OSDCloud Workspace
New-OSDCloudWorkspace -WorkspacePath 'C:\OSDCloudRE'

# Set the default WinPE Wallpaper
Edit-OSDCloudWinPE -UseDefaultWallpaper -CloudDriver *

# Test in Hyper-V
if (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All) {

    # Set OSDCloud VM Defaults
    Set-OSDCloudVMSettings -MemoryStartupGB 6 -ProcessorCount 2 -SwitchName 'Default Switch'
    
    # Test in Hyper-V
    New-OSDCloudVM
}
else {
    Write-Warning -Message 'Hyper-V is not installed.  Skipping VM Test'
    Write-Warning -Message 'Install Hyper-V using the following command and restart your computer:'
    Write-Warning -Message 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart -Verbose'
}