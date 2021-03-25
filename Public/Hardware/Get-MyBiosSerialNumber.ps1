<#
.SYNOPSIS
Returns the Bios SerialNumber

.DESCRIPTION
Returns the Bios SerialNumber

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyBiosSerialNumber {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    $GetMyBiosSerialNumber = ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()

    if ($Brief -eq $true) {
        if ($null -eq $GetMyBiosSerialNumber) {$GetMyBiosSerialNumber = 'Unknown'}
        elseif ($GetMyBiosSerialNumber -eq '') {$GetMyBiosSerialNumber = 'Unknown'}

        #Allow only a-z A-Z 0-9
        $GetMyBiosSerialNumber = $GetMyBiosSerialNumber -replace '_'
        $GetMyBiosSerialNumber = $GetMyBiosSerialNumber -replace '\W'
    }

    $GetMyBiosSerialNumber
}