function Invoke-RecastOSDCloudCLI {
    <#
    .SYNOPSIS
    Executes the Recast OSDCloud command-line deployment workflow.

    .DESCRIPTION
    Initializes the OSDCloud runtime state from device and deployment context,
    applies supported global customization hashtables, confirms selected operating
    system and driver pack cache availability, prepares the deployment disk, and
    runs the command-line operating system deployment workflow.

    This function does not accept direct parameters. It relies on module and global
    state populated by Start-RecastOSDCloudCLI before invocation.

    .PARAMETER None
    This function does not define input parameters.

    .EXAMPLE
    Invoke-RecastOSDCloudCLI
    Runs the Recast OSDCloud CLI deployment workflow using existing global deployment state.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-20 - Updated comment-based help for Recast OSDCloud CLI behavior.
    #>
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    $global:RecastOSDCloud.TimeStart = [datetime](Get-Date)
    #=================================================
    # Set OSDCloud LogsPath
    $LogsPath = "$env:TEMP\osdcloud-logs"
    if (-not (Test-Path -LiteralPath $LogsPath -PathType Container)) {
        $null = New-Item -Path $LogsPath -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    $TranscriptFullName = Join-Path $LogsPath "transcript-$((Get-Date).ToString('yyyy-MM-dd-HHmmss')).log"
    if (-not (Start-Transcript -Path $TranscriptFullName -ErrorAction SilentlyContinue)) {
        Write-Warning "[$(Get-Date -format s)] Failed to start transcript at $TranscriptFullName"
    }
    #=================================================
    #region Initialize-OSDCoreDevice
    if (-not ($global:OSDCoreDevice)) {
        Initialize-OSDCoreDevice
    }
    #=================================================
    #region OSDCloud Master Settings
    $Global:OSDCloud = $null
    $Global:OSDCloud = [ordered]@{
        LaunchMethod = $null
        OSDManufacturer = $global:OSDCoreDevice.OSDManufacturer
        OSDModel = $global:OSDCoreDevice.OSDModel
        OSDProduct = $global:OSDCoreDevice.OSDProduct
        AutomateAutopilot = $null
        AutomateProvisioning = $null
        AutomateShutdownScript = $null
        AutomateStartupScript = $null
        AutopilotJsonChildItem = $null
        AutopilotJsonItem = $null
        AutopilotJsonName = $null
        AutopilotJsonObject = $null
        AutopilotJsonString = $null
        AutopilotJsonUrl = $null
        AutopilotOOBEJsonChildItem = $null
        AutopilotOOBEJsonItem = $null
        AutopilotOOBEJsonName = $null
        AutopilotOOBEJsonObject = $null
        AzContext = $Global:AzContext
        AzOSDCloudBlobAutopilotFile = $Global:AzOSDCloudBlobAutopilotFile
        AzOSDCloudBlobDriverPack = $Global:AzOSDCloudBlobDriverPack
        AzOSDCloudBlobImage = $Global:AzOSDCloudBlobImage
        AzOSDCloudBlobPackage = $Global:AzOSDCloudBlobPackage
        AzOSDCloudBlobScript = $Global:AzOSDCloudBlobScript
        AzOSDCloudAutopilotFile = $Global:AzOSDCloudAutopilotFile
        AzOSDCloudDriverPack = $null
        AzOSDCloudImage = $Global:AzOSDCloudImage
        AzOSDCloudPackage = $null
        AzOSDCloudScript = $null
        AzStorageAccounts = $Global:AzStorageAccounts
        AzStorageContext = $Global:AzStorageContext
        BuildName = 'OSDCloud'
        ClearDiskConfirm = [bool]$true
        CheckSHA1 = $false
        Debug = $false
        DevMode = $false
        DownloadDirectory = $null
        DownloadName = $null
        DownloadFullName = $null
        DriverPack = $null
        DriverPackBaseName = $null
        DriverPackExpand = [bool]$false
        DriverPackName = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        DriverPackUrl = $null
        ExpandWindowsImage = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        HPIADrivers = $null
        HPIAFirmware = $null
        HPIASoftware = $null
        HPTPMUpdate = $null
        HPBIOSUpdate = $null
        HPCMSLDriverPackLatest = $null
        HPCMSLDriverPackLatestFound = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileDestination = $null
        ImageFileDestinationSHA1 = $null
        ImageFileUrl = $null
        ImageFileSHA1 = $null
        IsOnBattery = $global:OSDCoreDevice.IsOnBattery
        IsTest = ($env:SystemDrive -ne 'X:')
        IsVirtualMachine = $global:OSDCoreDevice.IsVM
        IsWinPE = ($env:SystemDrive -eq 'X:')
        IsoMountDiskImage = $null
        IsoGetDiskImage = $null
        IsoGetVolume = $null
        Logs = "$env:SystemDrive\OSDCloud\Logs"
        Manufacturer = $global:OSDCoreDevice.OSDManufacturer
        MSCatalogFirmware = $true
        MSCatalogDiskDrivers = $true
        MSCatalogNetDrivers = $true
        MSCatalogScsiDrivers = $true
        OOBEDeployJsonChildItem = $null
        OOBEDeployJsonItem = $null
        OOBEDeployJsonName = $null
        OOBEDeployJsonObject = $null
        ODTConfigFile = 'C:\OSDCloud\ODT\Config.xml'
        ODTFile = $null
        ODTFiles = $null
        ODTSetupFile = $null
        ODTSource = $null
        ODTTarget = 'C:\OSDCloud\ODT'
        ODTTargetData = 'C:\OSDCloud\ODT\Office'
        OperatingSystems = $null
        OSActivation = $null
        OSBuild = $null
        OSBuildMenu = $null
        OSBuildNames = $null
        OSDiskNumberDefault = $null
        OSEdition = $null
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionValues = $null
        OSInstallDiskNumber = $null
        OSImageIndex = 0
        OSLanguage = $null
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSVersion = 'Windows 10'
        Product = $global:OSDCoreDevice.OSDProduct
        Restart = [bool]$false
        ScriptStartup = $null
        ScriptShutdown = $null
        SectionPassed = $true
        SetupCompleteNoRestart = [bool]$false
        SetWiFi = $null
        Shutdown = [bool]$false
        ShutdownSetupComplete = [bool]$false
        SkipAllDiskSteps = [bool]$false
        SkipAutopilot = [bool]$false
        SkipAutopilotOOBE = [bool]$false
        SkipClearDisk = [bool]$false
        SkipODT = [bool]$false
        SkipOOBEDeploy = [bool]$false
        SkipNewOSDisk = [bool]$false
        SkipRecoveryPartition = [bool]$false
        SplashScreen = [bool]$false
        SyncMSUpCatDriverUSB = [bool]$false
        RecoveryPartition = $null
        TimeEnd = $null
        TimeSpan = $null
        TimeStart = [datetime](Get-Date)
        Transcript = $null
        USBPartitions = $null
        Version = [Version]$($MyInvocation.MyCommand.Module.Version)
        WindowsDefenderUpdate  = $null
        WindowsUpdate  = $null
        WindowsUpdateDrivers  = $null
        WindowsImage = $null
        WindowsImageCount = $null
        ZTI = [bool]$false
    }
    #endregion

    #region Set Initialization Defaults
    <#  If this is a Virtual Machine and Skip Recovery Partition
        OVERRIDE:
        $Global:MyOSDCloud.RecoveryPartition = $true
    #>
    if ($Global:OSDCloud.IsVirtualMachine) {
        $Global:OSDCloud.SkipRecoveryPartition = $true
    }
    #endregion

    #region Set Post-Merge Defaults
    $Global:OSDCloud.Version = [Version]$($MyInvocation.MyCommand.Module.Version)

    if ($Global:OSDCloud.RecoveryPartition -eq $true) {
        $Global:OSDCloud.SkipRecoveryPartition = [bool]$false
    }

    if ($Global:OSDCloud.restartComputer -eq $true) {
        $Global:OSDCloud.Restart = [bool]$true
    }

    if ($Global:OSDCloud.SkipAllDiskSteps -eq $true) {
        Write-DarkGrayHost '$OSDCloud.SkipAllDiskSteps = $true'
        $Global:OSDCloud.SkipClearDisk = $true
        $Global:OSDCloud.SkipNewOSDisk = $true
    }

    if ($Global:OSDCloud.IsWinPE -eq $false) {
        $Global:OSDCloud.SkipClearDisk = $true
        $Global:OSDCloud.SkipNewOSDisk = $true
    }

    if ($Global:OSDCloud.ZTI -eq $true) {
        Write-DarkGrayHost '$OSDCloud.ZTI = $true'
        $Global:OSDCloud.ClearDiskConfirm = $false
    }
    #endregion
    #=================================================
    # Make sure there is an Operating System ESD available for deployment, either online or offline.
    if ($global:RecastOSDCloud.OperatingSystemUrlTest -eq $false -and $global:RecastOSDCloud.OperatingSystemCacheObject -eq $false) {
        throw "[$(Get-Date -format s)] WindowsImage ESD is not reachable online or offline. Please verify the source and try again."
    }
    #=================================================
    # v1.5 Start the OSDCloud deployment workflow.
    Step-OSDCloudConfirmDeploymentDisk
    #=================================================
    # v1.5 Push deployment analytics to the Recast OSDCloud telemetry service.
    # Step-OSDCloudTelemetryPSGallery
    # Step-OSDCloudTelemetryPH
    #=================================================
    # v2 USB
    # Only on RecastOSDCloud workflows.
    Step-OSDCloudRemoveUSBDrives
    #=================================================
    # v1 Disk
    Step-OSDCloudClearDisk
    Step-OSDCloudNewDisk
    #=================================================
    # v2 USB and Power
    # Only on RecastOSDCloud workflows.
    Step-OSDCloudRestoreUSBDrives
    Step-OSDCloudEnableHighPerformance
    #=================================================
    # v2 Save the Operating System ESD to the local cache if it is not already cached, or if the online URL is reachable for testing.
    # Only on RecastOSDCloud workflows.
    if ($global:RecastOSDCloud.OperatingSystemCacheObject -eq $true) {
        Step-OSDCloudCopyOperatingSystemCacheObject
    }
    elseif ($global:RecastOSDCloud.OperatingSystemUrlTest -eq $true) {
        Step-OSDCloudSaveOnlineOperatingSystemObject
    }






    Stop-Transcript
    throw
    #=================================================
    # v2 Expand the Operating System after verifying the proper ImageIndex
    Step-OSDCloudGetWindowsImageIndex
    Step-OSDCloudExpandWindowsImage

    Step-OSDCloudRestartLogs
    Step-OSDCloudConfirmWindowsEdition
    Step-OSDCloudBcdBoot
    Step-OSDCloudUpdateSetupDisplayedEula
    Step-OSDCloudUpdatePowerShellModules
    Step-OSDCloudContentFolders
    Step-OSDCloudExportWinPEOemDrivers
    Step-OSDCloudAddWinOSOemDrivers
    Step-OSDCloudAddWinREOemDrivers
    Step-OSDCloudSaveDriverPackOffline
    # Step-OSDCloudSaveDriverPackOnline
    # Step-OSDCloudDriverPackAdd
    # step-Save-WindowsDriver-Firmware
    # step-Add-WindowsDriver-Firmware
    Step-OSDCloudExportOSInformation
    Step-OSDCloudFinish
}
