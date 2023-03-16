function Update-OSDModuleCatalog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'IntelEthernetDriverPack',
            'IntelGraphicsDriverPack',
            'IntelRadeonDriverPack',
            'IntelWirelessDriverPack'
        )]
        [System.String]
        $Name
    )

    switch ($Name) {
        'IntelEthernetDriverPack'   {$null = Get-IntelEthernetDriverPack -Force -Verbose}
        'IntelGraphicsDriverPack'   {$null = Get-IntelGraphicsDriverPack -Force -Verbose}
        'IntelRadeonDriverPack'     {$null = Get-IntelRadeonDriverPack -Force -Verbose}
        'IntelWirelessDriverPack'   {$null = Get-IntelWirelessDriverPack -Force -Verbose}
    }

    $Source = Join-Path $env:TEMP "$Name.json"
    $Destination = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\$Name.json"
    if (Test-Path $Source) {
        Copy-Item $Source $Destination -Force -ErrorAction Ignore
    }
}