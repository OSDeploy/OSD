function Get-OSDCloudOperatingSystems {
    <#
    .SYNOPSIS
    Gets OSDCloud operating system entries for a specific architecture.

    .DESCRIPTION
    Queries OSDCloud operating system data and returns entries that match the
    requested operating system architecture.

    .PARAMETER OSArch
    Specifies the operating system architecture to return.

    Valid values:
    - x64
    - arm64

    .EXAMPLE
    Get-OSDCloudOperatingSystems

    Returns x64 operating system entries.

    .EXAMPLE
    Get-OSDCloudOperatingSystems -OSArch arm64

    Returns ARM64 operating system entries.

    .INPUTS
    None. You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject
    One or more operating system entries returned by Get-OSDCoreOperatingSystems.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    25.2.17 Removed unnecessary Default ParameterSet Name
    26.6.24 Refined comment-based help text
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param (
        [ValidateSet('x64', 'arm64')]
        [System.String]
        $OSArch = 'x64'
    )

    try {
        $allOperatingSystems = Get-OSDCoreOperatingSystems -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve operating system data from Get-OSDCoreOperatingSystems. $($_.Exception.Message)"
    }

    if (-not $allOperatingSystems) {
        Write-Verbose "No operating system data was returned by Get-OSDCoreOperatingSystems."
        return @()
    }

    $normalizedArch = $OSArch.ToLowerInvariant()
    $results = $allOperatingSystems |
        Where-Object { $_.Architecture -and $_.Architecture.ToLowerInvariant() -eq $normalizedArch } |
        Sort-Object -Property Name

    return $results
}
