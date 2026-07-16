function Get-OSDModulePath {
    <#
    .SYNOPSIS
    Returns the base path of the loaded OSD module.

    .DESCRIPTION
    Uses the current command invocation context to return the module base path
    where the OSD module is installed or loaded from.

    .OUTPUTS
    System.String. The full module base path.

    .EXAMPLE
    Get-OSDModulePath

    Returns the OSD module installation path.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Initial help block created
    #>
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.ModuleBase
}
