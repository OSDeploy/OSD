function Start-RecastOSDCloud {
    <#
    .SYNOPSIS
    Starts the Recast OSDCloud graphical deployment workflow.

    .DESCRIPTION
    Initializes device and deployment context, discovers matching operating systems,
    resolves driver pack metadata for the current device (or supplied overrides),
    validates required dependencies, and then prepares global state consumed by
    the Recast OSDCloud GUI workflow.

    .PARAMETER OSDManufacturer
    Overrides the detected computer manufacturer for driver pack matching.
    If omitted, the detected device manufacturer is used.

    .PARAMETER OSDModel
    Overrides the detected computer model for logging and context alignment.
    If omitted, the detected device model is used.

    .PARAMETER OSDProduct
    Overrides the detected computer product/system ID for driver pack matching.
    If omitted, the detected device product value is used.

    .PARAMETER v2
    Legacy compatibility switch. This parameter is non-functional and retained
    temporarily to avoid breaking existing scripts.

    .EXAMPLE
    Start-RecastOSDCloud
    Starts OSDCloud GUI using detected device values and default branding.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Standardized comment-based help metadata and links.
    2026-07-09 - The -v2 parameter is deprecated and will be removed in a future release.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Operating system architecture for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSArchitecture = $env:PROCESSOR_ARCHITECTURE,

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system release identifier for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSReleaseID = '25H2',

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system language code for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSLanguageCode,

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system activation channel for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSActivation = 'Retail',

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system edition identifier for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSEditionId = 'Professional',

        [Parameter(Mandatory = $false, HelpMessage = 'Optional manufacturer override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDManufacturer,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional model override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDModel,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional product/system ID override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDProduct
    )
    #=================================================
    # Emit function/version context and surface legacy parameter usage.
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $ModuleVersion"
    #=================================================
    # Ensure hardware context is available for later OS/driver decisions.
    #region Initialize-OSDCoreDevice
    if (-not ($global:OSDCoreDevice)) {
        Initialize-OSDCoreDevice
    }

    if (-not $PSBoundParameters.ContainsKey('OSLanguageCode')) {
        if (Get-Command -Name 'Convert-KeyboardLayoutToLanguageCode' -ErrorAction SilentlyContinue) {
            $OSLanguageCode = Convert-KeyboardLayoutToLanguageCode -KeyboardLayout $global:OSDCoreDevice.KeyboardLayout -FallbackLanguageCode 'en-US'
        }
        else {
            $OSLanguageCode = 'en-US'
        }
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

    $global:OSDCoreOperatingSystemObject = $global:OSDCoreOperatingSystems | `
        Where-Object { $_.Activation -eq $OSActivation } | `
        Where-Object { $_.Architecture -match $OSArchitecture } | `
        Where-Object { $_.Language -eq $OSLanguageCode } | `
        Where-Object { $_.ReleaseID -eq $OSReleaseID }

    if (-not $global:OSDCoreOperatingSystemObject) {
        throw "[$(Get-Date -format s)] Unable to find a matching operating system object for OSName '$OSName', Activation '$OSActivation', and Language '$OSLanguage'."
    }
    #=================================================
    # Resolve driver pack metadata for the detected device, with optional
    # manufacturer/product overrides supplied by the caller.
    if ($OSDManufacturer) {
        $global:OSDCoreDevice.OSDManufacturer = $OSDManufacturer
        $global:OSDCoreDriverPacks = Get-OSDCoreDriverPacks -OSDManufacturer $OSDManufacturer
    }

    if ($OSDModel) {
        $global:OSDCoreDevice.OSDModel = $OSDModel
    }

    if ($OSDProduct) {
        # Use explicit product override for driver pack match.
        $global:OSDCoreDevice.OSDProduct = $OSDProduct
        $global:OSDCoreDriverPackObject = $global:OSDCoreDriverPacks | Where-Object { $_.SystemId -match $OSDProduct } | Select-Object -First 1
    }
    else {
        # Default to the detected device product when no override is provided.
        $global:OSDCoreDriverPackObject = $global:OSDCoreDriverPacks | Where-Object { $_.SystemId -match $global:OSDCoreDevice.OSDProduct } | Select-Object -First 1
    }
    #================================================
    #   Output OSDCore Objects
    #================================================
    if ($global:OSDCoreOperatingSystemObject) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCloud Operating System Object:"
        $global:OSDCoreOperatingSystemObject | Out-Host
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDManufacturer: $($global:OSDCoreDevice.OSDManufacturer)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDModel: $($global:OSDCoreDevice.OSDModel)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDProduct: $($global:OSDCoreDevice.OSDProduct)"
    if ($global:OSDCoreDriverPackObject) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCloud DriverPack Object:"
        $global:OSDCoreDriverPackObject | Out-Host
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
        LaunchMethod          = 'RecastOSDCloud'
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
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] Starting Invoke-RecastOSDCloud in 5 seconds ..."
    Start-Sleep -Seconds 5
    Invoke-RecastOSDCloud
    #================================================
}
