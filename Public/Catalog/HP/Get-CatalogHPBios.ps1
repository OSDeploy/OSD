<#
.SYNOPSIS
Returns the BIOS Component of the HP System Catalog

.DESCRIPTION
Returns the BIOS Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPBios {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogHPSystem -Compatible -Component BIOS | Sort-Object -Property CreationDate -Descending
    }
    else {
      Get-CatalogHPSystem -Component BIOS | Sort-Object -Property CreationDate -Descending
    }
}