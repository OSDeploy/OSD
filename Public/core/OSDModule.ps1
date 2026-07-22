function Get-OSDModuleCache {
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
    Get-OSDModuleCache

    Returns the full path to the OSD module cache directory.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Initial help block created
    #>
    [CmdletBinding()]
    param ()

    return (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'cache')
}
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
