function Get-MyBiosUpdate {
    [CmdletBinding()]
    param (
        [System.String]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [System.String]$Product = (Get-MyComputerProduct)
    )
    #=================================================
    #   Set ErrorActionPreference
    #=================================================
    $ErrorActionPreference = 'SilentlyContinue'
    #=================================================
    #   Action
    #=================================================
    if ($Manufacturer -eq 'Dell') {
        $Result = Get-CatalogDellBios | Where-Object {($_.SupportedSystemID -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'HP') {
        $Result = Get-CatalogHPBios | Where-Object {($_.SupportedSystemId -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-OSDCatalogLenovoBios | Where-Object {($_.SupportedProduct -contains $Product)}
        $Result[0]
    }
    else {
        Write-Verbose "$Manufacturer is not supported yet"
    }
    #=================================================
}