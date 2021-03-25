function Get-MyDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('Dell','HP','Lenovo')]
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #   Set ErrorActionPreference
    #=======================================================================
    $ErrorActionPreference = 'SilentlyContinue'
    #=======================================================================
    #   Action
    #=======================================================================
    Write-Verbose "Get-MyLenovoDriverPack: This function is currently in development"
    Write-Verbose "Get-MyLenovoDriverPack: Results are for Windows 10 x64 only"

    if ($Manufacturer -eq 'Dell') {
        $Result = Get-DellDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'HP') {
        $Result = Get-HpDriverPack -Product $Product
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-LenovoDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=======================================================================
}