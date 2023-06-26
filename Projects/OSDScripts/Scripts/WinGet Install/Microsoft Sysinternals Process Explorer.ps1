<#PSScriptInfo
.VERSION 23.6.1.2
.GUID f7194b1a-b5a2-4652-81a5-21412fefd800
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
Install Package using WinGet
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$id = 'Microsoft.Sysinternals.ProcessExplorer'
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