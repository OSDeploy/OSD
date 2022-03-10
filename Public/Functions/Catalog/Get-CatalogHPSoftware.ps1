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
function Get-CatalogHPSoftware {
    [CmdletBinding()]
    param (
		[System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDCatalogHPSystem -Component Software -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-OSDCatalogHPSystem -Component Software | Sort-Object -Property CreationDate -Descending
    }
}