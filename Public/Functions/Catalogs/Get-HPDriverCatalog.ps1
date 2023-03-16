<#
.SYNOPSIS
Returns the Driver Component of the HP System Catalog

.DESCRIPTION
Returns the Driver Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPDriverCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-HPSystemCatalog -Component Driver -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-HPSystemCatalog -Component Driver | Sort-Object -Property CreationDate -Descending
    }
}