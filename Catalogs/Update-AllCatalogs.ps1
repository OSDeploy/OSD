Import-Module -Name OSD -Force
#Lenovo
$null = Get-CatalogLenovoDriverPack
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\Lenovo\catalogv2.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}