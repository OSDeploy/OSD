function Start-DiskImageGUI {
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
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\DiskImageGUI.ps1"
    #=======================================================================
}