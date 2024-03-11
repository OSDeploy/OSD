#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# HP Device Catalogs
#Get-HPPlatformCatalog -UpdateModuleCatalog
#Get-HPSystemCatalog -UpdateModuleCatalog
#Update-HPDriverPackCatalog -UpdateModuleCatalog -Verify

# Dell Device Catalogs
#Get-DellSystemCatalog -UpdateModuleCatalog
#Update-DellDriverPackCatalog -UpdateModuleCatalog -Verify

# Lenovo Device Catalogs
#Get-LenovoBiosCatalog -UpdateModuleCatalog
#Update-LenovoDriverPackCatalog -UpdateModuleCatalog -Verify

# Microsoft Surface Device Catalogs
Update-MicrosoftDriverPackCatalog -UpdateModuleCatalog -Verify

# Master DriverPacks
$MasterDriverPacks = @()
$MasterDriverPacks += Get-DellDriverPack
$MasterDriverPacks += Get-HPDriverPack
$MasterDriverPacks += Get-LenovoDriverPack
$MasterDriverPacks += Get-MicrosoftDriverPack

$Results = $MasterDriverPacks | `
    Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
    Product, Name, PackageID, FileName, `
@{Name = 'Url'; Expression = { ([array]$_.DriverPackUrl) } }, `
@{Name = 'OS'; Expression = { ([array]$_.DriverPackOS) } }, `
    OSReleaseId, OSBuild, HashMD5, `
@{Name = 'Guid'; Expression = { ([guid]((New-Guid).ToString())) } }

$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase 'Catalogs\CloudDriverPacks.xml') -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | `
            Sort-Object Version -Descending | `
            Select-Object -First 1).ModuleBase 'Catalogs\CloudDriverPacks.xml') | `
    ConvertTo-Json | `
    Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase 'Catalogs\CloudDriverPacks.json') -Encoding ascii -Width 2000 -Force