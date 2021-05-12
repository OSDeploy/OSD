<#
.SYNOPSIS
Returns the Software Component of the HP System Catalog

.DESCRIPTION
Returns the Software Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPSoftware {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogHPSystem -Compatible -Component Software | Sort-Object -Property CreationDate -Descending
    }
    else {
      Get-CatalogHPSystem -Component Software | Sort-Object -Property CreationDate -Descending
    }
}