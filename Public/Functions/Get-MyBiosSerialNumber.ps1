function Get-MyBiosSerialNumber {
<#
.SYNOPSIS
Gets MyBiosSerialNumber information.

.DESCRIPTION
Returns MyBiosSerialNumber data for the current system or OSD session context.

.PARAMETER Brief
Specifies the Brief to use when running Get-MyBiosSerialNumber.

.EXAMPLE
Get-MyBiosSerialNumber -B <value>
Demonstrates a common way to run Get-MyBiosSerialNumber.

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Brief
    )

    $Result = ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()

    if ($Brief -eq $true) {
        if ($null -eq $Result) {$Result = 'Unknown'}
        elseif ($Result -eq '') {$Result = 'Unknown'}

        #Allow only a-z A-Z 0-9
        $Result = $Result -replace '_'
        $Result = $Result -replace '\W'
    }
    $Result
}
