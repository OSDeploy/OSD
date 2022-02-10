Import-Module -Name OSD -Force
#Dell
$null = Get-DellDriverPackCatalog
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\Dell\DriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
$null = Get-DellSystemCatalog
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'CatalogPC.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\Dell\CatalogPC.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}

#Lenovo
$null = Get-CatalogLenovoDriverPack
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\Lenovo\catalogv2.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}