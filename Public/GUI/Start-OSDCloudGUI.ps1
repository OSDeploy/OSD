function Start-OSDCloudGUI {
    [CmdletBinding()]
    param ()

    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\OSDCloudGUI.ps1"
}