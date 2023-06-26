<#PSScriptInfo
.VERSION 23.6.8.1
.GUID fe207d11-cf51-437b-98e9-b078eb94475f
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS Microsoft PowerShell Gallery
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
Set the installation policy for a repository
.LINK
https://learn.microsoft.com/en-us/powershell/module/powershellget/set-psrepository?view=powershellget-2.x
#>
[CmdletBinding()]
param()

if ((Get-PSRepository -Name PSGallery) -eq 'Untrusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose
}
Get-PSRepository -Name PSGallery