function Get-OSDCloudOperatingSystemsIndexes {
    <#
    .SYNOPSIS
    Returns OSDCloud operating system index entries by architecture.

    .DESCRIPTION
    Reads the cached OSDCloud operating system indexes and returns index
    entries for the specified architecture.

    .PARAMETER OSArch
    Specifies the operating system architecture.
    Valid values are x64 and ARM64.

    .EXAMPLE
    Get-OSDCloudOperatingSystemsIndexes

    Returns x64 operating system index entries from cache.

    .EXAMPLE
    Get-OSDCloudOperatingSystemsIndexes -OSArch ARM64

    Returns ARM64 operating system index entries from cache.

    .OUTPUTS
    PSCustomObject

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('x64','ARM64')]
        [System.String]
        $OSArch = 'x64'
    )

    if ($OSArch -eq 'x64') {
        $Results = Get-Content -Path "$(Get-OSDModulePath)\cache\archive-cloudoperatingsystems\CloudOperatingSystemsIndexes.json" | ConvertFrom-Json
    }
    elseif ($OSArch -eq "ARM64") {
        $Results = Get-Content -Path "$(Get-OSDModulePath)\cache\archive-cloudoperatingsystems\CloudOperatingSystemsARM64Indexes.json" | ConvertFrom-Json
    }

    return $Results
}
