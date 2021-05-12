<#
.SYNOPSIS
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.DESCRIPTION
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPAccessories {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogHPSystem -Compatible -Component 'Accessories Firmware and Driver' | Sort-Object -Property CreationDate -Descending
    }
    else {
      Get-CatalogHPSystem -Component 'Accessories Firmware and Driver' | Sort-Object -Property CreationDate -Descending
    }
}