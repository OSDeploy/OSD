<#
.SYNOPSIS
    Executes the core OSDCloud deployment workflow.

.DESCRIPTION
    Invoke-OSDCloud initializes runtime state in $Global:OSDCloud, merges user-provided configuration
    from global customization hashtables, and runs the end-to-end operating system deployment process.

    The function is the main execution engine used by OSDCloud entry points such as Start-OSDCloud,
    Start-OSDCloudCLI, and GUI launch workflows. It discovers startup/shutdown scripts, applies
    automation artifacts (for example Autopilot JSON), prepares deployment resources, and orchestrates
    imaging and post-configuration actions.

    This function accepts no direct parameters and relies on module/global state populated earlier in
    the launch sequence.

.PARAMETER None
    This function does not define input parameters.

.INPUTS
    None. Pipeline input is not supported.

.OUTPUTS
    Primarily host/progress output and state changes in $Global:OSDCloud. The function is intended to
    perform actions rather than emit structured pipeline objects.

.EXAMPLE
    Invoke-OSDCloud
    Runs OSDCloud using the current global configuration.

.EXAMPLE
    $Global:MyOSDCloud = [ordered]@{
        ZTI = $true
        SkipAutopilot = $true
    }
    Invoke-OSDCloud
    Applies custom values from $Global:MyOSDCloud and starts deployment.

.NOTES
    - Designed for OSDCloud automation and interactive deployment scenarios in WinPE and full Windows.
    - Uses and updates global variables including $Global:OSDCloud, $Global:StartOSDCloud,
      $Global:StartOSDCloudCLI, and $Global:MyOSDCloud when present.
    - Should be called from OSDCloud launch functions that prepare prerequisite state.
#>
function Invoke-RecastOSDCloudCLI {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    $global:RecastOSDeploy.TimeStart = [datetime](Get-Date)
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

    #region Merge Variables
    <#  Overwrite the OSDCloud Master Settings by using custom variables
        MyOSDCloud is the last and final customization variable
    #>
    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global:InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        # Write-DarkGrayHost '[i] Not Used $Global:InvokeOSDCloud'
    }

    if ($Global:StartOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global:StartOSDCloud'
        foreach ($Key in $Global:StartOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:StartOSDCloud.$Key
        }
    }
    else {
        # Write-DarkGrayHost '[i] Not Used $Global:StartOSDCloud'
    }

    if ($Global:StartOSDCloudCLI) {
        Write-DarkGrayHost '[i] Applying $Global:StartOSDCloudCLI'
        foreach ($Key in $Global:StartOSDCloudCLI.Keys) {
            $Global:OSDCloud.$Key = $Global:StartOSDCloudCLI.$Key
        }
    }
    else {
        # Write-DarkGrayHost '[i] Not Used $Global:StartOSDCloudCLI'
    }

    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost '[i] Reapplying $Global:InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        # Write-DarkGrayHost '[i] Not Used $Global:InvokeOSDCloud'
    }

    if ($Global:MyOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global:MyOSDCloud'
        foreach ($Key in $Global:MyOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:MyOSDCloud.$Key
        }
    }
    else {
        # Write-DarkGrayHost '[i] Not Used $Global:MyOSDCloud'
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
    Step-OSDCloudPreinstallLogs
    # Step-OSDCloudPreinstallHooks
    Step-OSDCloudConfirmOperatingSystem
    # Step-OSDCloudConfirmAutopilotJson
    # Step-OSDCloudConfirmOfficeODT
    Step-OSDCloudConfirmDeploymentDisk
    Step-OSDCloudConfirmWindowsESDOnline
    Step-OSDCloudConfirmWindowsESDOffline
    Step-OSDCloudConfirmDriverPackOnline
    Step-OSDCloudConfirmDriverPackOffline
    if ($global:RecastOSDeploy.ConfirmWindowsESDOnline -eq $false -and $global:RecastOSDeploy.ConfirmWindowsESDOffline -eq $false) {
        throw "[$(Get-Date -format s)] WindowsImage ESD is not reachable online or offline. Please verify the source and try again."
    }
    # Step-OSDCloudTelemetryPSGallery
    # Step-OSDCloudTelemetryPH
    Step-OSDCloudRemoveUSBDrives
    Step-OSDCloudClearDisk
    Step-OSDCloudNewDisk
    Step-OSDCloudRestoreUSBDrives
    Step-OSDCloudEnableHighPerformance
    Step-OSDCloudSaveWindowsESDOffline
    Step-OSDCloudSaveWindowsESDOnline
    Step-OSDCloudGetWindowsImageIndex
    Step-OSDCloudExpandWindowsImage
    Step-OSDCloudRestartLogs
    Step-OSDCloudConfirmWindowsEdition
    Step-OSDCloudBcdBoot
    Step-OSDCloudContentFolders
    Step-OSDCloudExportWinPEOemDrivers
    Step-OSDCloudAddWinOSOemDrivers
    Step-OSDCloudAddWinREOemDrivers
    if ($global:OSDCoreDriverPackObject) {
        Step-OSDCloudDriverPackSave
        Step-OSDCloudDriverPackAdd
    }
    # step-Save-WindowsDriver-Firmware
    # step-Add-WindowsDriver-Firmware
    Step-OSDCloudUpdateSetupDisplayedEula
    Step-OSDCloudUpdatePowerShellModules
    Step-OSDCloudExportOSInformation
    Step-OSDCloudFinish
}
