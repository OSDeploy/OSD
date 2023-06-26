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
#Requires -Modules AzureRM.Netcore
#Requires -Modules @{ ModuleName="AzureRM.Netcore"; ModuleVersion="0.12.0" }
#Requires -Modules @{ ModuleName="AzureRM.Netcore"; MaximumVersion="0.12.0" }
#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Core
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator
#Requires -Version 5.1
#Requires -Assembly path\to\foo.dll
#Requires -Assembly "System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
<#
.DESCRIPTION
Some Defaults
#>
[CmdletBinding()]
param()