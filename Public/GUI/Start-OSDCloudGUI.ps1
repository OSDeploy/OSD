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
function Start-OSDCloudTasks {
    [CmdletBinding()]
    param (
        [string]$Tasks = 'https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/Tasks/OSDCloudTasks.json'
    )
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudTasks"
    #=======================================================================
    #   Test
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor DarkGray "Tasks: $Tasks"
    if (Test-WebConnection -Uri $Tasks) {
        $Global:PSScriptGui = Invoke-RestMethod -Uri $Tasks
        $PSScriptGuiTitle = $MyInvocation.MyCommand
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\PSScriptGui.ps1"
    }
    else {
        Write-Warning "Unable to connect to Tasks Json"
        Write-Warning "Make sure you have an Internet connection and are not Firewall blocked"
    }
    #=======================================================================
}