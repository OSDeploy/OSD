Import-Module -Name OSD -Force
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-OSDCatalogLenovoDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.json") -Force -Encoding ascii
Break
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-OSDCatalogDellDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogDellDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellDriverPack.json") -Force -Encoding UTF8
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-OSDCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogDellSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-OSDCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPPlatformList.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPPlatformList.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-OSDCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPSystem.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-OSDCatalogHPDriverPack -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.json") -Force -Encoding UTF8
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-OSDCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoBios.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoBios.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-OSDCatalogMicrosoftDriverPack -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogMicrosoftDriverPack.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogMicrosoftDriverPack.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDCatalogIntelDisplayDriver
#=================================================
$null = Get-OSDCatalogIntelDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDCatalogIntelDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogIntelDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDCatalogIntelRadeonDisplayDriver
#=================================================
$null = Get-OSDCatalogIntelRadeonDisplayDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDCatalogIntelRadeonDisplayDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogIntelRadeonDisplayDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDCatalogIntelWirelessDriver
#=================================================
$null = Get-OSDCatalogIntelWirelessDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDCatalogIntelWirelessDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogIntelWirelessDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   OSDCatalogIntelEthernetDriver
#=================================================
$null = Get-OSDCatalogIntelEthernetDriver -Verbose
$Source = Join-Path $env:TEMP 'OSDCatalogIntelEthernetDriver.json'
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogIntelEthernetDriver.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================