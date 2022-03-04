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
        $Result = Get-DellBiosCatalog | Where-Object {($_.SupportedSystemID -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'HP') {
        $Result = Get-HPBiosCatalog | Where-Object {($_.SupportedSystemId -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-OSDMasterCatalogLenovoBios | Where-Object {($_.SupportedProduct -contains $Product)}
        $Result[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=================================================
}