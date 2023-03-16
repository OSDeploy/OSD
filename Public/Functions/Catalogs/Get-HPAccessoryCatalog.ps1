<#
.SYNOPSIS
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.DESCRIPTION
Returns the 'Accessories Firmware and Driver' Component of the HP System Catalog

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
Baseboard Product value

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPAccessoryCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible
    )
	
    if ($PSBoundParameters.ContainsKey('Compatible')) {
	    Get-HPSystemCatalog -Component 'Accessories Firmware and Driver' -Compatible | Sort-Object -Property CreationDate -Descending
    }
    else {
        Get-HPSystemCatalog -Component 'Accessories Firmware and Driver' | Sort-Object -Property CreationDate -Descending
    }
}