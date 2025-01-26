#Requires -RunAsAdministrator
Import-Module OSD -Force -ErrorAction Stop

# Cloud Catalogs
Get-DellSystemCatalog -UpdateModuleCatalog
Get-HPPlatformCatalog -UpdateModuleCatalog
Get-HPSystemCatalog -UpdateModuleCatalog
Get-LenovoBiosCatalog -UpdateModuleCatalog

Import-Module OSD -Force -ErrorAction Stop

# DriverPack Catalogs
Update-DellDriverPackCatalog -UpdateModuleCatalog -Verify
Update-LenovoDriverPackCatalog -UpdateModuleCatalog -Verify
Update-HPDriverPackCatalog -UpdateModuleCatalog -Verify

# OSD Module Path
$OSDModulePath = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase

# Master DriverPacks
$MasterDriverPacks = @()
$MasterDriverPacks += Get-MicrosoftDriverPack
$MasterDriverPacks += Get-DellDriverPack
$MasterDriverPacks += Get-HPDriverPack
$MasterDriverPacks += Get-LenovoDriverPack

$Results = $MasterDriverPacks | `
Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, Legacy, Product, Name, PackageID, FileName, `
@{Name = 'Url'; Expression = { ([array]$_.DriverPackUrl) } }, `
@{Name = 'OS'; Expression = { ([array]$_.DriverPackOS) } }, `
OSReleaseId, OSBuild, OSArchitecture, HashMD5, `
@{Name = 'Guid'; Expression = { ([guid]((New-Guid).ToString())) } }

foreach ($Item in $Results) {
    if ($Item.OS -match 'arm64') {
        $Item.OSArchitecture = 'arm64'
    }
    if ($Item.OSArchitecture -notmatch '64') {
        $Item.OSArchitecture = 'amd64'
    }
}

$Results | Export-Clixml -Path (Join-Path $OSDModulePath 'Catalogs\CloudDriverPacks.xml') -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | `
    Select-Object -First 1).ModuleBase 'Catalogs\CloudDriverPacks.xml') | ConvertTo-Json | `
    Out-File (Join-Path $OSDModulePath 'Catalogs\CloudDriverPacks.json') -Encoding ascii -Width 2000 -Force
