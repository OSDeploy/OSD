function Get-MyBiosUpdate {
<#
.SYNOPSIS
Gets MyBiosUpdate information.

.DESCRIPTION
Returns MyBiosUpdate data for the current system or OSD session context.

.PARAMETER Manufacturer
Specifies the Manufacturer to use when running Get-MyBiosUpdate.

.PARAMETER Product
Specifies the Product to use when running Get-MyBiosUpdate.

.EXAMPLE
Get-MyBiosUpdate -Manufacturer <value>
Demonstrates a common way to run Get-MyBiosUpdate.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
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
        $Result = Get-LenovoBiosCatalog | Where-Object {($_.SupportedProduct -contains $Product)}
        $Result[0]
    }
    else {
        Write-Verbose "$Manufacturer is not supported yet"
    }
    #=================================================
}
