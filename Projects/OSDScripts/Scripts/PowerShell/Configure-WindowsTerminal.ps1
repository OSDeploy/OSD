<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 91535b2d-d192-4f50-b71f-bce78dad9b46
.AUTHOR Jérôme Bezet-Torres
.COMPANYNAME Jérôme Bezet-Torres
.COPYRIGHT (c) 2023 Jérôme Bezet-Torres. All rights reserved.
.TAGS PowerShell
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
Configure Windows Terminal with PowerShell as default shell
.LINK
https://support.microsoft.com/en-us/windows/command-prompt-and-windows-powershell-for-windows-11-6453ce98-da91-476f-8651-5c14d5777c20
#>


New-Item -Path HKCU:\Console\%%Startup | out-null

New-ItemProperty -Path "HKCU:\Console\%%Startup" -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" -force | out-null
New-ItemProperty -Path "HKCU:\Console\%%Startup" -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" -force | out-null

