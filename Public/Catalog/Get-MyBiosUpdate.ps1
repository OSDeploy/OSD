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
        Write-Warning "$Manufacturer is not supported yet"
    }
    elseif ($Manufacturer -eq 'HP') {
        Write-Warning "$Manufacturer is not supported yet"
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-LenovoBiosUpdate | Where-Object {($_.SupportedProduct -contains $Product)}
        $Result[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=================================================
}