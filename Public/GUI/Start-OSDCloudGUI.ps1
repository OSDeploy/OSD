function Start-OSDCloudGUI {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudGUI"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\OSDCloudGUI.ps1"
    Start-Sleep -Seconds 2
    #=======================================================================
}