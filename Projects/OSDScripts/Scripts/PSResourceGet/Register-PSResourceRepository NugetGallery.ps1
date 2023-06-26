<#PSScriptInfo
.VERSION 23.6.9.1
.GUID 493310fa-1db7-4762-a522-4fdea8ec7c03
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

Register-PSResourceRepository -Name "NuGetGallery" -Uri "https://api.nuget.org/v3/index.json"