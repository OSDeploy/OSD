<#
.SYNOPSIS
Returns the Bios Version

.DESCRIPTION
Returns the Bios Version

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyBiosVersion {
    [CmdletBinding()]
    param ()

    Return ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
}