function Start-OSDCloudGUI {
    [CmdletBinding()]
    param (
        [string]$BrandingTitle = 'OSDCloud',
        [string]$BrandingColor = '#01786A'
    )
    #================================================
    #   Header
    #================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Green "Start-OSDCloudGUI"
    Write-Host -ForegroundColor DarkGray "================================================"
    #================================================
    #   Branding
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title   = $BrandingTitle
        Color   = $BrandingColor
    }
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\OSDCloudGUI.ps1"
    Start-Sleep -Seconds 2
    #================================================
}