<#
.SYNOPSIS
Returns the Firmware Component of the Dell System Catalog

.DESCRIPTION
Returns the Firmware Component of the Dell System Catalog

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-DellFirmwareCatalog {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-DellSystemCatalog -Component Firmware -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-DellSystemCatalog -Component Firmware | Sort-Object -Property ReleaseDate -Descending
    }
}