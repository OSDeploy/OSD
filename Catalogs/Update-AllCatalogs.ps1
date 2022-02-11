Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-DellDriverPackCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-DellSystemCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellSystemCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-HPPlatformListCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformListCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\Get-HPPlatformListCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-HPSystemCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPSystemCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPSystemCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-HPDriverPackCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-LenovoBiosCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoBiosCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoBiosCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-LenovoDriverPackCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#
#=================================================