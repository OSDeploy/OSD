function Get-OSDModulePath {
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.ModuleBase
}