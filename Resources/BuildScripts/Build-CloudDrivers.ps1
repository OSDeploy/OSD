Import-Module -Name OSD -Force
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-DellSystemCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\DellSystemCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-HPPlatformCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPPlatformCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-HPSystemCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPSystemCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPSystemCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-LenovoBiosCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoBiosCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\LenovoBiosCatalog.xml"
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