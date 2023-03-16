Import-Module -Name OSD -Force
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-OSDCatalogDellSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogDellSystem.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-OSDCatalogHPPlatformList -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPPlatformList.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPPlatformList.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-OSDCatalogHPSystem -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPSystem.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPSystem.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-OSDCatalogLenovoBios -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoBios.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoBios.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   Update-CloudDriverCatalog
#=================================================
Import-Module -Name OSD -Force
Update-IntelEthernetDriverPackCatalog
Update-IntelGraphicsDriverPackCatalog
Update-IntelRadeonDriverPackCatalog
Update-IntelWirelessDriverPackCatalog