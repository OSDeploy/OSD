function Start-AutopilotGUI {
    [CmdletBinding()]
    param ()

    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\AutopilotGUI.ps1"
}