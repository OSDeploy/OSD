<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 874c7a14-b050-4950-a1ef-cb70a0d60061
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

if ($env:SystemDrive -eq 'X:') {
    # Clears all Local Disks.  Prompts for Confirmation
    Clear-LocalDisk -Force -ErrorAction Stop
}