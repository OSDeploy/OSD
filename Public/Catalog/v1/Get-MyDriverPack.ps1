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
        $Result = Get-DellDriverPack | Where-Object {($_.Product -contains $Product)}
        if ($OsCode -eq 'Win10') {
            $Result = $Result | Where-Object {($_.SupportedOperatingSystems -contains 'Windows 10 x64')}
            $Result[0]
        }
        if ($OsCode -eq 'Win11') {
            $Result = $Result | Where-Object {($_.SupportedOperatingSystems -contains 'Windows 11 x64')}
            $Result[0]
        }
    }
    elseif ($Manufacturer -eq 'HP') {
        $Result = Get-HpDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-LenovoDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Microsoft') {
        $Result = Get-MicrosoftDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=================================================
}