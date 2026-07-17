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
    - amd64
    - arm64

    .EXAMPLE
    Get-OSDCloudOperatingSystems

    Returns x64 operating system entries.

    .EXAMPLE
    Get-OSDCloudOperatingSystems -OSArch arm64

    Returns ARM64 operating system entries.

    .EXAMPLE
    Get-OSDCloudOperatingSystems -OSArch amd64

    Returns x64/amd64 operating system entries.

    .INPUTS
    None. You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject
    One or more operating system entries returned by Get-OSDCoreOperatingSystems.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    25.2.17 Removed unnecessary Default ParameterSet Name
    26.6.24 Refined comment-based help text
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param (
        # Supported values are normalized so x64 and amd64 are interchangeable.
        [ValidateSet('x64', 'amd64', 'arm64')]
        [System.String]
        $OSArch = $env:PROCESSOR_ARCHITECTURE
    )

    try {
        $allOperatingSystems = Get-OSDCoreOperatingSystems -ErrorAction Stop
    }
    catch {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to retrieve operating system data from Get-OSDCoreOperatingSystems. $($_.Exception.Message)"
    }

    if (-not $allOperatingSystems) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No operating system data was returned by Get-OSDCoreOperatingSystems."
        return @()
    }

    $requestedArch = if ([string]::IsNullOrWhiteSpace($OSArch)) {
        $env:PROCESSOR_ARCHITECTURE
    }
    else {
        $OSArch
    }

    $normalizedArch = switch ($requestedArch.ToLowerInvariant()) {
        'x64'     { 'x64' }
        'amd64'   { 'x64' }
        'arm64'   { 'arm64' }
        default {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unsupported architecture '$requestedArch'. Use x64, amd64, or arm64."
        }
    }

    $allowedArchitectures = if ($normalizedArch -in @('x64', 'amd64')) {
        @('x64', 'amd64')
    }
    else {
        @('arm64')
    }

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Requested architecture '$requestedArch' normalized to '$normalizedArch'."

    $results = $allOperatingSystems |
        Where-Object { $_.Architecture -and $_.Architecture.ToLowerInvariant() -in $allowedArchitectures } |
        Sort-Object -Property Name

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Returning $(@($results).Count) operating system entries."

    return $results
}
