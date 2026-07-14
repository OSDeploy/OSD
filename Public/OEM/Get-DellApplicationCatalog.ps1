<#
.SYNOPSIS
Returns the Application Component of the Dell System Catalog

.DESCRIPTION
Returns the Application Component of the Dell System Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellApplicationCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-DellSystemCatalog -Component Application -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-DellSystemCatalog -Component Application | Sort-Object -Property ReleaseDate -Descending
    }
}