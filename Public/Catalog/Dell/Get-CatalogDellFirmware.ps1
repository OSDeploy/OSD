<#
.SYNOPSIS
Returns the Firmware Component of the Dell System Catalog

.DESCRIPTION
Returns the Firmware Component of the Dell System Catalog

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogDellFirmware {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogDellSystem -Compatible -Component Firmware | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-CatalogDellSystem -Component Firmware | Sort-Object -Property ReleaseDate -Descending
    }
}