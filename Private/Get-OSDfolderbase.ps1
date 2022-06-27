function Get-CurrentModuleBase
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
    )

    return $MyInvocation.MyCommand.Module.ModuleBase
}