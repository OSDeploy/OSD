<#PSScriptInfo
.VERSION 23.6.3.4
.GUID be122a01-eeab-459f-ad23-bf8153e6ce91
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
Update
#>
[CmdletBinding()]
param(
)

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    # Show package information
    # winget show --id $id
    
    # Show version information
    # winget show --id $id --versions
    
    # Install
    winget update 

    Start-Sleep -Seconds 2

    winget update --all --silent
}
else {
    Write-Error -Message 'WinGet is not installed.'
}