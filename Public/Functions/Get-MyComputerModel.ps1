function Get-MyComputerModel {
<#
.SYNOPSIS
Gets MyComputerModel information.

.DESCRIPTION
Returns MyComputerModel data for the current system or OSD session context.

.PARAMETER Brief
Specifies the Brief to use when running Get-MyComputerModel.

.EXAMPLE
Get-MyComputerModel -B <value>
Demonstrates a common way to run Get-MyComputerModel.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        #Normalize the Return
        [System.Management.Automation.SwitchParameter]$Brief
    )

    $MyComputerManufacturer = Get-MyComputerManufacturer -Brief

    if ($MyComputerManufacturer -eq 'Lenovo') {
        $MyComputerModel = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).Trim()
    }
    else {
        $MyComputerModel = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    }
    Write-Verbose $MyComputerModel

    if ($Brief -eq $true) {
        if ($MyComputerModel -eq '') {$MyComputerModel = 'OEM'}
        if ($MyComputerModel -match 'to be filled') {$MyComputerModel = 'OEM'}
        if ($null -eq $MyComputerModel) {$MyComputerModel = 'OEM'}
    }
    $MyComputerModel
}
