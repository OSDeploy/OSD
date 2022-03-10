<#
.SYNOPSIS
Returns the Application Component of the Dell System Catalog

.DESCRIPTION
Returns the Application Component of the Dell System Catalog

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-CatalogDellApplication {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-OSDCatalogDellSystem -Component Application -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-OSDCatalogDellSystem -Component Application | Sort-Object -Property ReleaseDate -Descending
    }
}