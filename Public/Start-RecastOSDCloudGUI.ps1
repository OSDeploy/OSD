function Start-RecastOSDCloudGUI {
    <#
    .SYNOPSIS
    Starts the Recast OSDCloud graphical deployment workflow.

    .DESCRIPTION
    Initializes device and deployment context, discovers matching operating systems,
    resolves driver pack metadata for the current device (or supplied overrides),
    validates required dependencies, and then prepares global state consumed by
    the Recast OSDCloud GUI workflow.

    .PARAMETER BrandName
    Sets the branding text shown in the OSDCloud GUI title/header.
    Defaults to the module resource value.

    .PARAMETER BrandColor
    Sets the branding color shown in the OSDCloud GUI.
    Provide a hex color value, for example '#0096D6'.

    .PARAMETER ComputerManufacturer
    Overrides the detected computer manufacturer for driver pack matching.
    If omitted, the detected device manufacturer is used.

    .PARAMETER ComputerProduct
    Overrides the detected computer product/system ID for driver pack matching.
    If omitted, the detected device product value is used.

    .PARAMETER v2
    Legacy compatibility switch. This parameter is non-functional and retained
    temporarily to avoid breaking existing scripts.

    .EXAMPLE
    Start-RecastOSDCloudGUI
    Starts OSDCloud GUI using detected device values and default branding.

    .EXAMPLE
    Start-RecastOSDCloudGUI -BrandName 'Contoso' -BrandColor '#005A9C'
    Starts OSDCloud GUI with custom branding.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Standardized comment-based help metadata and links.
    2026-07-09 - The -v2 parameter is deprecated and will be removed in a future release.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Custom brand text for the OSDCloud GUI.')]
        [Alias('Brand')]
        [ValidateNotNullOrEmpty()]
        [string]
        $BrandName = $Global:OSDModuleResource.StartOSDCloudGUI.BrandName,

        [Parameter(Mandatory = $false, HelpMessage = 'Brand color in hex format (for example #0096D6).')]
        [Alias('Color')]
        [ValidatePattern('^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$')]
        [string]
        $BrandColor = $Global:OSDModuleResource.StartOSDCloudGUI.BrandColor,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional manufacturer override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerManufacturer,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional product/system ID override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerProduct,

        [Parameter(Mandatory = $false, HelpMessage = 'Legacy compatibility switch. This parameter is deprecated and non-functional.')]
        [System.Management.Automation.SwitchParameter]
        $v2
    )
    #=================================================
    # Emit function/version context and surface legacy parameter usage.
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $ModuleVersion"

    if ($v2) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] v2 parameter is deprecated and non-functional and will be removed in a future release. Please remove the v2 parameter from your command."
    }
    #=================================================
    # Ensure hardware context is available for later OS/driver decisions.
    #region Initialize-OSDCoreDevice
    if (-not ($global:OSDCoreDevice)) {
        Initialize-OSDCoreDevice
    }
    <#
        PS C:\Users\david> $OSDCoreDevice
        Name                           Value
        ----                           -----
        OSDManufacturer                HP
        OSDModel                       HP Z2 Mini G9 Workstation Desktop PC
        OSDProduct                     895E
        ComputerName                   OSDMAIN
        BaseBoardProduct               895E
        BiosReleaseDate                11/02/2025 18:00:00
        BiosVersion                    U50 Ver. 03.05.02
        ComputerManufacturer           HP
        ComputerModel                  HP Z2 Mini G9 Workstation Desktop PC
        ComputerSystemFamily           103C_53335X HP Workstation
        ComputerSystemProduct          SBKPF,DWKSBLF,SBKPFV3
        ComputerSystemSKU              B40ZBUP#ABA
        ComputerSystemType             Small Form Factor
        HardwareHash
        IsAutopilotSpec                True
        IsDesktop                      False
        IsLaptop                       False
        IsOnBattery                    False
        IsServer                       False
        IsSFF                          True
        IsTablet                       False
        IsTpmSpec                      True
        IsVM                           False
        IsUEFI                         True
        KeyboardLayout                 00000409
        KeyboardName                   Enhanced (101- or 102-key)
        NetGateways                    {192.168.0.1, $null}
        NetIPAddress                   {192.168.0.121, fe80::81d7:1db5:c6cc:e822, fd1a:2b60:6c6d:4ec6:34fc:1332:8b28:fd1d, fd1a:2b60:6c6d:4ec6:1236:ad56:5fe8:9d11…}
        NetMacAddress                  {64:4B:F0:39:11:3A, 10:4A:26:03:04:16}
        OSArchitecture                 64-bit
        OSVersion                      10.0.26200
        ProcessorArchitecture          AMD64
        SerialNumber                   {redacted}
        SystemFirmwareHardwareId       EF647623-90B4-44BC-8866-D6FB7F29AB46
        TimeZone                       Central Standard Time
        TotalPhysicalMemoryGB          128
        TpmIsActivated                 True
        TpmIsEnabled                   True
        TpmIsOwned                     True
        TpmManufacturerIdTxt           NTC
        TpmManufacturerVersion         7.2.3.1
        TpmSpecVersion                 2.0, 0, 1.59
        UUID                           {redacted}
    #>
    #endregion
    #=================================================
    # Validate that the OS catalog was preloaded for this architecture.
    # The GUI cannot continue without at least one deployable operating system.
    if (-not $global:OSDCoreOperatingSystems) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load Operating Systems"
    }
    #=================================================
    # Resolve driver pack metadata for the detected device, with optional
    # manufacturer/product overrides supplied by the caller.
    if ($ComputerManufacturer) {
        $global:OSDCoreDevice.OSDManufacturer = $ComputerManufacturer
        $global:OSDCoreDriverPacks = Get-OSDCoreDriverPacks -OSDManufacturer $ComputerManufacturer
    }

    if ($ComputerProduct) {
        # Use explicit product override for driver pack match.
        $global:OSDCoreDevice.OSDProduct = $ComputerProduct
        $global:OSDCoreDriverPackObject = $global:OSDCoreDriverPacks | Where-Object { $_.SystemId -match $ComputerProduct } | Select-Object -First 1
    }
    else {
        # Default to the detected device product when no override is provided.
        $global:OSDCoreDriverPackObject = $global:OSDCoreDriverPacks | Where-Object { $_.SystemId -match $global:OSDCoreDevice.OSDProduct } | Select-Object -First 1
    }

    if ($global:OSDCoreDriverPackObject) {
        # Log resolved driver pack details to make selection behavior explicit.
        $DriverPackName = $global:OSDCoreDriverPackObject.Name
        $DriverPackUrl = $global:OSDCoreDriverPackObject.Url

        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDManufacturer: $($global:OSDCoreDevice.OSDManufacturer)"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDModel: $($global:OSDCoreDevice.OSDModel)"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDProduct: $($global:OSDCoreDevice.OSDProduct)"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] DriverPack Name: $DriverPackName"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] DriverPack Url: $DriverPackUrl"
    }
    else {
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDManufacturer: $($global:OSDCoreDevice.OSDManufacturer)"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDModel: $($global:OSDCoreDevice.OSDModel)"
        Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] OSDProduct: $($global:OSDCoreDevice.OSDProduct)"
    }
    #=================================================
    # Dependency guard: OSDCloud relies on curl.exe for downloads.
    if (-not (Get-Command -Name 'curl.exe' -ErrorAction SilentlyContinue)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloud requires 'curl.exe' which is not available on this system. Please ensure curl.exe is available in the system PATH."
    }
    #=================================================
    # Detect candidate deployment disk(s).
    $DeploymentDiskObject = Get-OSDCoreDeploymentDisk

    # Stop immediately if no eligible local deployment disk is found.
    if (-not $DeploymentDiskObject) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloud requires at least one Local Disk, but no compatible Local Disk was found."
    }
    # If multiple disks are discovered, keep behavior deterministic by using
    # the first disk and logging all candidates for troubleshooting visibility.
    if (@($DeploymentDiskObject).Count -gt 1) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Multiple Local Disks were found. OSDCloud will default to DiskNumber: $($DeploymentDiskObject[0].DiskNumber)"
        $DeploymentDiskObject | ForEach-Object {
            Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DiskNumber: $($_.DiskNumber), FriendlyName: $($_.FriendlyName), Size(GB): $([math]::Round($_.Size / 1GB, 2))"
        }
    }
    # Limit to the selected disk object expected by downstream workflow code.
    $DeploymentDiskObject = $DeploymentDiskObject | Select-Object -First 1
    #=================================================
    # Build deployment state consumed by the broader OSDCloud workflow.
    $global:OSDCloudDeploy = $null
    $global:OSDCloudDeploy = [ordered]@{
        DeploymentDiskObject  = $DeploymentDiskObject
        # DriverFolderName          = $null
        # DriverFolderNames         = @()
        # DriverFolderPath          = $null
        # DriverFolderPaths         = @()
        # DriverFolderSelections    = @()
        # DriverPackName        = $DriverPackName
        # DriverPackObject      = $DriverPackObject
        # DriverPackValues      = [array]$DriverPackValues
        # Flows                     = [array]$global:OSDCloudWorkflowTasks
        Function              = $($MyInvocation.MyCommand.Name)
        # ImageFileName         = $ImageFileName
        # ImageFileUrl          = $ImageFileUrl
        LaunchMethod          = 'OSDCloudGUI'
        Module                = $($MyInvocation.MyCommand.Module.Name)
        OperatingSystem       = $OperatingSystem
        # OperatingSystemObject = $OperatingSystemObject
        # OperatingSystemValues = $OperatingSystemValues
        OSActivation          = $OSActivation
        OSActivationValues    = $OSActivationValues
        OSArchitecture        = $OSArchitecture
        OSBuild               = $OSBuild
        OSBuildVersion        = $OSBuildVersion
        OSEdition             = $OSEdition
        OSEditionId           = $OSEditionId
        OSEditionValues       = $OSEditionValues
        OSLanguageCode        = $OSLanguageCode
        OSLanguageCodeValues  = $OSLanguageCodeValues
        OSVersion             = $OSVersion
        TimeStart             = $null
        # WorkflowName              = $WorkflowName
        # WorkflowTaskName          = $WorkflowTaskName
        # WorkflowTaskObject        = $WorkflowTaskObject
    }
    #================================================
    # Build GUI configuration defaults from module resources and current device context.
    $Global:OSDCloudGUI = $null
    $Global:OSDCloudGUI = [ordered]@{
        Function              = [System.String]'Start-RecastOSDCloudGUI'
        LaunchMethod          = [System.String]'OSDCloudGUI'

        AutomateConfiguration = $null
        AutomateJsonFile      = $null

        BrandName             = [System.String]$BrandName
        BrandColor            = [System.String]$BrandColor

        ComputerManufacturer  = [System.String]$OSDManufacturer
        ComputerModel         = [System.String]$OSDModel
        ComputerProduct       = [System.String]$OSDProduct

        # DriverPack                  = $null
        # DriverPacks                 = $null
        # DriverPackName        = $DriverPackName
        # DriverPackObject      = $DriverPackObject
        # DriverPackValues      = [array]$DriverPackValues

        IsOnBattery           = [System.Boolean]$global:OSDCoreDevice.IsOnBattery

        OSActivation          = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Activation
        OSEdition             = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Edition
        OSLanguage            = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Language
        OSImageIndex          = [System.Int32]$Global:OSDModuleResource.OSDCloud.Default.ImageIndex
        OSName                = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Name
        OSReleaseID           = [System.String]$Global:OSDModuleResource.OSDCloud.Default.ReleaseID
        OSVersion             = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Version

        OSActivationValues    = [array]$Global:OSDModuleResource.OSDCloud.Values.Activation
        OSEditionValues       = [array]$Global:OSDModuleResource.OSDCloud.Values.Edition
        OSLanguageValues      = [array]$Global:OSDModuleResource.OSDCloud.Values.Language
        OSNameValues          = [array]$Global:OSDModuleResource.OSDCloud.Values.Name
        OSNameARM64Values     = [array]$Global:OSDModuleResource.OSDCloud.Values.NameARM64
        OSReleaseIDValues     = [array]$Global:OSDModuleResource.OSDCloud.Values.ReleaseID
        OSVersionValues       = [array]$Global:OSDModuleResource.OSDCloud.Values.Version

        ClearDiskConfirm      = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm
        restartComputer       = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.restartComputer

        updateDiskDrivers     = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateDiskDrivers
        updateFirmware        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateFirmware
        updateNetworkDrivers  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateNetworkDrivers
        updateSCSIDrivers     = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateSCSIDrivers
        SyncMSUpCatDriverUSB  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.SyncMSUpCatDriverUSB

        OEMActivation         = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.OEMActivation
        WindowsUpdate         = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdate
        WindowsUpdateDrivers  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdateDrivers
        WindowsDefenderUpdate = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsDefenderUpdate

        HPIAALL               = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAALL
        HPIADrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIADrivers
        HPIAFirmware          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAFirmware
        HPIASoftware          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIASoftware
        HPTPMUpdate           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPTPMUpdate
        HPBIOSUpdate          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPBIOSUpdate

        TimeStart             = [datetime](Get-Date)
    }
    #================================================
    # Export baseline GUI settings, then look for external automation JSON
    # on non-C drives to override interactive defaults when present.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Exporting default configuration to $env:Temp\Start-RecastOSDCloudGUI.json"
    $Global:OSDCloudGUI | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:TEMP\Start-RecastOSDCloudGUI.json" -Force

    $Global:OSDCloudGUI.AutomateJsonFile = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "Start-RecastOSDCloudGUI.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($Global:OSDCloudGUI.AutomateJsonFile) {
        foreach ($Item in $Global:OSDCloudGUI.AutomateJsonFile) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($Item.FullName)"
            $Global:OSDCloudGUI.AutomateConfiguration = Get-Content -Path "$($Item.FullName)" -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        }
    }
    if ($Global:OSDCloudGUI.AutomateConfiguration) {
        # Apply each discovered automation setting onto the active GUI config.
        foreach ($Key in $Global:OSDCloudGUI.AutomateConfiguration.Keys) {
            $Global:OSDCloudGUI.$Key = $Global:OSDCloudGUI.AutomateConfiguration.$Key
        }
    }
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title = $Global:OSDCloudGUI.BrandName
        Color = $Global:OSDCloudGUI.BrandColor
    }
    Write-Host -ForegroundColor Green "OSDCloudGUI Configuration"
    $Global:OSDCloudGUI | Out-Host
    #================================================
    # Launch the WPF GUI entry point with the prepared global state.
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\RecastOSDCloudGUI\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}
