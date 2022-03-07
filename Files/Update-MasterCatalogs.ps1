Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-MasterCatalogDellDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogDellDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogDellDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-MasterCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogDellSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogDellSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-MasterCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogHPPlatformList.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogHPPlatformList.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-MasterCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogHPSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogHPSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-MasterCatalogHPDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogHPDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogHPDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-MasterCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogLenovoBios.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogLenovoBios.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-MasterCatalogLenovoDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogLenovoDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogLenovoDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-MasterCatalogMicrosoftDriverPack -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MasterCatalogMicrosoftDriverPack.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogMicrosoftDriverPack.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MasterCatalogIntelDisplayDriver
#=================================================
$null = Get-MasterCatalogIntelDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'MasterCatalogIntelDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogIntelDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MasterCatalogIntelRadeonDisplayDriver
#=================================================
$null = Get-MasterCatalogIntelRadeonDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'MasterCatalogIntelRadeonDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogIntelRadeonDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MasterCatalogIntelWirelessDriver
#=================================================
$null = Get-MasterCatalogIntelWirelessDriver -Verbose
$Source = Join-Path $env:TEMP 'MasterCatalogIntelWirelessDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MasterCatalogIntelWirelessDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================