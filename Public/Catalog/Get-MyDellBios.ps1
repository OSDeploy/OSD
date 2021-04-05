<#
.SYNOPSIS
This will return the latest compatible BIOS Update for your system as a PowerShell Object

.DESCRIPTION
This will return the latest compatible BIOS Update for your system as a PowerShell Object
Shortcut for Get-CatalogDellSystem -Component BIOS -Compatible

.LINK
https://osd.osdeploy.com/module/functions/dell/get-mydellbios

.NOTES
21.3.11 Pulling data from Local due to issues with the Dell site being down
21.3.5  Resolved issue with multiple objects
21.3.4  Initial Release
#>
function Get-MyDellBios {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = 'SilentlyContinue'
    #=======================================================================
    #   Require Dell Computer
    #=======================================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Return $null
    }
    #=======================================================================
    #   Current System Information
    #=======================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #=======================================================================
    #   Get-CatalogDellSystem
    #=======================================================================
    #$GetMyDellBios = Get-CatalogDellSystem -Component BIOS -Compatible | Sort-Object ReleaseDate -Descending | Select-Object -First 1
    $GetMyDellBIOS = Import-Clixml "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\OSD-Dell-CatalogPC-BIOS.xml" | Sort-Object ReleaseDate -Descending
    $GetMyDellBIOS | Add-Member -MemberType NoteProperty -Name 'Flash64W' -Value 'https://github.com/OSDeploy/OSDCloud/raw/main/BIOS/Flash64W_Ver3.3.8.cab'
    #=======================================================================
    #   Filter Compatible
    #=======================================================================
    Write-Verbose "Filtering XML for items compatible with SystemSKU $SystemSKU"
    $GetMyDellBIOS = $GetMyDellBIOS | `
        Where-Object {$_.SupportedSystemID -contains $SystemSKU}
    #=======================================================================
    #   Pick and Sort
    #=======================================================================
    $GetMyDellBios = $GetMyDellBios | Sort-Object ReleaseDate -Descending | Select-Object -First 1
    #Write-Verbose "You are currently running Dell Bios version $BIOSVersion" -Verbose
    #=======================================================================
    #   Return
    #=======================================================================
    Return $GetMyDellBios
}