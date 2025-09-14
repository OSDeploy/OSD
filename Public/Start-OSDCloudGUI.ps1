function Start-OSDCloudGUI {
    <#
    .SYNOPSIS
    OSDCloud imaging using the command line

    .DESCRIPTION
    OSDCloud imaging using the command line

    .EXAMPLE
    Start-OSDCloudGUI

    .NOTES
    Added Architecture
    #>

    [CmdletBinding()]
    param (
        $Architecture = $Env:PROCESSOR_ARCHITECTURE,

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
        $ComputerProduct = (Get-MyComputerProduct),

        [System.String]
        $PrestartURL
    )
    #=================================================
    if ($PrestartURL) {
        try {
            $Result = Invoke-WebRequest -Uri $PrestartURL -UseBasicParsing -Method Head
            if ($Result.StatusCode -eq 200) {
                Invoke-Expression (Invoke-RestMethod -Uri $PrestartURL -UseBasicParsing)
            }
        }
        catch {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDCloud failed to reach the PrestartURL"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDCloud will continue in 20 seconds ... or press Ctrl+C to exit"
            Start-Sleep -Seconds 20
        }
    }
    #================================================
    #   Get-OSDCloudDriverPacks
    #================================================
    $DriverPacks = Get-OSDCloudDriverPacks | Where-Object {$_.OSArchitecture -match $Architecture}

    switch ($ComputerManufacturer) {
        'Dell' {
            $DriverPacks = $DriverPacks | Where-Object { $_.OSArchitecture -match $Architecture -and $_.Manufacturer -eq 'Dell' }
        }
        'HP' {
            $DriverPacks = $DriverPacks | Where-Object { $_.OSArchitecture -match $Architecture -and $_.Manufacturer -eq 'HP' }
        }
        'Lenovo' {
            $DriverPacks = $DriverPacks | Where-Object { $_.OSArchitecture -match $Architecture -and $_.Manufacturer -eq 'Lenovo' }
        }
        Default {
            $DriverPacks = $DriverPacks | Where-Object { $_.OSArchitecture -match $Architecture }
        }
    }

    if ($ComputerModel -match 'Surface') {
        $DriverPacks = $DriverPacks | Where-Object { $_.OSArchitecture -match $Architecture -and $_.Manufacturer -eq 'Microsoft' }
    }
    #================================================
    #   Architecture
    #================================================
    if ($Architecture -eq 'ARM64') {
        $OSActivation = [System.String]$Global:OSDModuleResource.OSDCloud.DefaultARM64.Activation
        $OSEdition = [System.String]$Global:OSDModuleResource.OSDCloud.DefaultARM64.Edition
        $OSName = [System.String]$Global:OSDModuleResource.OSDCloud.DefaultARM64.Name

        $OSEditionValues = [array]$Global:OSDModuleResource.OSDCloud.ValuesARM64.Edition
        $OSNameValues = [array]$Global:OSDModuleResource.OSDCloud.ValuesARM64.Name
        $OSReleaseIDValues = [array]$Global:OSDModuleResource.OSDCloud.ValuesARM64.ReleaseID
        $OSVersionValues = [array]$Global:OSDModuleResource.OSDCloud.ValuesARM64.Version
    }
    else {
        $OSActivation = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Activation
        $OSEdition = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Edition
        $OSName = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Name

        $OSEditionValues = [array]$Global:OSDModuleResource.OSDCloud.Values.Edition
        $OSNameValues = [array]$Global:OSDModuleResource.OSDCloud.Values.Name
        $OSReleaseIDValues = [array]$Global:OSDModuleResource.OSDCloud.Values.ReleaseID
        $OSVersionValues = [array]$Global:OSDModuleResource.OSDCloud.Values.Version
    }
    #================================================
    #   Pass Variables to OSDCloudGUI
    #================================================
    $Global:OSDCloudGUI = $null
    $Global:OSDCloudGUI = [ordered]@{
        Function                    = [System.String]'Start-OSDCloudGUI'
        LaunchMethod                = [System.String]'OSDCloudGUI'
        AutomateConfiguration       = $null
        AutomateJsonFile            = $null
        BrandName                   = [System.String]$BrandName
        BrandColor                  = [System.String]$BrandColor
        ComputerManufacturer        = [System.String]$ComputerManufacturer
        ComputerModel               = [System.String](Get-MyComputerModel -Brief)
        ComputerProduct             = [System.String]$ComputerProduct
        DriverPack                  = $null
        DriverPacks                 = [array]$DriverPacks
        DriverPackName              = 'None'
        IsOnBattery                 = [System.Boolean](Get-OSDGather -Property IsOnBattery)

        OSActivation                = [System.String]$OSActivation
        OSEdition                   = [System.String]$OSEdition
        OSLanguage                  = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Language
        OSImageIndex                = [System.Int32]$Global:OSDModuleResource.OSDCloud.Default.ImageIndex
        OSName                      = [System.String]$OSName
        OSReleaseID                 = [System.String]$Global:OSDModuleResource.OSDCloud.Default.ReleaseID
        OSVersion                   = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Version

        OSActivationValues          = [array]$Global:OSDModuleResource.OSDCloud.Values.Activation
        OSEditionValues             = [array]$OSEditionValues
        OSLanguageValues            = [array]$Global:OSDModuleResource.OSDCloud.Values.Language
        OSNameValues                = [array]$OSNameValues
        OSReleaseIDValues           = [array]$OSReleaseIDValues
        OSVersionValues             = [array]$OSVersionValues

        ClearDiskConfirm            = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm
        restartComputer             = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.restartComputer
        updateDiskDrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateDiskDrivers
        updateFirmware              = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateFirmware
        updateNetworkDrivers        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateNetworkDrivers
        updateSCSIDrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateSCSIDrivers
        SyncMSUpCatDriverUSB        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.SyncMSUpCatDriverUSB

        OEMActivation               = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.OEMActivation
        WindowsUpdate               = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdate
        WindowsUpdateDrivers        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdateDrivers
        WindowsDefenderUpdate       = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsDefenderUpdate

        HPIAALL                     = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAALL
        HPIADrivers                 = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIADrivers
        HPIAFirmware                = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAFirmware
        HPIASoftware                = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIASoftware
        HPTPMUpdate                 = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPTPMUpdate
        HPBIOSUpdate                = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPBIOSUpdate
        
        TimeStart                   = [datetime](Get-Date)
    }
    #================================================
    #   OSDCloud Automate
    #================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Exporting default configuration to $env:Temp\Start-OSDCloudGUI.json"
    $Global:OSDCloudGUI | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:TEMP\Start-OSDCloudGUI.json" -Force
    
    $Global:OSDCloudGUI.AutomateJsonFile = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "Start-OSDCloudGUI.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($Global:OSDCloudGUI.AutomateJsonFile) {
        foreach ($Item in $Global:OSDCloudGUI.AutomateJsonFile) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($Item.FullName)"
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
    #   Set Default Driver Pack
    #================================================
    $ProductDriverPacks = $DriverPacks | Where-Object {($_.Product -contains $ComputerProduct)}

    if ($ProductDriverPacks) {
        if ($Global:OSDCloudGUI.OSVersion) {
            $OSVersionDriverPacks = $ProductDriverPacks | Where-Object { $_.OS -match $Global:OSDCloudGUI.OSVersion}
            if (-NOT $OSVersionDriverPacks) {
                $OSVersionDriverPacks = $ProductDriverPacks
            }
        }
        else {
            $OSVersionDriverPacks = $ProductDriverPacks
        }

        if ($Global:OSDCloudGUI.OSReleaseID) {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks | Where-Object { $_.Name -match $Global:OSDCloudGUI.OSReleaseID}
            if (-NOT $OSReleaseIDDriverPacks) {
                $OSReleaseIDDriverPacks = $OSVersionDriverPacks
            }
        }
        else {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks
        }
        $Results = $OSReleaseIDDriverPacks | Sort-Object -Property Name -Descending | Select-Object -First 1
    }

    if ($Results) {
        $Global:OSDCloudGUI.DriverPackName = $Results.Name
    }
    else {
        $Global:OSDCloudGUI.DriverPackName = 'None'
    }
    Write-Host -ForegroundColor Green "OSDCloudGUI Configuration"
    $Global:OSDCloudGUI | Out-Host
    #================================================
    #   Test TPM
    #================================================
    try {
        $Win32Tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm

        if ($null -eq $Win32Tpm) {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
        elseif ($Win32Tpm.SpecVersion) {
            if ($null -eq $Win32Tpm.SpecVersion) {
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] TPM: Unable to detect the TPM Version"
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }

            $majorVersion = $Win32Tpm.SpecVersion.Split(",")[0] -as [int]
            if ($majorVersion -lt 2) {
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] TPM: Version is less than 2.0"
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }
            else {
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsActivated: $($Win32Tpm.IsActivated_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsEnabled: $($Win32Tpm.IsEnabled_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsOwned: $($Win32Tpm.IsOwned_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer: $($Win32Tpm.ManufacturerIdTxt)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer Version: $($Win32Tpm.ManufacturerVersion)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM SpecVersion: $($Win32Tpm.SpecVersion)"
                Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] TPM 2.0: Supported"
                Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Autopilot: Supported"
            }
        }
        else {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
    }
    catch {
    }
    #================================================
    #   Launch GUI
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudGUI\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}