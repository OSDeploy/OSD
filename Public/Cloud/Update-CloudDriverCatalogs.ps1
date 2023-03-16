function Update-CloudDriverCatalogIntelEthernet {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelEthernet -Force -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelEthernet.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriver\CloudDriverIntelEthernet.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelGraphics {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelGraphics -Force -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelGraphics.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriver\CloudDriverIntelGraphics.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelRadeonGraphics {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelRadeonGraphics -Force -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelRadeonGraphics.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriver\CloudDriverIntelRadeonGraphics.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelWireless {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelWireless -Force -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelWireless.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriver\CloudDriverIntelWireless.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}