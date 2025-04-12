function Get-OSDModuleVersion {
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.Version
}