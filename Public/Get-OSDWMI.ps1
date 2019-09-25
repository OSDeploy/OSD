function Get-OSDWMI {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
        'BaseBoard',`
        'BIOS',`
        'ComputerSystem',`
        'NetworkAdapter',`
        'NetworkAdapterConfiguration',`
        'OperatingSystem',`
        'Processor',`
        'SystemEnclosure'
        )][string]$Property
    )

    $Value = (Get-CimInstance -ClassName Win32_$Property | Select-Object -Property *)
    Return $Value
}