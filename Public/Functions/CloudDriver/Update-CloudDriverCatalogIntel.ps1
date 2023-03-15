function Update-CloudDriverCatalogIntelEthernet {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelEthernet -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelEthernet.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "CloudDriver\CloudDriverIntelEthernet.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelGraphics {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelGraphics -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelGraphics.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "CloudDriver\CloudDriverIntelGraphics.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelRadeon {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelRadeon -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelRadeon.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "CloudDriver\CloudDriverIntelRadeon.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}
function Update-CloudDriverCatalogIntelWireless {
    [CmdletBinding()]
    param ()
    $null = Get-CloudDriverIntelWireless -Verbose
    $Source = Join-Path $env:TEMP 'CloudDriverIntelWireless.json'
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "CloudDriver\CloudDriverIntelWireless.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}