function Get-OSDCloudOSNames {
    <#
    .SYNOPSIS
    Returns the Operating Systems names used by OSDCloud

    .DESCRIPTION
    Returns the Operating Systems names used by OSDCloud

    .EXAMPLE
    Get-OSDCloudOSNames
    Returns the OSDCloud operating system name list from module resources.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    param ()

    $Global:OSDCloudOSNames = $Global:OSDModuleResource.OSDCloud.Values.Name

    $Global:OSDCloudOSNames
}
