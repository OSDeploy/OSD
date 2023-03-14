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
        [Alias('Brand')]
        [System.String]
        $BrandName = $Global:OSDModuleResource.StartOSDCloudGUI.BrandName,
        
        #Color for the OSDCloudGUI Brand
        [Alias('Color')]
        [System.String]
        $BrandColor = $Global:OSDModuleResource.StartOSDCloudGUI.BrandColor,

        #Temporary Parameter
        [System.String]
        $ComputerManufacturer = (Get-MyComputerManufacturer -Brief),

        #Temporary Parameter
        [System.String]
        $ComputerProduct = (Get-MyComputerProduct)
    )
    #================================================
    #   Defaults
    #================================================

    #================================================
    #   Brand
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title   = $BrandName
        Color   = $BrandColor
    }
    #================================================
    #   Pass Variables to OSDCloudGUI
    #================================================
    $Global:OSDCloudGUI = $null
    $Global:OSDCloudGUI = [ordered]@{
        Function                    = [System.String]'Start-OSDCloudGUI'
        LaunchMethod                = [System.String]'OSDCloudGUI'
        
        BrandName                   = [System.String]$BrandName
        BrandColor                  = [System.String]$BrandColor
        
        ComputerManufacturer        = [System.String]$ComputerManufacturer
        ComputerModel               = [System.String](Get-MyComputerModel -Brief)
        ComputerProduct             = [System.String]$ComputerProduct
        
        DriverPack                  = $null
        DriverPacks                 = [array](Get-OSDCloudDriverPacks)
        DriverPackName              = $null
        
        IsOnBattery                 = [System.Boolean](Get-OSDGather -Property IsOnBattery)

        OSActivation                = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Activation
        OSEdition                   = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Edition
        OSLanguage                  = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Language
        OSImageIndex                = [System.Int32]$Global:OSDModuleResource.OSDCloud.Default.ImageIndex
        OSName                      = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Name
        OSReleaseID                 = [System.String]$Global:OSDModuleResource.OSDCloud.Default.ReleaseID
        OSVersion                   = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Version

        OSActivationValues          = [array]$Global:OSDModuleResource.OSDCloud.Values.Activation
        OSEditionValues             = [array]$Global:OSDModuleResource.OSDCloud.Values.Edition
        OSLanguageValues            = [array]$Global:OSDModuleResource.OSDCloud.Values.Language
        OSNameValues                = [array]$Global:OSDModuleResource.OSDCloud.Values.Name
        OSReleaseIDValues           = [array]$Global:OSDModuleResource.OSDCloud.Values.ReleaseID
        OSVersionValues             = [array]$Global:OSDModuleResource.OSDCloud.Values.Version
        
        captureScreenshots          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.captureScreenshots
        ClearDiskConfirm            = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm
        restartComputer             = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.restartComputer
        updateDiskDrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateDiskDrivers
        updateFirmware              = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateFirmware
        updateNetworkDrivers        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateNetworkDrivers
        updateSCSIDrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateSCSIDrivers
        
        TimeStart                   = [datetime](Get-Date)
    }
    #================================================
    #   Set Driver Pack
    #   New logic added to Get-OSDCloudDriverPack
    #   This should match the proper OS Version ReleaseID
    #================================================
    $Global:OSDCloudGUI.DriverPack = Get-OSDCloudDriverPack -Product $ComputerProduct -OSVersion $Global:OSDCloudGUI.OSVersion -OSReleaseID $Global:OSDCloudGUI.OSReleaseID
    if ($Global:OSDCloudGUI.DriverPack) {
        $Global:OSDCloudGUI.DriverPackName = $Global:OSDCloudGUI.DriverPack.Name
    }
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "OSDCloudGUI Configuration"
    $Global:OSDCloudGUI | Out-Host
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudGUI\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}