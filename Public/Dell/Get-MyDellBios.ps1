function Get-MyDellBios {
    [CmdletBinding()]
    param ()
    #===================================================================================================
    #   Current System Information
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #===================================================================================================
    #   Get-DellCatalogPC
    #===================================================================================================

    $GetMyDellBios = Get-DellCatalogPC -Component BIOS -Compatible

    Write-Verbose "You are currently running BIOS version $BIOSVersion" -Verbose

    Return $GetMyDellBios
}