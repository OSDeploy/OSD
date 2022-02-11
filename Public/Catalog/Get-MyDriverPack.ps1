function Get-MyDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [System.String]$Product = (Get-MyComputerProduct),
        
        [ValidateSet('Win10','Win11')]
        [System.String]$OsCode = 'Win10'
    )
    #=================================================
    #   Set ErrorActionPreference
    #=================================================
    $ErrorActionPreference = 'SilentlyContinue'
    #=================================================
    #   Action
    #=================================================
    if ($Manufacturer -eq 'Dell') {
        if ($OsCode -eq 'Win10') {
            $Results = Get-DellDriverPack -OsCode 'Win10' | Where-Object {($_.Product -contains $Product)}
        }
        if ($OsCode -eq 'Win11') {
            $Results = Get-DellDriverPack -OsCode 'Win11' | Where-Object {($_.Product -contains $Product)}
        }
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
        $Results[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=================================================
}