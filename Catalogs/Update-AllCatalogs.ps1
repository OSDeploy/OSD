Import-Module -Name OSD -Force
#Dell
$null = Get-DellDriverPackCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
$null = Get-DellSystemCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellSystemCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#Lenovo
$null = Get-LenovoDriverPackCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}


Break
#HP
$null = Get-HPDriverPackCatalog
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HP\HPClientDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
