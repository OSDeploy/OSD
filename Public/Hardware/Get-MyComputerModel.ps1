<#
.SYNOPSIS
Returns the Computer Model

.DESCRIPTION
Returns the Computer Model

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyComputerModel {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    if ((Get-MyComputerManufacturer -Brief) -match 'Lenovo') {
        $GetMyComputerModel = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).Trim()
    } else {
        $GetMyComputerModel = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    }

    if ($Brief -eq $true) {
        if ($null -eq $GetMyComputerModel) {$GetMyComputerModel = 'Unknown'}
        elseif ($GetMyComputerModel -eq '') {$GetMyComputerModel = 'Unknown'}
        elseif ($GetMyComputerModel -match 'to be filled') {$GetMyComputerModel = 'Generic'}
    }

    Return $GetMyComputerModel
}