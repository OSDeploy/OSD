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
		[System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDMasterCatalogHPSystem -Component Software -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-OSDMasterCatalogHPSystem -Component Software | Sort-Object -Property CreationDate -Descending
    }
}