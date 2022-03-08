function Get-MyDriverPack {
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
        $Results = Get-DellDriverPack | Where-Object {($_.Product -contains $Product)}
    }
    elseif ($Manufacturer -eq 'HP') {
        $Results = Get-HpDriverPack | Where-Object {($_.Product -contains $Product)}
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Results = Get-LenovoDriverPack | Where-Object {($_.Product -contains $Product)}
    }
    elseif ($Manufacturer -eq 'Microsoft') {
        $Results = Get-MicrosoftDriverPack | Where-Object {($_.Product -contains $Product)}
    }
    #=================================================
    #   Results
    #=================================================
    if ($Results) {
        $Results = $Results | Sort-Object -Property Name -Descending
        $Results[0]
    }
    else {
        Write-Warning "$Manufacturer $Product is not supported"
    }
    #=================================================
}