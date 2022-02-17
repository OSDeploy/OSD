Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
$null = Get-DellDriverPackMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   DellSystemCatalog
#=================================================
$null = Get-DellSystemMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellSystemMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\DellSystemMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPPlatformListCatalog
#=================================================
$null = Get-HPPlatformListMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformListMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPPlatformListMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPSystemCatalog
#=================================================
$null = Get-HPSystemMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPSystemMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPSystemMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   HPDriverPackCatalog
#=================================================
$null = Get-HPDriverPackMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\HPDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoBiosCatalog
#=================================================
$null = Get-LenovoBiosMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoBiosMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoBiosMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   LenovoDriverPackCatalog
#=================================================
$null = Get-LenovoDriverPackMasterCatalog -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackMasterCatalog.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\LenovoDriverPackMasterCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
$null = Get-MicrosoftDriverPackMasterCatalog -Verbose -UseCatalog Cloud
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MicrosoftDriverPackMasterCatalog.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\MicrosoftDriverPackMasterCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
#=================================================
#
#=================================================