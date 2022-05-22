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
    $Results = Get-OSDCloudDriverPacks | Where-Object {($_.Product -contains $Product)}
    #=================================================
    #   Results
    #=================================================
    if ($Results) {
        $Results = $Results | Sort-Object -Property Name -Descending
        $Results[0]
    }
    else {
        Write-Verbose "$Manufacturer $Product is not supported"
    }
    #=================================================
}