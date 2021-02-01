<#
.SYNOPSIS
Returns the Computer SerialNumber

.DESCRIPTION
Returns the Computer SerialNumber

.LINK
https://osd.osdeploy.com/module/functions/system-information/get-ezcomputerserialnumber

.NOTES
21.1.28    Initial Release
#>
function Get-EZComputerSerialNumber {
    [CmdletBinding()]
    Param ()

    begin {
        $SerialNumber = Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SerialNumber
    }
    process {
        if ($null -eq $SerialNumber) {$SerialNumber = 'Unknown'}
        elseif ($SerialNumber -eq '') {$SerialNumber = 'Unknown'}

        $SerialNumber = $SerialNumber -replace ":", ""
    }
    end {
        Return $SerialNumber
    }
}