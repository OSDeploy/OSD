function Get-MyDellApplications {
    [CmdletBinding()]
    param ()
    #=================================================
    #   Current System Information
    #=================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()

    $GetDellCatalogPC = Get-DellSystemMasterCatalog -UpdateType Application

    $GetMyDellApplications = $GetDellCatalogPC | Where-Object {$_.SupportedSystemID -contains $SystemSKU}

    Return $GetMyDellApplications | Sort-Object ReleaseDate -Descending
}