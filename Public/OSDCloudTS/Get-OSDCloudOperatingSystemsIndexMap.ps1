function Get-OSDCloudOperatingSystemsIndexMap {
    <#
    .SYNOPSIS
    Returns OSDCloud operating system index map entries by architecture.

    .DESCRIPTION
    Reads the cached OSDCloud operating system index map and returns entries
    filtered by the specified architecture.

    .PARAMETER OSArch
    Specifies the operating system architecture.
    Valid values are x64 and ARM64.

    .EXAMPLE
    Get-OSDCloudOperatingSystemsIndexMap

    Returns x64 index map entries from cache.

    .EXAMPLE
    Get-OSDCloudOperatingSystemsIndexMap -OSArch ARM64

    Returns ARM64 index map entries from cache.

    .OUTPUTS
    PSCustomObject

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('x64', 'ARM64')]
        [System.String]
        $OSArch = 'x64'
    )

    $indexMapPath = "$(Get-OSDModulePath)\cache\archive-cloudoperatingindexmap\CloudOperatingIndexMap.json"
    $Results = Get-Content -Path $indexMapPath | ConvertFrom-Json
    $Results = $Results | Where-Object { $_.Architecture -eq $OSArch }

    return $Results
}
