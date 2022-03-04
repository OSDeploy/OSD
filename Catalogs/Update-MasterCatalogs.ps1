Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogDellDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\DellDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-OSDMasterCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\DellSystemMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-OSDMasterCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformListMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\HPPlatformListMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-OSDMasterCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPSystemMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\HPSystemMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogHPDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\HPDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-OSDMasterCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoBiosMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\LenovoBiosMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogLenovoDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\LenovoDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-OSDMasterCatalogMicrosoftDriverPack -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MicrosoftDriverPackMasterCatalog.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\MicrosoftDriverPackMasterCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   IntelDisplayDriverMasterCatalog
#=================================================
$null = Get-OSDMasterCatalogIntelDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'IntelDisplayDriverMasterCatalog.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\IntelDisplayDriverMasterCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   IntelRadeonDisplayDriverMasterCatalog
#=================================================
$null = Get-OSDMasterCatalogIntelRadeonDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'IntelRadeonDisplayDriverMasterCatalog.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\IntelRadeonDisplayDriverMasterCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   IntelWirelessDriverMasterCatalog
#=================================================
$null = Get-OSDMasterCatalogIntelWirelessDriver -Verbose
$Source = Join-Path $env:TEMP 'IntelWirelessDriverMasterCatalog.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MASTER\IntelWirelessDriverMasterCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================