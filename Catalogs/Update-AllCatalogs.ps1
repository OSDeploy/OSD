Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-DellDriverPackCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellDriverPackCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-DellSystemCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellSystemCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-HPPlatformListCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformListCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPPlatformListCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-HPSystemCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPSystemCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPSystemCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-HPDriverPackCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPDriverPackCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-LenovoBiosCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoBiosCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoBiosCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-LenovoDriverPackCatalogMaster -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackCatalogMaster.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoDriverPackCatalogMaster.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-MicrosoftDriverPackCatalogMaster -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MicrosoftDriverPackCatalogMaster.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MicrosoftDriverPackCatalogMaster.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#
#=================================================