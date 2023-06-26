<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 4ef98699-6c5f-469c-9bb1-9fe67cb7b071
.AUTHOR Jérôme Bezet-Torres
.COMPANYNAME Jérôme Bezet-Torres
.COPYRIGHT (c) 2023 Jérôme Bezet-Torres. All rights reserved.
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
Install Package using WinGet
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$id = 'WestWind.MarkdownMonster'
)

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    # Show package information
    # winget show --id $id
    
    # Show version information
    # winget show --id $id --versions
    
    # Install
    winget install --id $id --exact --accept-source-agreements --accept-package-agreements
}
else {
    Write-Error -Message 'WinGet is not installed.'
}