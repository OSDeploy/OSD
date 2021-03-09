<#
.SYNOPSIS
This will return the latest compatible BIOS Update for your system as a PowerShell Object

.DESCRIPTION
This will return the latest compatible BIOS Update for your system as a PowerShell Object
Shortcut for Get-DellCatalogPC -Component BIOS -Compatible

.LINK
https://osd.osdeploy.com/module/functions/dell/get-mydellbios

.NOTES
21.3.5  Resolved issue with multiple objects
21.3.4  Initial Release
#>
function Get-MyDellBios {
    [CmdletBinding()]
    param ()
    #===================================================================================================
    #   Require Dell Computer
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Break
    }
    #===================================================================================================
    #   Current System Information
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #===================================================================================================
    #   Get-DellCatalogPC
    #===================================================================================================

    $GetMyDellBios = Get-DellCatalogPC -Component BIOS -Compatible | Sort-Object ReleaseDate -Descending | Select-Object -First 1

    Write-Verbose "You are currently running BIOS version $BIOSVersion" -Verbose

    Return $GetMyDellBios
}