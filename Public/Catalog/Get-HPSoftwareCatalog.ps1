<#
.SYNOPSIS
Returns the Software Component of the HP System Catalog

.DESCRIPTION
Returns the Software Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPSoftwareCatalog {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-HPSystemCatalog -Component Software -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-HPSystemCatalog -Component Software | Sort-Object -Property CreationDate -Descending
    }
}