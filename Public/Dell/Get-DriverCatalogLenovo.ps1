function Get-DriverCatalogLenovoXml {
    [CmdletBinding()]
    param ()

    [xml]$CatalogXml = Get-DriverCatalogLenovoXml -ErrorAction Stop
    $LenovoCatalog = $CatalogXml.Products.Product

<#     cls
    Import-Module OSD -Force
    [xml]$XmlDocument  = Get-DriverCatalogLenovoXml -ErrorAction Stop
    
    $LenvoCatalog = $XmlDocument.Products.Product | `
    Select-Object `
    @{Label="Model";Expression={$_.model};},
    @{Label="Family";Expression={$_.family};},
    @{Label="OS";Expression={$_.os};},
    @{Label="Build";Expression={$_.build};},
    @{Label="Types";Expression={($_.Queries.Types)};},
    @{Label="Version";Expression={($_.Queries.Version)};},
    @{Label="Smbios";Expression={($_.Queries.Smbios)};},
    @{Label="Name";Expression={($_.Name)};},
    @{Label="DriverPack";Expression={$_.DriverPack[0].'#Text'};},
    @{Label="BIOSUpdate";Expression={($_.BIOSUpdate)};}
    
    $LenvoCatalog = $LenvoCatalog | Where OS -eq 'win10'
    $LenvoCatalog = $LenvoCatalog | Sort-Object Build -Descending | Group-Object Smbios | ForEach-Object {$_.Group | Select-Object -First 1}
    $LenvoCatalog = $LenvoCatalog | Select Model, Version, Smbios, DriverPack, BiosUpdate
    $LenvoCatalog | Sort Version | ft
    break
    
    $LenvoCatalog | Sort-Object SupportedDevices, Version -Descending | Group-Object SupportedDevices | ForEach-Object {$_.Group | Select-Object -First 1}
    Break #>
}