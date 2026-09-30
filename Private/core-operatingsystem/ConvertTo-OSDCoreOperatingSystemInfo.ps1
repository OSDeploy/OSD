function ConvertTo-OSDCoreOperatingSystemInfo {
    <#
    .SYNOPSIS
    Converts a Windows build number to operating system release information.

    .DESCRIPTION
    Maps a known five-digit Windows build number to the operating system name,
    release version, and combined operating system label used by OSDCloud catalog
    records. Unknown build numbers return no result.

    .PARAMETER OSBuild
    Five-digit Windows build number to convert.

    .EXAMPLE
    ConvertTo-OSDCoreOperatingSystemInfo -OSBuild '26300'

    Returns Windows 11 26H2 operating system release information.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject
    Operating system release information for a known build number.

    .LINK
    https://www.osdeploy.com/

    .NOTES
    Author: OSDeploy
    2026-09-25 - Initial version
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^\d{5}$')]
        [string]$OSBuild
    )

    $Error.Clear()

    switch ($OSBuild) {
        '19045' { $OSName = 'Windows 10'; $OSVersion = '22H2' }
        '22000' { $OSName = 'Windows 11'; $OSVersion = '21H2' }
        '22621' { $OSName = 'Windows 11'; $OSVersion = '22H2' }
        '22631' { $OSName = 'Windows 11'; $OSVersion = '23H2' }
        '26100' { $OSName = 'Windows 11'; $OSVersion = '24H2' }
        '26200' { $OSName = 'Windows 11'; $OSVersion = '25H2' }
        '26300' { $OSName = 'Windows 11'; $OSVersion = '26H2' }
        '28000' { $OSName = 'Windows 11'; $OSVersion = '26H1' }
        default { return }
    }

    return [pscustomobject]@{
        OperatingSystem = "$OSName $OSVersion"
        OSName          = $OSName
        OSVersion       = $OSVersion
    }
}
