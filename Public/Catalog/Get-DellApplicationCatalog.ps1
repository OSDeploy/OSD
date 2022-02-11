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
function Get-DellApplicationCatalog {
    [CmdletBinding()]
    param (
        [switch]$Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-DellSystemCatalog -Component Application -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-DellSystemCatalog -Component Application | Sort-Object -Property ReleaseDate -Descending
    }
}