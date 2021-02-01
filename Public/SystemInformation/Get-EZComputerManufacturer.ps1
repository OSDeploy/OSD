<#
.SYNOPSIS
Returns the Computer Manufacturer

.DESCRIPTION
Returns the Computer Manufacturer

.LINK
https://osd.osdeploy.com/module/functions/system-information/get-ezcomputermanufacturer

.NOTES
21.1.28    Initial Release
#>
function Get-EZComputerManufacturer {
    [CmdletBinding()]
    Param ()

    begin {
        $Manufacturer = Get-CimInstance -ClassName CIM_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Manufacturer
    }
    process {
        if ($null -eq $Manufacturer) {$Manufacturer = 'Unknown'}
        elseif ($Manufacturer -eq '') {$Manufacturer = 'Unknown'}
        elseif ($Manufacturer -match 'Dell') {$Manufacturer = 'Dell'}
        elseif ($Manufacturer -match 'Lenovo') {$Manufacturer = 'Lenovo'}
        elseif ($Manufacturer -match 'Hewlett Packard') {$Manufacturer = 'HP'}
        elseif ($Manufacturer -match 'HP') {$Manufacturer = 'HP'}
        elseif ($Manufacturer -match 'to be filled') {$Manufacturer = 'Generic'}
    }
    end {
        Return $Manufacturer
    }
}