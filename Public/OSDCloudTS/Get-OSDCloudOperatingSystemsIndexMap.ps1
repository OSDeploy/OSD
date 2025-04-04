function Get-OSDCloudOperatingSystemsIndexMap {
    <#
    .SYNOPSIS
    Returns the Operating System Indexes used by OSDCloud

    .DESCRIPTION
    Returns the Operating System Indexes used by OSDCloud

    .PARAMETER OSArch
    Specifies the OS architecture to filter results. Valid values are 'x64' and 'ARM64'.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('x64', 'ARM64')]
        [System.String]
        $OSArch = 'x64'
    )

    $indexMapPath = "$(Get-OSDCatsPath)\osd-module\CloudOperatingIndexMap.json"
    $Results = Get-Content -Path $indexMapPath | ConvertFrom-Json
    $Results = $Results | Where-Object { $_.Architecture -eq $OSArch }
    
    return $Results
}