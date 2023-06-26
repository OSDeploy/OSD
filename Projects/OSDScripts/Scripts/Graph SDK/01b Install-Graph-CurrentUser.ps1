<#PSScriptInfo
.VERSION 23.6.8.1
.GUID 46c5a7db-7ef1-44e7-b782-bd320325627c
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
<#
.DESCRIPTION
Install the Microsoft Graph PowerShell SDK
.LINK
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
#>
[CmdletBinding()]
param()

if ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'Restricted') {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

try {
    Get-InstalledModule Microsoft.Graph -ErrorAction Stop
}
catch {
    Install-Module Microsoft.Graph -Scope CurrentUser -Verbose
}
Import-Module Microsoft.Graph
Get-InstalledModule Microsoft.Graph