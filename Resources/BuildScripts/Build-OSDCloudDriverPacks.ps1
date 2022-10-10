Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellDriverPack.log")
$null = Get-OSDCatalogDellDriverPack -Force -Verbose -TestUrl
#$null = Get-OSDCatalogDellDriverPack -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogDellDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogDellDriverPack.json") -Encoding ascii -Width 2000 -Force
Stop-Transcript
#=================================================
#   LenovoDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.log")
$null = Get-OSDCatalogLenovoDriverPack -Force -Verbose -TestUrl
#$null = Get-OSDCatalogLenovoDriverPack -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.json") -Encoding ascii -Width 2000 -Force
Stop-Transcript
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogMicrosoftDriverPack.log")
$MasterDriverPacks = @()
$null = Get-OSDCatalogMicrosoftDriverPack -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogMicrosoftDriverPack.json')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogMicrosoftDriverPack.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Stop-Transcript
#=================================================
#   HPDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.log")
$null = Get-OSDCatalogHPDriverPack -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPDriverPack.xml')
$Destination = Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.json") -Encoding ascii -Width 2000 -Force
$MasterDriverPacks += Get-Content (Join-Path (Get-Module OSD).ModuleBase "Catalogs\OSDCatalog\OSDCatalogHPDriverPack.json") | ConvertFrom-Json
Stop-Transcript
#=================================================
#   MasterDriverPack.json
#=================================================
Import-Module OSD -Force
$MasterDriverPacks = @()
$MasterDriverPacks += Get-DellDriverPack
$MasterDriverPacks += Get-HpDriverPack
$MasterDriverPacks += Get-LenovoDriverPack
$MasterDriverPacks += Get-MicrosoftDriverPack

$Results = $MasterDriverPacks | `
Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
Product, Name, PackageID, FileName, `
@{Name='Url';Expression={([array]$_.DriverPackUrl)}}, `
@{Name='OS';Expression={([array]$_.DriverPackOS)}}, `
HashMD5, `
@{Name='Guid';Expression={([guid]((New-Guid).ToString()))}}

$Results | Export-Clixml -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\driverpacks.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\driverpacks.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module OSD).ModuleBase "Catalogs\driverpacks.json") -Encoding ascii -Width 2000 -Force
#================================================