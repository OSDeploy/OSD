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
        [System.String]$Color = '#003E92'
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
function Start-HPOSDCloudGUI {
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
        [System.String]$Brand = 'HPOSDCloud',
        
        #Color for the OSDCloudGUI Brand
        [Alias('BrandingColor')]
        [System.String]$Color = '#003E92'
    )
    #================================================
    #   Branding
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title   = $Brand
        Color   = $Color
    }
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\HPOSDCloudGUI\MainWindow.ps1"
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
    param (
        [System.Management.Automation.SwitchParameter]
        #Forces a reconnection to azgui.osdcloud.com
        $Force
    )

    if ($Force) {
        $Force = $false
        $Global:AzOSDCloudBlobImage = $null
    }

    if ($Global:AzOSDCloudBlobImage) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Start-AzOSDCloudGUI"
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\AzOSDCloudGUI\MainWindow.ps1"
        Start-Sleep -Seconds 2

        if ($Global:StartOSDCloud.AzOSDCloudImage) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            Invoke-OSDCloud
        }
        else {
            Write-Warning "Unable to get a Windows Image from Start-AzOSDCloudGUI to handoff to Invoke-OSDCloud"
        }
    }
    else {
        Invoke-Expression (Invoke-RestMethod azgui.osdcloud.com)
    }
}
function Start-AzOSDCloudRE {
    <#
    .SYNOPSIS
    AzOSDCloudRE imaging using the command line

    .DESCRIPTION
    AzOSDCloudRE imaging using the command line

    .EXAMPLE
    Start-AzOSDCloudRE

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Forces a reconnection to azgui.osdcloud.com
        $Force
    )

    if ($Force) {
        $Force = $false
        $Global:AzOSDCloudBlobBootImage = $null
    }

    if ($Global:AzOSDCloudBlobBootImage) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Start-AzOSDCloudRE"
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\AzOSDCloudRE\MainWindow.ps1"
        Start-Sleep -Seconds 2

        if ($Global:StartOSDCloud.AzOSDCloudBootImage) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            #Invoke-OSDCloud
        }
        else {
            Write-Warning "Unable to get an ISO Boot Image from Start-AzOSDCloudRE"
        }
    }
    else {
        Invoke-Expression (Invoke-RestMethod azgui.osdcloud.com)
    }
}