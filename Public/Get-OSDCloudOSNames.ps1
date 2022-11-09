function Get-OSDCloudOSNames {
    <#
    .SYNOPSIS
    Returns the Operating Systems names used by OSDCloud

    .DESCRIPTION
    Returns the Operating Systems names used by OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    $Global:OSDCloudOSNames = @(
        'Windows 11 22H2 x64',
        'Windows 11 21H2 x64',
        'Windows 10 22H2 x64',
        'Windows 10 21H2 x64',
        'Windows 10 21H1 x64',
        'Windows 10 20H2 x64',
        'Windows 10 2004 x64',
        'Windows 10 1909 x64',
        'Windows 10 1903 x64',
        'Windows 10 1809 x64'
    )

    $Global:OSDCloudOSNames
}