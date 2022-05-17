function Start-OSDCloudGUI {
    <#
    .SYNOPSIS
    OSDCloud imaging using the command line

    .DESCRIPTION
    OSDCloud imaging using the command line

    .EXAMPLE
    Start-OSDCloudGUI

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        #The custom Brand for OSDCloudGUI
        [Alias('BrandingTitle')]
        [System.String]$Brand = 'OSDCloud',
        
        #Color for the OSDCloudGUI Brand
        [Alias('BrandingColor')]
        [System.String]$Color = '#01786A'
    )
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
function Start-AzOSDCloudGUI {
    <#
    .SYNOPSIS
    AzOSDCloudGUI imaging using the command line

    .DESCRIPTION
    AzOSDCloudGUI imaging using the command line

    .EXAMPLE
    Start-AzOSDCloudGUI

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-AzOSDCloudGUI"
    if ($Global:AzOSDCloudBlobImage) {
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\AzOSDCloudGUI\MainWindow.ps1"
        Start-Sleep -Seconds 2

        if ($Global:AzOSDCloudImage) {
            Invoke-OSDCloud
        }
        else {
            Write-Warning "Unable to get a Windows Image from Start-AzOSDCloudGUI to handoff to Invoke-OSDCloud"
        }
    }
    else {
        Write-Warning 'Unable to find a WIM on any of the OSDCloud Azure Storage Containers'
        Write-Warning 'Make sure you have a WIM Windows Image in the OSDCloud Azure Storage Container'
        Write-Warning 'Make sure this user has the Azure Storage Blob Data Reader role to the OSDCloud Container'
        Write-Warning 'You may need to execute Get-AzOSDCloudBlobImage then Start-AzOSDCloud'
    }
    #================================================
}