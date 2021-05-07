<#
.SYNOPSIS
Returns the Firmware Component of the HP System Catalog

.DESCRIPTION
Returns the Firmware Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPFirmware {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogHPSystem -Compatible -Component Firmware | Sort-Object -Property CreationDate -Descending
    }
    else {
      Get-CatalogHPSystem -Component Firmware | Sort-Object -Property CreationDate -Descending
    }
}