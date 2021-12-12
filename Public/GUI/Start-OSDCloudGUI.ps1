function Start-OSDCloudGUI {
    [CmdletBinding()]
    param (
        [Alias('BrandingTitle')]
        [string]$Brand = 'OSDCloud',
        [Alias('BrandingColor')]
        [string]$Color = '#01786A'
    )
    #================================================
    #   Header
    #================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudGUI"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #================================================
    #   Branding
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title   = $Brand
        Color   = $Color
    }
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudGUI\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}