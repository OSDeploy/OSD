<#PSScriptInfo
.VERSION 23.6.15.1
.GUID 42890d16-470b-46d5-bce1-8660a33b4f67
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS Shippets
.LICENSEURI
.PROJECTURI
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>

<#
.SYNOPSIS
Performs monthly data updates.

.DESCRIPTION
The Update-Month.ps1 script updates the registry with new data generated
during the past month and generates a report.
#>
$startTime = (Get-Date).DateTime

# Insert Code Here

$endTime = Get-Date
$TimeSpan = New-TimeSpan -Start $startTime -End $endTime
'-- Script Executed in (min:sec) '+$TimeSpan.Minutes+':'+$TimeSpan.Seconds