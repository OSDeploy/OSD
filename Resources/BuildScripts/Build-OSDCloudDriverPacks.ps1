Import-Module -Name OSD -Force
#=================================================
#   DellDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\DellDriverPackCatalog.log")
$null = Get-DellDriverPackCatalog -Force -Verbose -TestUrl
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\DellDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\DellDriverPackCatalog.json") -Encoding ascii -Width 2000 -Force
Stop-Transcript
#=================================================
#   LenovoDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\LenovoDriverPackCatalog.log")
$null = Get-LenovoDriverPackCatalog -Force -Verbose -TestUrl
#$null = Get-LenovoDriverPackCatalog -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'LenovoDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\LenovoDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\LenovoDriverPackCatalog.json") -Encoding ascii -Width 2000 -Force
Stop-Transcript
#=================================================
#   HPDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPDriverPackCatalog.log")
$null = Get-HPDriverPackCatalog -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalog.xml')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPDriverPackCatalog.xml"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Import-Clixml -Path $Destination | ConvertTo-Json | Out-File -FilePath (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPDriverPackCatalog.json") -Encoding ascii -Width 2000 -Force
#$MasterDriverPacks += Get-Content (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\HPDriverPackCatalog.json") | ConvertFrom-Json
Stop-Transcript
#=================================================
#   MicrosoftDriverPackCatalog
#=================================================
Import-Module -Name OSD -Force
Start-Transcript -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\MicrosoftDriverPackCatalog.log")
#$MasterDriverPacks = @()
$null = Get-MicrosoftDriverPackCatalog -Force -Verbose
$Source = Join-Path $env:TEMP (Join-Path 'OSD' 'MicrosoftDriverPackCatalog.json')
$Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\MicrosoftDriverPackCatalog.json"
if (Test-Path $Source) {
    Copy-Item $Source $Destination -Force
}
Stop-Transcript
#=================================================
#   MasterDriverPack.json
#=================================================
Import-Module OSD -Force
$MasterDriverPacks = @()
$MasterDriverPacks += Get-DellDriverPack
$MasterDriverPacks += Get-HPDriverPack
$MasterDriverPacks += Get-LenovoDriverPack
$MasterDriverPacks += Get-MicrosoftDriverPack

$Results = $MasterDriverPacks | `
Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
Product, Name, PackageID, FileName, `
@{Name='Url';Expression={([array]$_.DriverPackUrl)}}, `
@{Name='OS';Expression={([array]$_.DriverPackOS)}}, `
HashMD5, `
@{Name='Guid';Expression={([guid]((New-Guid).ToString()))}}

$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.json") -Encoding ascii -Width 2000 -Force
#================================================