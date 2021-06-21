function Start-CaptureFFU {
    [CmdletBinding()]
    param ()

    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\CaptureFFU.ps1"
}