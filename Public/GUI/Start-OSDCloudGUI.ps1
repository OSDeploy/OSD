function Start-OSDCloudGUI {
    [CmdletBinding()]
    param (
        [string]$Title = 'OSDCloud',
        [string]$TitleColor = '#01786A'
    )
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudGUI"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    $Global:OSDCloudGuiBranding = @{
        Branding    = $Title
        Color       = $TitleColor
    }
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\OSDCloudGUI.ps1"
    Start-Sleep -Seconds 2
    #=======================================================================
}