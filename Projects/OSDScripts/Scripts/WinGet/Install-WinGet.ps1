<#PSScriptInfo
.VERSION 23.6.1.2
.GUID c3f0cde1-d1af-4832-9135-aa3f99466f6c
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS WinGet
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/PwshHub
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -RunAsAdministrator
<#
.DESCRIPTION
Installs WinGet by adding the Microsoft.DesktopAppInstaller Appx Package
.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    Write-Host 'WinGet is already installed.'
}
else {
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -Verbose
    }
    catch {
        Write-Error 'WinGet could not be installed.'
    }
}