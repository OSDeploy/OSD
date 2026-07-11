<#
.SYNOPSIS
Returns the Firmware Component of the Dell System Catalog

.DESCRIPTION
Returns the Firmware Component of the Dell System Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellFirmwareCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-DellSystemCatalog -Component Firmware -Compatible | Sort-Object -Property ReleaseDate -Descending
    }
    else {
        Get-DellSystemCatalog -Component Firmware | Sort-Object -Property ReleaseDate -Descending
    }
}