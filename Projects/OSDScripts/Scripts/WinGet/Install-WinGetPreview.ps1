<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 854704c6-fd33-4ab8-ba55-8fdb10e44911
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
Installs WinGet Preview
.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget
#>
[CmdletBinding()]
param()

$progressPreference = 'silentlyContinue'
$WinGetPreviewUri = 'https://aka.ms/getwingetpreview'
$WinGetPreview = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
Invoke-WebRequest -Uri $WinGetPreviewUri -OutFile "./$WinGetPreview"
Add-AppxPackage $WinGetPreview