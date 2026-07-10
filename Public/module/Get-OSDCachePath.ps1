function Get-OSDCachePath {
    <#
    .SYNOPSIS
    Returns the OSD module cache directory path.

    .DESCRIPTION
    Resolves the module base path from the current command context and appends
    the cache child directory name. This returns the expected cache folder path
    for the installed OSD module.

    .OUTPUTS
    System.String. The full path to the module cache directory.

    .EXAMPLE
    Get-OSDCachePath

    Returns the full path to the OSD module cache directory.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Initial help block created
    #>
    [CmdletBinding()]
    param ()

    return (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'cache')
}
