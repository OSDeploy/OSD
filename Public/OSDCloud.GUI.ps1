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
function Start-OSDCloudGUIDev {
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
        [System.String]$Brand = 'OSDCloudDev',
        
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
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudDev\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}
function Start-OSDCloudAzure {
    <#
    .SYNOPSIS
    Start OSDCloud Azure

    .DESCRIPTION
    Start OSDCloud Azure

    .EXAMPLE
    Start-OSDCloudAzure

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
        Write-Host -ForegroundColor Green "Start-OSDCloudAzure"
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudAzure\MainWindow.ps1"
        Start-Sleep -Seconds 2

        if ($Global:StartOSDCloud.AzOSDCloudImage) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            Invoke-OSDCloud
        }
        else {
            Write-Warning "Unable to get a Windows Image from Start-OSDCloudAzure to handoff to Invoke-OSDCloud"
        }
    }
    else {
        Invoke-Expression (Invoke-RestMethod azgui.osdcloud.com)
    }
}
function Start-OSDCloudREAzure {
    <#
    .SYNOPSIS
    Start OSDCloudRE Azure

    .DESCRIPTION
    Start OSDCloudRE Azure

    .EXAMPLE
    Start-OSDCloudREAzure

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
        Write-Host -ForegroundColor Green "Start-OSDCloudREAzure"
        & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudREAzure\MainWindow.ps1"
        Start-Sleep -Seconds 2

        if ($Global:StartOSDCloud.AzOSDCloudBootImage) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            #Invoke-OSDCloud
        }
        else {
            Write-Warning "Unable to get an ISO Boot Image from Start-OSDCloudREAzure"
        }
    }
    else {
        Invoke-Expression (Invoke-RestMethod azgui.osdcloud.com)
    }
}
