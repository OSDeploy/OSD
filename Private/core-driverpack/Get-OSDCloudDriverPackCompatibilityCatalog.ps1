function Get-OSDCloudDriverPackCompatibilityCatalog {
    <#
    .SYNOPSIS
    Builds the legacy OSDCloud driver pack catalog from core catalog sources.

    .DESCRIPTION
    Reads all bundled manufacturer and generic catalogs from core\driverpacks and
    converts them to the public Get-OSDCloudDriverPacks property schema. Online
    catalog refresh and OSDCore licensing are not used.

    .PARAMETER ModuleBase
    Root path of the OSD module containing the core\driverpacks directory.

    .EXAMPLE
    Get-OSDCloudDriverPackCompatibilityCatalog
    Returns the bundled driver pack catalogs using the legacy public object schema.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-09-30 - Added core catalog aggregation for public compatibility
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
    )

    $Error.Clear()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"

    $driverPackCatalogPath = Join-Path -Path $ModuleBase -ChildPath 'core\driverpacks'
    $requiredCatalogs = @(
        'dell.xml'
        'hp.xml'
        'lenovo.xml'
        'panasonic.json'
        'surface.json'
        'generic.json'
    )

    foreach ($catalogName in $requiredCatalogs) {
        $catalogPath = Join-Path -Path $driverPackCatalogPath -ChildPath $catalogName
        if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.IO.FileNotFoundException]::new("Required driver pack catalog was not found: $catalogPath"),
                'DriverPackCatalogNotFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $catalogPath
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    $genericCatalogContent = Get-Content -LiteralPath (Join-Path $driverPackCatalogPath 'generic.json') -Raw -ErrorAction Stop
    $genericDriverPacks = $genericCatalogContent | ConvertFrom-Json
    $legacyDriverPackCatalog = @()
    $legacyDriverPackCatalogPath = Join-Path -Path $ModuleBase -ChildPath 'cache\driverpack-catalogs\build-driverpacks.json'
    if (Test-Path -LiteralPath $legacyDriverPackCatalogPath -PathType Leaf) {
        $legacyCatalogContent = Get-Content -LiteralPath $legacyDriverPackCatalogPath -Raw -ErrorAction Stop
        $legacyDriverPackCatalog = @($legacyCatalogContent | ConvertFrom-Json)
    }

    $coreDriverPacks = @(
        Get-OSDCoreDriverPackCatalogDell -LocalOnly -LocalDriverPackCatalog (Join-Path $driverPackCatalogPath 'dell.xml') 6>$null
        Get-OSDCoreDriverPackCatalogHP -LocalOnly -LocalDriverPackCatalog (Join-Path $driverPackCatalogPath 'hp.xml') 6>$null
        Get-OSDCoreDriverPackCatalogLenovo -LocalOnly -LocalDriverPackCatalog (Join-Path $driverPackCatalogPath 'lenovo.xml') 6>$null
        Get-OSDCoreDriverPackCatalogPanasonic -LocalOnly -LocalDriverPackCatalog (Join-Path $driverPackCatalogPath 'panasonic.json') 6>$null
        Get-OSDCoreDriverPackCatalogSurface -LocalOnly -LocalDriverPackCatalog (Join-Path $driverPackCatalogPath 'surface.json') 6>$null
        foreach ($genericDriverPack in $genericDriverPacks) {
            $genericDriverPack
        }
    )

    $coreDriverPacks |
        ConvertTo-OSDCloudDriverPack -LegacyDriverPackCatalog $legacyDriverPackCatalog |
        Sort-Object -Property Manufacturer, Model, Name

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
}
