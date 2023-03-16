function Update-IntelEthernetDriverPackCatalog {
    [CmdletBinding()]
    param ()
    $null = Get-IntelEthernetDriverPack -Force -Verbose
    $Source = Join-Path $env:TEMP 'IntelEthernetDriverPack.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\IntelEthernetDriverPack.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-IntelGraphicsDriverPackCatalog {
    [CmdletBinding()]
    param ()
    $null = Get-IntelGraphicsDriverPack -Force -Verbose
    $Source = Join-Path $env:TEMP 'IntelGraphicsDriverPack.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\IntelGraphicsDriverPack.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-IntelRadeonDriverPackCatalog {
    [CmdletBinding()]
    param ()
    $null = Get-IntelRadeonDriverPack -Force -Verbose
    $Source = Join-Path $env:TEMP 'IntelRadeonDriverPack.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\IntelRadeonDriverPack.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-IntelWirelessDriverPackCatalog {
    [CmdletBinding()]
    param ()
    $null = Get-IntelWirelessDriverPack -Force -Verbose
    $Source = Join-Path $env:TEMP 'IntelWirelessDriverPack.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\IntelWirelessDriverPack.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}