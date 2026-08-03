function Get-OSDCoreDriverPacks {
    <#
    .SYNOPSIS
    Retrieves driver pack information for the specified manufacturer and operating system architecture.

    .DESCRIPTION
    Gets driver pack catalogs based on the device manufacturer and OS architecture. For AMD64 architecture,
    manufacturer-specific catalogs are loaded. For ARM64 and other architectures, the default catalog is returned.
    Supports Dell, HP, Lenovo, Microsoft (Surface), and generic devices.

    .PARAMETER OSDManufacturer
    The device manufacturer name. Defaults to the value from $global:OSDCoreDevice.OSDManufacturer.
    Supported values: Dell, HP, Lenovo, Microsoft, or any other value will use the Default catalog.

    .PARAMETER ProcessorArchitecture
    The operating system architecture. Defaults to the value from $global:OSDCoreDevice.ProcessorArchitecture.
    Typically 'amd64' or 'arm64'.

    .OUTPUTS
    PSCustomObject
    Array of driver pack objects containing driver information for the specified manufacturer and architecture.

    .EXAMPLE
    PS> Get-OSDCoreDriverPacks
    Returns driver packs for the current device's manufacturer and architecture.

    .EXAMPLE
    PS> Get-OSDCoreDriverPacks -OSDManufacturer 'Dell' -ProcessorArchitecture 'amd64'
    Returns driver packs for Dell devices with AMD64 architecture.

    .NOTES
    Requires manufacturer-specific cmdlets (Get-OSDCoreDriverPackCatalogDell, Get-OSDCoreDriverPackCatalogHP, etc.) to be available.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$GenericDriverPackJson = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\generic.json'),

        [System.String]$OSDManufacturer = $global:OSDCoreDevice.OSDManufacturer,

        [System.String]$ProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
    )

    # Load Generic driver pack catalog for fallback
    $GenericCatalog = Get-Content -Path $GenericDriverPackJson -Raw | ConvertFrom-Json

    if ($ProcessorArchitecture -eq 'amd64') {
        $DriverPackValues = switch ($OSDManufacturer) {
            'Dell' { Get-OSDCoreDriverPackCatalogDell }
            'HP' { Get-OSDCoreDriverPackCatalogHP }
            'Lenovo' { Get-OSDCoreDriverPackCatalogLenovo }
            'Microsoft' { Get-OSDCoreDriverPackCatalogSurface }
            default { $GenericCatalog }
        }
    }
    else {
        $DriverPackValues = switch ($OSDManufacturer) {
            'Microsoft' { Get-OSDCoreDriverPackCatalogSurface }
            default { $GenericCatalog }
        }
    }

    $DriverPackValues | Where-Object { $_.OSArchitecture -eq $ProcessorArchitecture }
}
