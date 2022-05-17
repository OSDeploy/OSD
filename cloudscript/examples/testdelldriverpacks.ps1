<#PSScriptInfo
.VERSION 22.5.17.1
.GUID 75acdf11-6054-47af-8c22-95a764e57193
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdeploy.com
.COPYRIGHT (c) 2022 David Segura osdeploy.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri 'https://go.osdcloud.com/testdelldriverpacks')
This is abbreviated as
powershell iex (irm go.osdcloud.com/testdelldriverpacks)
#>
<#
.SYNOPSIS
    PSCloudScript at go.osdcloud.com/testdelldriverpacks
.DESCRIPTION
    PSCloudScript at go.osdcloud.com/testdelldriverpacks
.NOTES
    Version 22.5.17.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/examples/testdelldriverpacks.ps1
.EXAMPLE
    powershell iex (irm go.osdcloud.com/testdelldriverpacks)
#>

$DriverPackCatalog = 'https://raw.githubusercontent.com/OSDeploy/OSD/master/Catalogs/OSDCatalog/OSDCatalogDellDriverPack.json'

$DriverPacks = Invoke-RestMethod -Uri $DriverPackCatalog

foreach ($DriverPack in $DriverPacks) {
    try {
        $null = Invoke-WebRequest -Method Head $DriverPack.Url -ErrorAction Stop
    }
    catch {
        Write-Host -ForegroundColor Red "FAILED: " -NoNewline
        Write-Host "$($DriverPack.Name) $($DriverPack.Url)"
    }
}