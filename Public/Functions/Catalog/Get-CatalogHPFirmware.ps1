<#
.SYNOPSIS
Returns the Firmware Component of the HP System Catalog

.DESCRIPTION
Returns the Firmware Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-CatalogHPFirmware {
    [CmdletBinding()]
    param (
		[System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDCatalogHPSystem -Component Firmware -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-OSDCatalogHPSystem -Component Firmware | Sort-Object -Property CreationDate -Descending
    }
}