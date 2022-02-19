function Start-DiskImageFFU {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #	Run
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\DiskImageFFU.ps1"
    #=======================================================================
}