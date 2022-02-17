<#
.SYNOPSIS
Returns the Driver Component of the HP System Catalog

.DESCRIPTION
Returns the Driver Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPDriverCatalog {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-HPSystemCatalogMaster -Component Driver -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-HPSystemCatalogMaster -Component Driver | Sort-Object -Property CreationDate -Descending
    }
}