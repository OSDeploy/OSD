#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# Cloud Drivers
Get-IntelEthernetDriverPack -UpdateModuleCatalog
Get-IntelGraphicsDriverPack -UpdateModuleCatalog
Get-IntelRadeonDriverPack -UpdateModuleCatalog
Get-IntelWirelessDriverPack -UpdateModuleCatalog

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# Cloud Catalogs
Get-DellSystemCatalog -UpdateModuleCatalog
Get-HPPlatformCatalog -UpdateModuleCatalog
Get-HPSystemCatalog -UpdateModuleCatalog
Get-LenovoBiosCatalog -UpdateModuleCatalog

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# DriverPack Catalogs
Update-DellDriverPackCatalog -UpdateModuleCatalog -Verify
Update-LenovoDriverPackCatalog -UpdateModuleCatalog -Verify
Update-HPDriverPackCatalog -UpdateModuleCatalog -Verify
Update-MicrosoftDriverPackCatalog -UpdateModuleCatalog -Verify

# PlatyPS Module
$modules = Get-Module -Name platyPS -ListAvailable
if ($modules.Count -eq 0) {
    Install-Module -Name PlatyPS -Force -ErrorAction Stop
}
else {
    Import-Module platyPS -Force -ErrorAction Stop
}

# OSD Module Path
$OSDModulePath = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase

# Markdown Help
$OSDDocsPath = $(Join-Path $OSDModulePath 'Docs')
New-MarkdownHelp -Module OSD -OutputFolder $OSDDocsPath -Force

# External Help
$OSDDocsOutoutPath = $(Join-Path $OSDModulePath 'en-US')
New-ExternalHelp -Path $OSDDocsPath -OutputPath $OSDDocsOutoutPath -Force

# Master DriverPacks
$MasterDriverPacks = @()
$MasterDriverPacks += Get-DellDriverPack
$MasterDriverPacks += Get-HPDriverPack
$MasterDriverPacks += Get-LenovoDriverPack
$MasterDriverPacks += Get-MicrosoftDriverPack

$Results = $MasterDriverPacks | `
Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
Product, Name, PackageID, FileName, `
@{Name='Url';Expression={([array]$_.DriverPackUrl)}}, `
@{Name='OS';Expression={([array]$_.DriverPackOS)}}, `
OSReleaseId,OSBuild,HashMD5, `
@{Name='Guid';Expression={([guid]((New-Guid).ToString()))}}

$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | `
Sort-Object Version -Descending | `
Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") | `
ConvertTo-Json | `
Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.json") -Encoding ascii -Width 2000 -Force