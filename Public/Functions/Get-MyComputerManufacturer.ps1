function Get-MyComputerManufacturer {
<#
.SYNOPSIS
Gets MyComputerManufacturer information.

.DESCRIPTION
Returns MyComputerManufacturer data for the current system or OSD session context.

.PARAMETER Brief
Specifies the Brief to use when running Get-MyComputerManufacturer.

.EXAMPLE
Get-MyComputerManufacturer -B <value>
Demonstrates a common way to run Get-MyComputerManufacturer.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Brief
    )
    #Should always opt for CIM over WMI
    $MyComputerManufacturer = ((Get-CimInstance -ClassName CIM_ComputerSystem).Manufacturer).Trim()
    Write-Verbose $MyComputerManufacturer

    #Sometimes vendors are not always consistent, i.e. Dell or Dell Inc.
    #So need to detmine the Brief Manufacturer to normalize results
    if ($Brief -eq $true) {
        if ($MyComputerManufacturer -match 'Dell') {$MyComputerManufacturer = 'Dell'}
        if ($MyComputerManufacturer -match 'Lenovo') {$MyComputerManufacturer = 'Lenovo'}
        if ($MyComputerManufacturer -match 'Hewlett') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'Packard') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'HP') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'Microsoft') {$MyComputerManufacturer = 'Microsoft'}
        if ($MyComputerManufacturer -match 'Panasonic') {$MyComputerManufacturer = 'Panasonic'}
        if ($MyComputerManufacturer -match 'to be filled') {$MyComputerManufacturer = 'OEM'}
        if ($null -eq $MyComputerManufacturer) {$MyComputerManufacturer = 'OEM'}
    }
    $MyComputerManufacturer
}
