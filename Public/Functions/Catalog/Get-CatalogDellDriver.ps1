<#
.SYNOPSIS
Returns the Driver Component of the Dell System Catalog

.DESCRIPTION
Returns the Driver Component of the Dell System Catalog

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-CatalogDellDriver {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDCatalogDellSystem -Component Driver -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-OSDCatalogDellSystem -Component Driver | Sort-Object -Property ReleaseDate -Descending
    }
}