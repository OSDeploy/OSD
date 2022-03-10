Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-BaseCatalogDellDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogDellDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogDellDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-BaseCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogDellSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogDellSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-BaseCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogHPPlatformList.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogHPPlatformList.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-BaseCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogHPSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogHPSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-BaseCatalogHPDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogHPDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogHPDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-BaseCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogLenovoBios.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogLenovoBios.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-BaseCatalogLenovoDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogLenovoDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogLenovoDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-BaseCatalogMicrosoftDriverPack -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'BaseCatalogMicrosoftDriverPack.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogMicrosoftDriverPack.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   BaseCatalogIntelDisplayDriver
#=================================================
$null = Get-BaseCatalogIntelDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'BaseCatalogIntelDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogIntelDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   BaseCatalogIntelRadeonDisplayDriver
#=================================================
$null = Get-BaseCatalogIntelRadeonDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'BaseCatalogIntelRadeonDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogIntelRadeonDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   BaseCatalogIntelWirelessDriver
#=================================================
$null = Get-BaseCatalogIntelWirelessDriver -Verbose
$Source = Join-Path $env:TEMP 'BaseCatalogIntelWirelessDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\BASE\BaseCatalogIntelWirelessDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================