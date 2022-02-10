<#
.SYNOPSIS
Returns the Driver Component of the Dell System Catalog

.DESCRIPTION
Returns the Driver Component of the Dell System Catalog

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogDellDriver {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-CatalogDellSystem -Compatible -Component Driver | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-CatalogDellSystem -Component Driver | Sort-Object -Property ReleaseDate -Descending
    }
}