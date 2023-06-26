<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 8785db1b-343a-4b25-89e2-276266a0df3b
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS OSDCloud
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/PwshHub
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -RunAsAdministrator
<#
.DESCRIPTION
If you're not a fan of all the extra files in the Media folder, this script will remove them.
.LINK
https://www.osdcloud.com
#>
[CmdletBinding()]
param()

$KeepTheseDirs = @('boot','efi','en-us','osdcloud','sources','fonts','resources')

Get-ChildItem "$(Get-OSDCloudWorkspace)\Media" | `
Where-Object {$_.PSIsContainer} | `
Where-Object {$_.Name -notin $KeepTheseDirs} | `
Remove-Item -Recurse -Force

Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\Boot" | `
Where-Object {$_.PSIsContainer} | `
Where-Object {$_.Name -notin $KeepTheseDirs} | `
Remove-Item -Recurse -Force

Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\EFI\Microsoft\Boot" | `
Where-Object {$_.PSIsContainer} | `
Where-Object {$_.Name -notin $KeepTheseDirs} | `
Remove-Item -Recurse -Force

New-OSDCloudISO