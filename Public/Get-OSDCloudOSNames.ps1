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

    $Global:OSDCloudOSNames = $Global:OSDModuleResource.OSDCloud.Values.Name

    $Global:OSDCloudOSNames
}