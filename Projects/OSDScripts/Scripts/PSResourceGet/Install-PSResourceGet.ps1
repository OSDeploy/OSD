<#PSScriptInfo
.VERSION 23.6.9.1
.GUID f2a7a989-2955-46ef-973d-b979ed892b9b
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS PSResourceGet
.LICENSEURI 
.PROJECTURI https://github.com/powershell/psresourceget
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
<#
.DESCRIPTION
Microsoft.PowerShell.PSResourceGet is a continuation of the PowerShellGet 3.0 project.
The first preview release of this module under the new name is now available on the PowerShell Gallery.
This release contains the module rename, and reintroduces support for Azure Artifacts, GitHub packages, and Artifactory and contains a number of bug fixes.
.LINK
https://devblogs.microsoft.com/powershell/psresourceget-preview-is-now-available/
#>
[CmdletBinding()]
param()

# To install from PowerShellGet 3.0 previews
if (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable) {
    Install-PSResource Microsoft.PowerShell.PSResourceGet -Prerelease -Verbose
}

# To install from PowerShellGet 2.2.5
else {
    Install-Module -Name Microsoft.PowerShell.PSResourceGet -AllowPrerelease -Verbose
}