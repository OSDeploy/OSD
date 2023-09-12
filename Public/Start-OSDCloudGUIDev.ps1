function Start-OSDCloudGUIDev {
    <#
    .SYNOPSIS
    OSDCloud imaging using the command line

    .DESCRIPTION
    OSDCloud imaging using the command line

    .EXAMPLE
    Start-OSDCloudGUIDev

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
    #   Pass Variables to OSDCloudGUI
    #================================================
    $Global:OSDCloudGUI = $null
    $Global:OSDCloudGUI = [ordered]@{
        Function                    = [System.String]'Start-OSDCloudGUIDev'
        LaunchMethod                = [System.String]'OSDCloudGUIDev'

        AutomateConfiguration       = $null
        AutomateJsonFile            = $null

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
    #   OSDCloud Automate
    #================================================
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting default configuration to $env:Temp\Start-OSDCloudGUI.json"
    $Global:OSDCloudGUI | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:TEMP\Start-OSDCloudGUI.json" -Force
    
    $Global:OSDCloudGUI.AutomateJsonFile = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "Start-OSDCloudGUI.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($Global:OSDCloudGUI.AutomateJsonFile) {
        foreach ($Item in $Global:OSDCloudGUI.AutomateJsonFile) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Item.FullName)"
            $Global:OSDCloudGUI.AutomateConfiguration = Get-Content -Path "$($Item.FullName)" -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        }
    }
    if ($Global:OSDCloudGUI.AutomateConfiguration) {
        foreach ($Key in $Global:OSDCloudGUI.AutomateConfiguration.Keys) {
            $Global:OSDCloudGUI.$Key = $Global:OSDCloudGUI.AutomateConfiguration.$Key
        }
    }
    #================================================
    #   Brand
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title = $Global:OSDCloudGUI.BrandName
        Color = $Global:OSDCloudGUI.BrandColor
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
    Write-Host -ForegroundColor Green "OSDCloudGUIDEV Configuration"
    $Global:OSDCloudGUI | Out-Host
    #================================================
    #   Test TPM
    #================================================
    try {
        $Win32Tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm

        if ($null -eq $Win32Tpm) {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
        elseif ($Win32Tpm.SpecVersion) {
            if ($null -eq $Win32Tpm.SpecVersion) {
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Unable to detect the TPM Version"
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }

            $majorVersion = $Win32Tpm.SpecVersion.Split(",")[0] -as [int]
            if ($majorVersion -lt 2) {
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Version is less than 2.0"
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }
            else {
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsActivated: $($Win32Tpm.IsActivated_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsEnabled: $($Win32Tpm.IsEnabled_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsOwned: $($Win32Tpm.IsOwned_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM Manufacturer: $($Win32Tpm.ManufacturerIdTxt)"
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM Manufacturer Version: $($Win32Tpm.ManufacturerVersion)"
                #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM SpecVersion: $($Win32Tpm.SpecVersion)"
                Write-Host -ForegroundColor Green "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM 2.0: Supported"
                Write-Host -ForegroundColor Green "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Supported"
            }
        }
        else {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
    }
    catch {
    }
    #================================================
    #   Launch GUI
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudDEV\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}