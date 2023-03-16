<#
.SYNOPSIS
Returns the BIOS Component of the Dell System Catalog

.DESCRIPTION
Returns the BIOS Component of the Dell System Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellBiosCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-DellSystemCatalog -Component BIOS -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-DellSystemCatalog -Component BIOS | Sort-Object -Property ReleaseDate -Descending
    }
}