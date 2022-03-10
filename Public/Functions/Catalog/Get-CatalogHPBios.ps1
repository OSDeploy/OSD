<#
.SYNOPSIS
Returns the BIOS Component of the HP System Catalog

.DESCRIPTION
Returns the BIOS Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-CatalogHPBios {
    [CmdletBinding()]
    param (
		[System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDCatalogHPSystem -Component BIOS -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-OSDCatalogHPSystem -Component BIOS | Sort-Object -Property CreationDate -Descending
    }
}