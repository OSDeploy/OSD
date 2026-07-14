function Get-MyBiosVersion {
<#
.SYNOPSIS
Gets MyBiosVersion information.

.DESCRIPTION
Returns MyBiosVersion data for the current system or OSD session context.

.EXAMPLE
Get-MyBiosVersion
Demonstrates a common way to run Get-MyBiosVersion.

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param ()

    $CimBios = Get-CimInstance -ClassName Win32_BIOS
    if ($CimBios.Manufacturer -match 'Lenovo') {
        $SystemBiosMajorVersion = $CimBios.SystemBiosMajorVersion
        $SystemBiosMinorVersion = $CimBios.SystemBiosMinorVersion
        $MyBiosVersion = "$SystemBiosMajorVersion.$SystemBiosMinorVersion"
        Return $MyBiosVersion
    }
    else {
        ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
    }
}
