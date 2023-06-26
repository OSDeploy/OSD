<#PSScriptInfo
.VERSION 23.6.1.1
.GUID b38c7c7f-f8a5-4ea0-9828-9a5fbb94c25f
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS OSD OSDCloud Hyper-V
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/PwshHub
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator
<#
.DESCRIPTION
Sets New-OSDCloudVM defaults
#>
[CmdletBinding()]
param()

# This is how to set your Hyper-V VM defaults
if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -eq 'Enabled') {
    Set-OSDCloudVMSettings -MemoryStartupGB 10 -ProcessorCount 2 -SwitchName 'Default Switch'
}