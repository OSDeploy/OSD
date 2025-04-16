function Get-OSDCachePath {
    [CmdletBinding()]
    param ()

    return (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'cache')
}