function Get-MyDellDrivers {
    [CmdletBinding()]
    param ()
    #===================================================================================================
    #   Current System Information
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()

    $GetDellCatalogPC = Get-DellCatalogPC -UpdateType Driver

    $GetMyDellDrivers = $GetDellCatalogPC | Where-Object {$_.SupportedSystemID -contains $SystemSKU}

    $GetMyDellDrivers = $GetMyDellDrivers | Sort-Object SupportedDevices, Version -Descending | Group-Object SupportedDevices | ForEach-Object {$_.Group | Select-Object -First 1}

    Return $GetMyDellDrivers | Sort-Object ReleaseDate -Descending
}