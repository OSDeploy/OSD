<#
.SYNOPSIS
Returns the Computer Model

.DESCRIPTION
Returns the Computer Model

.LINK
https://osd.osdeploy.com/module/functions/get-ezcomputermodel

.NOTES
21.1.28    Initial Release
#>
function Get-EZComputerModel {
    [CmdletBinding()]
    Param ()

    begin {
        if ($(Get-EZComputerManufacturer) -match 'Lenovo') {
            $Model = Get-CimInstance -ClassName Win32_ComputerSystemProduct -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
        } else {
            $Model = Get-CimInstance -ClassName CIM_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Model
        }
    }
    process {
        if ($null -eq $Model) {$Model = 'Unknown'}
        elseif ($Model -eq '') {$Model = 'Unknown'}
        elseif ($Model -match 'to be filled') {$Model = 'Generic'}
    }
    end {
        Return $Model
    }
}