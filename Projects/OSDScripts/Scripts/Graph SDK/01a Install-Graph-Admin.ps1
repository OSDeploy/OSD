<#PSScriptInfo
.VERSION 23.6.8.1
.GUID 3780f7a30-92cc-4be2-ba46-6b97d1cd1eb5
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS Microsoft Graph SDK
.LICENSEURI 
.PROJECTURI
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -RunAsAdministrator
<#
.DESCRIPTION
Install the Microsoft Graph PowerShell SDK
.LINK
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
#>
[CmdletBinding()]
param()

if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
}

try {
    Get-InstalledModule Microsoft.Graph -ErrorAction Stop
}
catch {
    Install-Module Microsoft.Graph -Scope AllUsers -Verbose
}
Import-Module Microsoft.Graph
Get-InstalledModule Microsoft.Graph