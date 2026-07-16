function Get-OSDModuleVersion {
    <#
    .SYNOPSIS
    Returns the version of the loaded OSD module.

    .DESCRIPTION
    Uses the current command invocation context to return the module version
    object for the loaded OSD module.

    .OUTPUTS
    System.Version. The module version.

    .EXAMPLE
    Get-OSDModuleVersion

    Returns the currently loaded OSD module version.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Initial help block created
    #>
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.Version
}
