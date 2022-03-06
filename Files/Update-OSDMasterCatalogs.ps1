Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogDellDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogDellDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogDellDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-OSDMasterCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogDellSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogDellSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-OSDMasterCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogHPPlatformList.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogHPPlatformList.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-OSDMasterCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogHPSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogHPSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogHPDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogHPDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogHPDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-OSDMasterCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogLenovoBios.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogLenovoBios.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogLenovoDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogLenovoDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogLenovoDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogMicrosoftDriverPack -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDMasterCatalogMicrosoftDriverPack.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogMicrosoftDriverPack.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDMasterCatalogIntelDisplayDriver
#=================================================
$null = Get-OSDMasterCatalogIntelDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDMasterCatalogIntelDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogIntelDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDMasterCatalogIntelRadeonDisplayDriver
#=================================================
$null = Get-OSDMasterCatalogIntelRadeonDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDMasterCatalogIntelRadeonDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogIntelRadeonDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDMasterCatalogIntelWirelessDriver
#=================================================
$null = Get-OSDMasterCatalogIntelWirelessDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDMasterCatalogIntelWirelessDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\OSDMasterCatalogIntelWirelessDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================