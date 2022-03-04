<#
.SYNOPSIS
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.DESCRIPTION
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPAccessoryCatalog {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDMasterCatalogHPSystem -Component 'Accessories Firmware and Driver' -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-OSDMasterCatalogHPSystem -Component 'Accessories Firmware and Driver' | Sort-Object -Property CreationDate -Descending
    }
}