<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 5eadea57-4339-47fb-ac29-67d52128335e
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS WinPE
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
Clears the Local Disk
#>
[CmdletBinding()]
param()

if ((Get-MyComputerModel) -match 'Virtual') {
    Set-DisRes 1440
}