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

.LINK
    Start-OSDCloud
    Start-OSDCloudCLI
#>
function Invoke-RecastOSDCloudCLI {
    [CmdletBinding()]
    param ()
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
    #region Global:OSDCloud.DebugMode
    if ($Global:OSDCloud.DebugMode -eq $true){
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DebugMode Write OSDCloud Vars"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Writing OSDCloud Variables to $($env:temp)\OSDCloudVars.log"
        $OSDCloud | Out-File $env:temp\OSDCloudVars.log
    }
    #endregion
    #region Global:OSDCloud.SplashScreen
    if ($Global:OSDCloud.SplashScreen -eq $true){
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Setup SplashScreen"
        $RegPath = "HKLM:\SOFTWARE\OSDCloud"
        if (!(Test-Path -Path $RegPath)){New-Item -Path $RegPath -Force}
        New-ItemProperty -Path $RegPath -Name "OSVersion" -Value $Global:OSDCloud.OSVersion
        New-ItemProperty -Path $RegPath -Name "OSReleaseID" -Value $Global:OSDCloud.OSReleaseID
        New-ItemProperty -Path $RegPath -Name "OSEdition" -Value $Global:OSDCloud.OSEdition
        New-ItemProperty -Path $RegPath -Name "OSLicense" -Value $Global:OSDCloud.OSActivation
        New-ItemProperty -Path $RegPath -Name "OSActivation" -Value $Global:OSDCloud.OSActivation
    }
    #endregion
    #region Global:OSDCloud.SetWiFi
    if ($Global:OSDCloud.SetWiFi -eq $true){
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Gathering WiFi Information"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Please Supply the SSID & Press Enter - CASE SENSITIVE"
        if (!($SSID)){$SSID = Read-Host}
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Please Supply the Password & Press Enter - CASE SENSITIVE"
        if (!($PSK)){$PSK = Read-Host -AsSecureString}
    }
    #endregion
    #region Global:OSDCloud.MS365Install
    if ($Global:OSDCloud.MS365Install -eq $true){
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Gathering M365 Information"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Please Supply the CompanyName & Press Enter - CASE SENSITIVE"
        if (!($M365CompanyName)){$M365CompanyName = Read-Host}
        if ($M365CompanyName -eq ""){$M365CompanyName = "Organization"}
    }
    #endregion
    Step-OSDCloudPreinstallHooks
    Step-OSDCloudConfirmOperatingSystem
    # Step-OSDCloudConfirmAutopilotJson
    # Step-OSDCloudConfirmOfficeODT
    Step-OSDCloudConfirmDisk
    # Step-OSDCloudTelemetryPSGallery
    # Step-OSDCloudTelemetryPH
    Step-OSDCloudRemoveUSBDrives
    Step-OSDCloudClearDisk
    Step-OSDCloudNewDisk
    Step-OSDCloudRestoreUSBDrives
    Step-OSDCloudMoveLogs
    Step-OSDCloudEnableHighPerformance
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreOperatingSystemObject"
    $global:OSDCoreOperatingSystemObject | Out-Host
    Step-OSDCloudCopyWindowsESD
    Step-OSDCloudSaveWindowsESD
    Pause
    # Align the OSEdition with the OSEditionId
    $editionIdMap = @{
        'Home'                 = 'Core'
        'Home N'               = 'CoreN'
        'Home Single Language' = 'CoreSingleLanguage'
        'Education'            = 'Education'
        'Education N'          = 'EducationN'
        'Pro'                  = 'Professional'
        'Pro N'                = 'ProfessionalN'
        'Enterprise'           = 'Enterprise'
        'Enterprise N'         = 'EnterpriseN'
    }
    if ($Global:OSDCloud.OSEdition -and $editionIdMap.ContainsKey($Global:OSDCloud.OSEdition)) {
        $Global:OSDCloud.OSEditionId = $editionIdMap[$Global:OSDCloud.OSEdition]
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSEditionId is set to $($Global:OSDCloud.OSEditionId)"

    # Match the OSEditionId to the OSImageIndex
    if ($Global:OSDCloud.OSEditionId) {
        $MatchingWindowsImage = $Global:OSDCloud.WindowsImage | `
            ForEach-Object { Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName -Index $_.ImageIndex } | `
            Where-Object { $_.EditionId -eq $Global:OSDCloud.OSEditionId }

        if ($MatchingWindowsImage) {
            if ($MatchingWindowsImage.Count -eq 1) {
                $Global:OSDCloud.OSImageIndex = $MatchingWindowsImage.ImageIndex
            }
        }
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSImageIndex is set to $($Global:OSDCloud.OSImageIndex)"

    # Does the WindowsImage contain the ImageIndex?
    if ($Global:OSDCloud.WindowsImage | Where-Object {$_.ImageIndex -eq $Global:OSDCloud.OSImageIndex}) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] WindowsImage contains the required ImageIndex"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Select the Windows Image to expand"
        $SelectedWindowsImage = $Global:OSDCloud.WindowsImage | Where-Object {$_.ImageSize -gt 3000000000}

        if ($SelectedWindowsImage) {
            $SelectedWindowsImage | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Select an Image to apply by ImageIndex [Number]"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $SelectedWindowsImage.ImageIndex))))

            #$Global:OSDCloud.OSImageIndex = $SelectedWindowsImage | Where-Object {$_.ImageIndex -eq $SelectReadHost}
            $Global:OSDCloud.OSImageIndex = $SelectReadHost
        }
    }
    if ($Global:OSDCloud.OSImageIndex) {
        $Global:OSDCloud.WindowsImage | Where-Object {$_.ImageSize -gt 3000000000} | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host
    }
    else {
        #=================================================
        #	FAILED
        #=================================================
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] OSDCloud Failed"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Could not find a proper Windows Image for deployment"
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press Ctrl+C to exit"
        Start-Sleep -Seconds 86400
        Exit
    }
    #=================================================
    #   Create ScratchDirectory
    $Params = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        ItemType    = 'Directory'
        Path        = 'C:\OSDCloud\Temp'
    }
    if (-NOT (Test-Path $Params.Path -ErrorAction SilentlyContinue)) {
        New-Item @Params | Out-Null
    }
    #=================================================
    # Build the Params
    if ($Global:OSDCloud.ImageFileDestination.FullName -match ".swm") {
        $ExpandWindowsImage = @{
            ApplyPath = 'C:\'
            ErrorAction = 'Stop'
            ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
            Name = (Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName).ImageName
            ScratchDirectory = 'C:\OSDCloud\Temp'
            SplitImageFilePattern = ($Global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm")
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] SplitImageFilePattern: $(($Global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm"))"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Name: $((Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName).ImageName)"
    }
    else {
        $ExpandWindowsImage = @{
            ApplyPath = 'C:\'
            ErrorAction = 'Stop'
            ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
            Index = $Global:OSDCloud.OSImageIndex
            ScratchDirectory = 'C:\OSDCloud\Temp'
        }
    }
    #endregion
    #=================================================
    #region Expand WindowsImage
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand-WindowsImage"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] ApplyPath: 'C:\'"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] ImagePath: $($Global:OSDCloud.ImageFileDestination.FullName)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Index: $($Global:OSDCloud.OSImageIndex)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] ScratchDirectory: 'C:\OSDCloud\Temp'"

    $Global:OSDCloud.ExpandWindowsImage = $ExpandWindowsImage
    if ($Global:OSDCloud.IsWinPE -eq $true) {
        try {
            Write-DarkGrayHost -Message 'Expand-WindowsImage'
            Expand-WindowsImage @ExpandWindowsImage
        }
        catch {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Expand-WindowsImage failed."
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $_"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press Ctrl+C to cancel OSDCloud"
            Start-Sleep -Seconds 86400
            exit
        }
    }
    #endregion
    #=================================================
    Step-OSDCloudWriteGetWindowsEdition
    Step-OSDCloudBcdBoot
    Step-OSDCloudNewItemContentFolders
    Step-OSDCloudExportWindowsDriverOemWinPE
    Step-OSDCloudAddWindowsDriverOemWinOS
    Step-OSDCloudAddWindowsDriverOemWinRE

    #region Drivers
        #region Get-OSDCloudDriverPack
        Write-SectionHeader 'OSDCloud DriverPack'
        #Check the Global Variables for a Driver Pack name
        if ($Global:OSDCloud.HPCMSLDriverPackLatest -eq $true){
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Request to use HP CMSL to download Driver Pack, setting DriverPackName to None"
            if (Test-WebConnection -Uri "google.com") {
                $Global:OSDCloud.DriverPackName = 'None' #Set to None to prevent any other DriverPack from being used
            }
            else {
                $Global:OSDCloud.HPCMSLDriverPackLatest = $false
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Unable to reach internet, will not attempt to download HP Driver Pack via CMSL"
            }
        }

        if ($global:OSDCloudDeploy.DriverPackObject) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud v2 DriverPack"
            $Global:OSDCloud.DriverPack = $global:OSDCloudDeploy.DriverPackObject
        }
        elseif ($Global:OSDCloud.DriverPackName) {
            if ($Global:OSDCloud.DriverPackName -match 'None') {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is set to None"
                $Global:OSDCloud.DriverPack = $null
                if ((Test-DISMFromOSDCloudUSB) -eq $true){
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                    #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
                    Start-DISMFromOSDCloudUSB
                    $DriverPPKGNeeded = $false
                }
                else {
                    if ($Global:OSDCloud.HPCMSLDriverPackLatest -eq $true){
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Attempting to use HPCMSL Functions to download Latest Driver Pack for Model"
                        $HPDriverPack = Get-HPDriverPackLatest
                        if ($HPDriverPack -ne $false){
                            $HPDriverPackObject = @{
                                Name = $HPDriverPack.Name
                                Product = Get-MyComputerProduct
                                FileName = ($HPDriverPack.url).Split('/')[-1]
                                Url = $HPDriverPack.Url
                            }
                            $Global:OSDCloud.DriverPack = $HPDriverPackObject
                            $Global:OSDCloud.HPCMSLDriverPackLatestFound = $HPDriverPack
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Found HP Driver Pack via CMSL, Setting Variables"
                        }
                        else {
                            $Global:OSDCloud.HPCMSLDriverPackLatest = $false
                        }
                    }
                }
            }
            elseif ($Global:OSDCloud.DriverPackName -match 'Microsoft Update Catalog') {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is set to Microsoft Update Catalog"
                $Global:OSDCloud.DriverPack = $null
            }
            else {
                $Global:OSDCloud.DriverPack = Get-OSDCloudDriverPacks | Where-Object {$_.Name -eq $Global:OSDCloud.DriverPackName} | Select-Object -First 1
            }
        }
        else {
            if ($Global:OSDCloud.Product) {
                $Global:OSDCloud.DriverPack = Get-OSDCloudDriverPack -Product $Global:OSDCloud.Product | Select-Object -First 1
            }
            else {
                $Global:OSDCloud.DriverPack = Get-OSDCloudDriverPack | Select-Object -First 1
            }
        }

        # Get the DriverPack BaseName from the DriverPack FileName
        if ($Global:OSDCloud.DriverPack) {
            $Global:OSDCloud.DriverPackBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Global:OSDCloud.DriverPack.FileName)
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackBaseName is set to $($Global:OSDCloud.DriverPackBaseName) from the DriverPack"
        }

        # Check for file on Azure Storage if AzOSDCloudBlobDriverPack and DriverPackBaseName is set
        if ($Global:OSDCloud.AzOSDCloudBlobDriverPack -and $Global:OSDCloud.DriverPackBaseName) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Searching for DriverPack in Azure Storage"
            $Global:OSDCloud.AzOSDCloudDriverPack = $Global:OSDCloud.AzOSDCloudBlobDriverPack | Where-Object {$_.Name -match $Global:OSDCloud.DriverPackBaseName} | Select-Object -First 1
            if ($Global:OSDCloud.AzOSDCloudDriverPack) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack has been located in Azure Storage"
                $Global:OSDCloud.AzOSDCloudDriverPack | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\AzOSDCloudDriverPack.json' -Encoding ascii -Width 2000
            }
        }

        # OSDCloud v2 DriverPack
        if ($global:InvokeOSDCloud.DriverPackObject) {
            Step-OSDCloudDriverPackSave
            Step-OSDCloudDriverPackAdd
        }
        elseif ($Global:OSDCloud.DriverPack) {
            $SaveMyDriverPack = $null
            if ((Test-DISMFromOSDCloudUSB -PackageID $Global:OSDCloud.DriverPack.PackageID) -eq $true){
                $Global:OSDCloud.DriverPackDISM = $true
                $Global:OSDCloud.DriverPackName = 'None'
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
            }
            else{
                $Global:OSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $Global:OSDCloud.DriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
                $Global:OSDCloud.DriverPackOffline = $Global:OSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1
            }
            if ($Global:OSDCloud.DriverPackOffline) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is available on OSDCloudUSB and will not be downloaded"
                Write-DarkGrayHost $Global:OSDCloud.DriverPack.Name
                Write-DarkGrayHost $Global:OSDCloud.DriverPackOffline.FullName
                #$Global:OSDCloud.DriverPackSource = Find-OSDCloudFile -Name (Split-Path -Path $Global:OSDCloud.DriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $Global:OSDCloud.DriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
                $Global:OSDCloud.DriverPackSource = $Global:OSDCloud.DriverPackOffline
            }
            if ($Global:OSDCloud.DriverPackSource) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is being copied from OSDCloudUSB at $($Global:OSDCloud.DriverPackSource.FullName) to C:\Drivers"
                Copy-Item -Path $Global:OSDCloud.DriverPackSource.FullName -Destination 'C:\Drivers' -Force
                $Global:OSDCloud.DriverPackExpand = $true
            }
            elseif ($Global:OSDCloud.DriverPackDISM){
                #Use the Expanded Drivers on the OSDCloudUSB drive
                Start-DISMFromOSDCloudUSB -PackageID $Global:OSDCloud.DriverPack.PackageID
            }
            elseif ($Global:OSDCloud.HPCMSLDriverPackLatestFound){
                #Download HP Driver Pack from HP CMSL

                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Driver Pack Downloading to c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"
                Get-HPDriverPackLatest -download
                if (Test-Path -Path "c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"){
                    Write-DarkGrayHost -Message "Confirmed Downloaded to c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"
                    $Global:OSDCloud.DriverPackExpand = $true
                    $Global:OSDCloud.DriverPackName = 'None' #Skips adding MS Update Catalog drivers into Process
                    #$Global:OSDCloud.OSDCloudUnattend = $true #Skips installing the PPKG File to load drivers in Specialize
                }
            }
            elseif ($Global:OSDCloud.AzOSDCloudDriverPack) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is being downloaded from Azure Storage to C:\Drivers"

                try {
                    Get-AzStorageBlobContent -CloudBlob $Global:OSDCloud.AzOSDCloudDriverPack.ICloudBlob -Context $Global:OSDCloud.AzOSDCloudDriverPack.Context -Destination "C:\Drivers\$(Split-Path $Global:OSDCloud.AzOSDCloudDriverPack.Name -Leaf)"
                }
                catch {
                    Get-AzStorageBlobContent -CloudBlob $Global:OSDCloud.AzOSDCloudDriverPack.ICloudBlob -Context $Global:OSDCloud.AzOSDCloudDriverPack.Context -Destination "C:\Drivers\$(Split-Path $Global:OSDCloud.AzOSDCloudDriverPack.Name -Leaf)"
                }

                $Global:OSDCloud.DriverPackExpand = $true
            }
            elseif ($Global:OSDCloud.DriverPack.Guid) {
                $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Guid $Global:OSDCloud.DriverPack.Guid
            }
            if ($Global:OSDCloud.DriverPackExpand) {
                $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

                foreach ($Item in $DriverPacks) {
                    $SaveMyDriverPack = $Item.FullName
                    $ExpandFile = $Item.FullName
                    Write-Verbose -Verbose "DriverPack: $ExpandFile"
                    #=================================================
                    #   Cab
                    #=================================================
                    if ($Item.Extension -eq '.cab') {
                        $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                        if (-NOT (Test-Path "$DestinationPath")) {
                            New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack CAB is being expanded to $DestinationPath"
                            Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null
                        }
                        Continue
                    }
                    #=================================================
                    #   Zip
                    #=================================================
                    if ($Item.Extension -eq '.zip') {
                        $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack ZIP is being expanded to $DestinationPath"
                            Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                        }
                        Continue
                    }
                    #=================================================
                    #   Dell Update Package
                    #=================================================
                    if ($Item.Extension -eq '.exe' -and $Global:OSDCloud.Manufacturer -eq 'Dell') {
                        $DestinationPath = Join-Path $Item.Directory $Item.BaseName
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Dell Update Package is being expanded to $DestinationPath"
                            Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=$DestinationPath" -Wait
                        }
                        Continue
                    }
                    #=================================================
                    #   HP Softpaq
                    #=================================================
                    if ($Global:OSDCloud.Manufacturer -eq 'HP'){ #If HP
                        if ($Item.Extension -eq '.exe'){ #If found an EXE in c:\drivers
                            if (Test-Path -Path $env:windir\System32\7za.exe){ #If 7zip is found
                                Write-Host -ForegroundColor Cyan "Found 7zip, using to Expand HP Softpaq"
                                Write-Host "SaveMyDriverPack: $SaveMyDriverPack"
                                Write-Host "SaveMyDriverPack.FullName: $($SaveMyDriverPack.FullName)"
                                $DestinationPath = Join-Path $Item.Directory $Item.BaseName
                                if (-NOT (Test-Path "$DestinationPath")) { #If DestinationPath does not exist already
                                    Write-Host "HP Driver Pack $ExpandFile is being expanded to $DestinationPath"
                                    Start-Process -FilePath $env:windir\System32\7za.exe -ArgumentList "x $ExpandFile -o$DestinationPath -y" -Wait -NoNewWindow -PassThru
                                    Write-Host "7zip has expanded the HP Driver Pack to $DestinationPath"
                                    #$Global:OSDCloud.OSDCloudUnattend = $true
                                    $DriverPPKGNeeded = $false #Disable PPKG for HP Driver Pack during Specialize
                                    $Global:OSDCloud.DriverPackName = 'None' #Skips adding MS Update Catalog drivers into Process
                                }
                                Continue
                            }
                            else{
                                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] 7zip not found, unable to expand HP Softpaq"
                                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Please add 7zip your OSDCloud Boot Media to use this feature"
                            }
                        }
                    }
                    #=================================================
                }
            }

            if ($SaveMyDriverPack) {
                if (-not ($Global:OSDCloud.DriverPackSource)) {
                    #=================================================
                    #	Cache to OSDCloudUSB
                    #=================================================
                    $OSDCloudUSB = Get-USBVolume | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Where-Object {$_.SizeRemainingGB -ge 2} | Select-Object -First 1
                    if ($OSDCloudUSB) {
                        if (Test-Path -Path $SaveMyDriverPack){
                            $DriverPackPath = $SaveMyDriverPack
                        }
                        if ($null -ne $SaveMyDriverPack.FullName){
                            if (Test-Path -Path $SaveMyDriverPack.FullName){
                                $DriverPackPath = $SaveMyDriverPack.FullName
                            }
                        }
                        if (Test-Path $DriverPackPath){
                            $OSDCloudUSBDestination = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\$($Global:OSDCloud.Manufacturer)"
                            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Copying Driver Pack $DriverPackPath to OSDCloudUSB at $OSDCloudUSBDestination"
                            If (!(Test-Path $OSDCloudUSBDestination)) {
                                $null = New-Item -Path $OSDCloudUSBDestination -ItemType Directory -Force
                            }
                            $null = Copy-Item -Path $DriverPackPath -Destination $OSDCloudUSBDestination -Force -PassThru -ErrorAction Stop
                        }
                    }
                }
            }
        }
        #endregion

        #region Save-SystemFirmwareUpdate
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Update Catalog Firmware"

        if ($OSDCloud.IsOnBattery -eq $true) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Update Catalog Firmware is not enabled for devices on battery power"
        }
        elseif ($OSDCloud.IsVirtualMachine) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Update Catalog Firmware is not enabled for Virtual Machines"
        }
        elseif ($Global:OSDCloud.MSCatalogFirmware -eq $false) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Update Catalog Firmware is not enabled for this deployment"
        }
        else {
            if (Test-MicrosoftUpdateCatalog) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Firmware Updates will be downloaded from Microsoft Update Catalog to C:\Drivers\Firmware"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Some systems do not support a driver Firmware Update"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] You may have to enable this setting in your BIOS or Firmware Settings"

                Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Unable to download or find firmware for this Device"
            }
        }
        #endregion

        #region Save-MsUpCatDriver
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Update Catalog Drivers"

        if ($Global:OSDCloud.DriverPackName -eq 'None') {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers from Microsoft Update Catalog will not be applied for this deployment"
        }
        else {
            if (Test-MicrosoftUpdateCatalog) {
                $DestinationDirectory = 'C:\Drivers\MsUpCatDrivers'
                if ($Global:OSDCloud.DriverPackName -eq 'Microsoft Update Catalog') {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers for all devices will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                }
                elseif ($null -eq $SaveMyDriverPack) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers for all devices will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                }
                else {
                    if ($OSDCloud.MSCatalogDiskDrivers) {
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers for PNPClass DiskDrive will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'DiskDrive'
                    }
                    if ($OSDCloud.MSCatalogNetDrivers) {
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers for PNPClass Net will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'Net'
                    }
                    if ($OSDCloud.MSCatalogScsiDrivers) {
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers for PNPClass SCSIAdapter will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'SCSIAdapter'
                    }
                }
            }
            if ((Test-DISMFromOSDCloudUSB) -eq $true){
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
                Start-DISMFromOSDCloudUSB
                $DriverPPKGNeeded = $false
            }
        }
        #endregion

        #region Add-OfflineServicingWindowsDriver
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Add Windows Driver with Offline Servicing (Add-OfflineServicingWindowsDriver)"
        Write-Verbose -Message "https://docs.microsoft.com/en-us/powershell/module/dism/add-windowsdriver"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Drivers in C:\Drivers are being added to the offline Windows Image"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] This process can take up to 20 minutes"
        Write-Verbose -Message "Add-OfflineServicingWindowsDriver"
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Add-OfflineServicingWindowsDriver
        }
        #endregion

        #region Specialize Driver Pack installation
        if ($Global:OSDCloud.OSDCloudUnattend -eq $true) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Set Specialize Unattend.xml (Set-OSDCloudUnattendSpecialize)"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] C:\Windows\Panther\Invoke-OSDSpecialize.xml is being applied as an Unattend file"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] This will enable the extraction and installation of HP, Lenovo, and Microsoft Surface Drivers if necessary"
            if ($Global:OSDCloud.IsWinPE -eq $true) {
                if ($Global:OSDCloud.DevMode -eq $true){
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Running in DEV Mode, running Set-OSDCloudUnattendSpecializeDEV instead"
                    Set-OSDCloudUnattendSpecializeDev
                }
                else {
                    Set-OSDCloudUnattendSpecialize
                    #Set-OSDxCloudUnattendSpecialize -Verbose
                }
            }
        }
        else {
            if ($DriverPPKGNeeded -ne $false){
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud DriverPack Provisioning Package"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] This will enable the extraction and installation of HP, Dell, Lenovo, and Microsoft Surface Drivers"
                Invoke-OSDCloudDriverPackPPKG
            }
        }
        #endregion
    #endregion

    #region Gary Blok create SetupComplete.cmd
    if (Test-WebConnection -Uri "google.com") {
        $WebConnection = $True
    }
    if (!($SSID)){
        $SSID = Get-WiFiActiveProfileSSID
        if ($SSID){
            $PSK = Get-WiFiProfileKey -SSID $SSID
            if ($PSK){
                $Global:OSDCloud.SetWiFi = $true
            }
        }
    }
    if ($Global:OSDCloud.SetWiFi -eq $true){
        Write-Host -ForegroundColor Cyan "Adding WiFi Tasks into JSON Config File for Action during Specialize"
        $PSKText = [System.Net.NetworkCredential]::new("", $PSK).Password
        $HashTable = @{
            'Addons' = @{
                'SSID' = $SSID
                'PSK' = $PSKText
            }
        }
        $HashVar = $HashTable | ConvertTo-Json
        $ConfigPath = "c:\osdcloud\configs"
        $ConfigFile = "$ConfigPath\WiFi.JSON"
        try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
        catch {}
        $HashVar | Out-File $ConfigFile
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Creating SetupComplete.cmd and SetupComplete.ps1"
    #Creates the SetupComplete.cmd & SetupComplete.ps1 files in C:\Windows\Setup\scripts
    #SetupComplete.cmd calls SetupComplete.ps1, which does all of the actual work
    Set-SetupCompleteCreateStart

    if ($Null -eq $Global:OSDCloud.SetWiFi){$Global:OSDCloud.SetWiFi = $false}
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Wireless from Global Variable `$Global:OSDCloud.SetWiFi is set to $($Global:OSDCloud.SetWiFi)"
    if ($Global:OSDCloud.SetWiFi -eq $true) {
        $SetWiFi = $true
        Set-SetupCompleteSetWiFi
    }
    if ($Global:OSDCloud.IsWinPE -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Windows Defender Update from Global Variable `$Global:OSDCloud.WindowsDefenderUpdate is set to $($Global:OSDCloud.WindowsDefenderUpdate)"
        if ($Global:OSDCloud.WindowsDefenderUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteDefenderUpdate
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] No Internet or Future WiFi Configured, disabling Defender Updates"
            }
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Windows Update from Global Variable `$Global:OSDCloud.WindowsUpdate is set to $($Global:OSDCloud.WindowsUpdate)"
        if ($Global:OSDCloud.WindowsUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdate
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] No Internet or Future WiFi Configured, disabling Windows Updates"
            }
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Windows Update Drivers from Global Variable `$Global:OSDCloud.WindowsUpdateDrivers is set to $($Global:OSDCloud.WindowsUpdateDrivers)"
        if ($Global:OSDCloud.WindowsUpdateDrivers -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdateDriver
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] No Internet or Future WiFi Configured, disabling Windows Update Driver Updates"
            }
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable DevMode from Global Variable `$Global:OSDCloud.DevMode is set to $($Global:OSDCloud.DevMode)"
        if ($Global:OSDCloud.DevMode -eq $true) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable NetFx3 from Global Variable `$Global:OSDCloud.NetFx3 is set to $($Global:OSDCloud.NetFx3)"
            if ($Global:OSDCloud.NetFx3 -eq $true){
                if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                    Set-SetupCompleteNetFX
                }
                else {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] No Internet or Future WiFi Configured, disabling NetFX Install"
                }
            }
        }
        if ($Null -eq $Global:OSDCloud.SetTimeZone) { $Global:OSDCloud.SetTimeZone = $false }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Set TimeZone from Global Variable `$Global:OSDCloud.SetTimeZone is set to $($Global:OSDCloud.SetTimeZone)"
        if ($Global:OSDCloud.SetTimeZone -eq $true) {
            if ($WebConnection -eq $true) {
                Set-TimeZoneFromIP
            }
            else {
                Set-SetupCompleteTimeZone
            }
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable OEM Activation from Global Variable `$Global:OSDCloud.OEMActivation is set to $($Global:OSDCloud.OEMActivation)"
        if ($Global:OSDCloud.OEMActivation -eq $true){
            Set-SetupCompleteOEMActivation
        }
    }
    #=================================================
    #region Dell Updates Config for Specialize Phase
    if (($Global:OSDCloud.DevMode -eq $true) -and ($WebConnection -eq $true)){
        if (($Global:OSDCloud.DCUInstall -eq $true) -or ($Global:OSDCloud.DCUDrivers -eq $true) -or ($Global:OSDCloud.DCUFirmware -eq $true) -or ($Global:OSDCloud.DCUBIOS -eq $true) -or ($Global:OSDCloud.DCUAutoUpdateEnable -eq $true) -or ($Global:OSDCloud.DellTPMUpdate -eq $true)){

            #Set Enable Specialize to be triggered later
            $EnableSpecialize = $true

            Write-Host -ForegroundColor Cyan "Adding Dell Tasks into JSON Config File for Action during Specialize"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Install Dell Command Update = $($Global:OSDCloud.DCUInstall) | Run DCU Drivers = $($Global:OSDCloud.DCUDrivers) | Run DCU Firmware = $($Global:OSDCloud.DCUFirmware)"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Run DCU BIOS = $($Global:OSDCloud.DCUBIOS) | Enable DCU Auto Update = $($Global:OSDCloud.DCUAutoUpdateEnable) | DCU TPM Update = $($Global:OSDCloud.DellTPMUpdate) "
            $HashTable = @{
                'Updates' = @{
                    'DCUInstall' = $Global:OSDCloud.DCUInstall
                    'DCUDrivers' = $Global:OSDCloud.DCUDrivers
                    'DCUFirmware' = $Global:OSDCloud.DCUFirmware
                    'DCUBIOS' = $Global:OSDCloud.DCUBIOS
                    'DCUAutoUpdateEnable' = $Global:OSDCloud.DCUAutoUpdateEnable
                    'DellTPMUpdate' = $Global:OSDCloud.DellTPMUpdate
                }
            }
            $HashVar = $HashTable | ConvertTo-Json
            $ConfigPath = "c:\osdcloud\configs"
            $ConfigFile = "$ConfigPath\DELL.JSON"
            try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
            catch {}
            $HashVar | Out-File $ConfigFile
        }
    }
    #endregion
    #=================================================
    #region HP Updates Config for Specialize Phase
    #Set Specialize JSON

    if (($Global:OSDCloud.HPIAAll -eq $true) -or ($Global:OSDCloud.HPIADrivers -eq $true) -or ($Global:OSDCloud.HPIAFirmware -eq $true) -or ($Global:OSDCloud.HPIASoftware -eq $true) -or ($Global:OSDCloud.HPTPMUpdate -eq $true) -or ($Global:OSDCloud.HPBIOSUpdate -eq $true)){
        if ($WebConnection) {  #This all requires the device to be online to download updates
            if (Test-HPIASupport){
                #Set Enable Specialize to be triggered later
                #$EnableSpecialize = $true #Disabling on 24.1.7, adding lower into the process only if TPM update is needed


                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] HP Enterprise Options Setup"
                Write-Host -ForegroundColor DarkGray " Confirmed Internet Connectivity"
                Write-Host -ForegroundColor DarkGray " Confirmed HP Tools Supported [Test-HPIASupport]"
                $HPFeaturesEnabled = $true
                write-host -ForegroundColor DarkGray " Confirm HPCMSL Installed [Install-ModuleHPCMSL]"
                Install-ModuleHPCMSL
                #If BIOS Update Desired, Confirm Update Available, if Not, set to False
                if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
                    [version]$HPBIOSVersion = Get-HPBIOSVersion
                    [version]$Latest = $((Get-HPBIOSUpdates -Latest).ver)
                    Write-Output "Checking HP BIOS Version via HPCMSL"
                    Write-Output " HP BIOS Ver Available: $Latest"
                    Write-Output " Installed BIOS Ver: $HPBIOSVersion"
                    #If Latest BIOS Available is Less than or Equal to Installed BIOS, Disable BIOS Update
                    if ($Latest -le $HPBIOSVersion){
                        $Global:OSDCloud.HPBIOSUpdate = $false
                    }
                }
                #Get Sure Admin State
                try {
                    Write-Host -ForegroundColor DarkGray "Testing for HP Sure Admin State"
                    $namespace = "ROOT\HP\InstrumentedBIOS"
                    $classname = "HP_BIOSEnumeration"
                    if (Get-CimInstance -ClassName $classname -Namespace $namespace | Where-Object {$_.Name -match "Enhanced BIOS Authentication"}){
                        $HPSureAdminState = Get-HPSureAdminState -ErrorAction SilentlyContinue
                    }
                }
                catch{
                    Write-Host -ForegroundColor DarkGray "Unable to Test for HP Sure Admin State"
                }
                if ($HPSureAdminState) {$HPSureAdminMode = $HPSureAdminState.SureAdminMode}

                if ($Global:OSDCloud.HPTPMUpdate -eq $true){
                    $TPMResult = Get-HPTPMDetermine
                    if (($TPMResult -ne "SP94937") -and ($TPMResult -ne "SP87753")){
                        Write-Host -ForegroundColor DarkGray "Switching HP TPM off, as no TPM Update is available"
                        $Global:OSDCloud.HPTPMUpdate = $false
                    }
                }
                if (($Global:OSDCloud.HPTPMUpdate -eq $true) -or ($Global:OSDCloud.HPBIOSUpdate -eq $true)){
                    if ($HPSureAdminMode -eq "On"){
                        Write-Host "HP Sure Admin Enabled, Unable to Modify HP BIOS Settings or Perform HP BIOS / TPM Updates" -ForegroundColor Yellow
                        if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
                            $Global:OSDCloud.HPBIOSUpdate = $false  #Set to False if Sure Admin Enable
                            $HPBIOSWinUpdate = $true #Attempt to use Windows Update Version Instead
                        }
                        $Global:OSDCloud.HPTPMUpdate = $false
                    }
                    else { #Sure Admin Mode is Off
                        if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
                            try { #Test for BIOS Password
                                Write-Host -ForegroundColor DarkGray "Testing for HP BIOS Password"
                                $PasswordSet = Get-HPBIOSSetupPasswordIsSet -ErrorAction SilentlyContinue
                            }
                            catch {
                                <#Do this if a terminating exception happens#>
                            }
                            if ($PasswordSet -eq $true){
                                Write-Host -ForegroundColor DarkGray "Device currently has BIOS Setup Password, Attempting to use Get-HPBIOSWindowsUpdate Later in Process"
                                $HPBIOSWinUpdate = $true
                            }
                            else{ #No Password & No Sure Recover and there must be an update, so lets try to update it.
                                Write-Host -ForegroundColor Gray "Starting HP BIOS Update Process Job using HPCMSL [Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore]"
                                Write-Host -ForegroundColor DarkGray " Current Firmware: $(Get-HPBIOSVersion)"
                                Write-Host -ForegroundColor DarkGray " Staging Update: $((Get-HPBIOSUpdates -Latest).ver) "
                                #Details: https://developers.hp.com/hp-client-management/doc/Get-HPBiosUpdates
                                $timeoutSeconds = 60 # 1 Minite Timeout for BIOS Update
                                $code = {
                                    Start-Transcript -Path "C:\OSDCloud\Logs\HPBIOSUpdateJob.log"
                                    Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore -ErrorAction SilentlyContinue -Verbose
                                    Stop-Transcript
                                }
                                #Start the Job
                                $HPBIOSUpdateNotes = "Attempted in WinPE - Update to $((Get-HPBIOSUpdates -Latest).ver)"
                                $Installing = Start-Job -ScriptBlock $code
                                # Report the job ID (for diagnostic purposes)
                                write-host -ForegroundColor DarkGray " BIOS Update Job ID: $($Installing.Id)"
                                Write-Host -ForegroundColor DarkGray " See Log: C:\OSDCloud\Logs\HPBIOSUpdateJob.log for Details"

                                # Wait for the job to complete or time out
                                Wait-Job $Installing -Timeout $timeoutSeconds | Out-Null
                                #Receive-Job -Job $Installing
                                # Check the job state
                                if ($Installing.State -eq "Completed") {
                                    # Job completed successfully
                                    write-host -ForegroundColor DarkGray " Completed running Job to Update BIOS"
                                } elseif ($Installing.State -eq "Running") {
                                    # Job was interrupted due to timeout
                                    write-host -ForegroundColor DarkGray " Job to Update BIOS was Interrupted"
                                    "Interrupted"
                                } else {
                                    # Unexpected job state
                                    write-host -ForegroundColor DarkGray " Job to Update BIOS went to an Unexpected State, see log"
                                }
                                # Clean up the job
                                Remove-Job -Force $Installing
                                if (Test-Path -Path "C:\OSDCloud\Logs\HPBIOSUpdateJob.log"){
                                    Write-Host -ForegroundColor Cyan " $((Get-content -Path "C:\OSDCloud\Logs\HPBIOSUpdateJob.log" -ReadCount 1) | Select-Object -last 6 | Select-Object -First 1)"
                                }

                            }
                        }
                    }
                }

                if ($Global:OSDCloud.HPTPMUpdate -eq $true){
                    Write-Host -ForegroundColor DarkGray "HP TPM Update: $(Get-HPTPMDetermine)"
                    Set-HPTPMBIOSSettings
                    if (Get-HPTPMDetermine -ne "False"){
                        Test-HPTPMFromOSDCloudUSB -TryToCopy
                        Invoke-HPTPMEXEDownload
                        $EnableSpecialize = $true
                    }
                    else {
                        #$Global:OSDCloud.HPTPMUpdate = $false
                    }
                }

                if ($Null -eq $Global:OSDCloud.HPIADrivers){$Global:OSDCloud.HPIADrivers = $false}
                if ($Null -eq $Global:OSDCloud.HPIAFirmware){$Global:OSDCloud.HPIAFirmware = $false}
                if ($Null -eq $Global:OSDCloud.HPIASoftware){$Global:OSDCloud.HPIASoftware = $false}
                if ($Null -eq $Global:OSDCloud.HPIAALL){$Global:OSDCloud.HPIAALL = $false}
                if ($Null -eq $Global:OSDCloud.HPTPMUpdate){$Global:OSDCloud.HPTPMUpdate = $false}
                if ($Null -eq $Global:OSDCloud.HPBIOSUpdate){$Global:OSDCloud.HPBIOSUpdate = $false}
                if ($Null -eq $HPBIOSUpdateNotes){$HPBIOSUpdateNotes = "NA"}
                if ($Null -eq $HPBIOSWinUpdate){$HPBIOSWinUpdate = $false}

                Write-Host -ForegroundColor DarkGray "Adding HP Tasks into JSON Config File for Action during Specialize and Setup Complete"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] HPIA Drivers = $($Global:OSDCloud.HPIADrivers) | HPIA Firmware = $($Global:OSDCloud.HPIAFirmware) | HPIA Software = $($Global:OSDCloud.HPIASoftware) | HPIA All = $($Global:OSDCloud.HPIAAll) "
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] HP TPM Update = $($Global:OSDCloud.HPTPMUpdate) | HP BIOS Update = $($Global:OSDCloud.HPBIOSUpdate) | HP BIOS WU Update = $HPBIOSWinUpdate"

                $HPHashTable = @{
                    'HPUpdates' = @{
                        'HPIADrivers' = $Global:OSDCloud.HPIADrivers
                        'HPIAFirmware' = $Global:OSDCloud.HPIAFirmware
                        'HPIASoftware' = $Global:OSDCloud.HPIASoftware
                        'HPIAAll' = $Global:OSDCloud.HPIAALL
                        'HPTPMUpdate' = $Global:OSDCloud.HPTPMUpdate
                        'HPBIOSUpdate' = $Global:OSDCloud.HPBIOSUpdate
                        'HPBIOSWinUpdate' = $HPBIOSWinUpdate
                        'HPBIOSUpdateNotes' = $HPBIOSUpdateNotes
                    }
                }
                if (($Global:OSDCloud.HPIAALL -eq $true) -or ($Global:OSDCloud.HPIADrivers -eq $true) -or ($Global:OSDCloud.HPIASoftware -eq $true) -or ($Global:OSDCloud.HPIAFirmware -eq $true)){
                    Write-Host -ForegroundColor DarkGray "Running HPIA during Setup Complete will add about 20 Minutes to OOBE (Just a moment...)"
                }


                $HPHashVar = $HPHashTable | ConvertTo-Json
                $ConfigPath = "c:\osdcloud\configs"
                $ConfigFile = "$ConfigPath\HP.JSON"
                try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
                catch {}
                $HPHashVar | Out-File $ConfigFile

                #Leverage SetupComplete.cmd to run HP Tools
                Set-SetupCompleteHPAppend
            }
            else { Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Failed Function Test-HPIASupport Function:This is Not a Supported HP Device, Skipping HP Enterprise Functions"}
        }
        else { Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] No Interent Found, Skipping HP Device Updates"}
    }


    #endregion
    #=================================================
    #Extra Items Config for Specialize Phase
    if (($Global:OSDCloud.PauseSpecialize -eq $true) -and ($Global:OSDCloud.DevMode -eq $true)) {

        #Set Enable Specialize to be triggered later
        $EnableSpecialize = $true

        if ($WebConnection){
            Write-Host -ForegroundColor Cyan "Adding Pause Tasks into JSON Config File for Action during Specialize"
            $HashTable = @{
                'Addons' = @{
                    'Pause' = $Global:OSDCloud.PauseSpecialize
                }
            }
            $HashVar = $HashTable | ConvertTo-Json
            $ConfigPath = "c:\osdcloud\configs"
            $ConfigFile = "$ConfigPath\Extras.JSON"
            try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
            catch {}
            $HashVar | Out-File $ConfigFile
        }
    }

    #Required for some HP & Dell Updates - Will get set to True in the Dell / HP sections if needed
    if ($EnableSpecialize -eq $true){
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Write-DarkGrayHost  "Set-OSDCloudUnattendSpecialize"
            Set-OSDCloudUnattendSpecialize
        }
    }
    if ($Null -eq $Global:OSDCloud.Bitlocker){$Global:OSDCloud.Bitlocker = $false}
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] Enable Bitlocker from Global Variable `$Global:OSDCloud.Bitlocker is set to $($Global:OSDCloud.Bitlocker)"
    if ($Global:OSDCloud.Bitlocker -eq $true){
        Set-BitlockerRegValuesXTS256
        Set-SetupCompleteBitlocker
    }
    # HERE
    #endregion

    #region AutopilotConfigurationFile.json
    if ($Global:OSDCloud.AutopilotJsonObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Applying AutopilotConfigurationFile.json"
        Write-DarkGrayHost 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        $Global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion
    Step-OSDCloudUpdateSetupDisplayedEula
    Step-OSDCloudUpdatePowerShellModules

    #region ----- OSDeploy.OOBEDeploy.json
    if ($Global:OSDCloud.OOBEDeployJsonObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Applying OSDeploy.OOBEDeploy.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.OOBEDeployJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json' -Encoding ascii -Width 2000 -Force
        #================================================
        #   WinPE PostOS
        #   Set OOBEDeploy CMD.ps1
        #================================================
$SetCommand = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest OSD Module
start "Install-Module OSD" /wait PowerShell -NoL -C Install-Module OSD -Force -SkipPublisherCheck -Verbose

:: Start-OOBEDeploy
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json
start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy

exit
'@
        $SetCommand | Out-File -FilePath "C:\Windows\OOBEDeploy.cmd" -Encoding ascii -Width 2000 -Force
    }
    #endregion

    #region ----- OSDeploy.AutopilotOOBE.json
    if ($Global:OSDCloud.AutopilotOOBEJsonObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Applying OSDeploy.AutopilotOOBE.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion

    Step-OSDCloudStageOfficeConfig
    Step-OSDCloudExportOSInformation
    if ($null -eq $HPFeaturesEnabled -or [string]::IsNullOrWhiteSpace([string]$HPFeaturesEnabled)) {
        $HPFeaturesEnabled = $false
    }
    Step-OSDCloudSaveModule -HPFeaturesEnabled ([System.Boolean]$HPFeaturesEnabled)

    #region Gary Blok Debug and Dev Mode
    if ($WebConnection -eq $True){
        if ($Global:OSDCloud.DebugMode -eq $true){
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DebugMode Enabled"
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
            osdcloud-addcmtrace
            osdcloud-addmouseoobe
            #sdcloud-UpdateModuleFilesManually
            #osdcloud-WinpeUpdateDefender
        }
    }
    #endregion

    #region Gary Blok Finish SetupComplete.cmd

    #Checks for SetupComplete.cmd file on USB Drive, if finds one, sets OSD process to run the SetupComplete
    #Flashdrive\OSDCloud\Config\Scripts\SetupComplete
    if (Get-SetupCompleteOSDCloudUSB -eq $true){
        Set-SetupCompleteOSDCloudUSB
    }
    #Makes it so that if SetupComplete finds C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd, it will run it.
    else{
        Set-SetupCompleteOSDCloudCustom
    }

    #This appends the two lines at the end of SetupComplete Script to Stop Transcription and to Restart Computer
    if ($Global:OSDCloud.SetupCompleteNoRestart -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [i] SetupCompleteNoRestart from Global Variable `$Global:OSDCloud.SetupComplete is set to $($Global:OSDCloud.SetupCompleteNoRestart)"
        Set-SetupCompleteCreateFinish -NoRestart
    }
    else {
        Set-SetupCompleteCreateFinish
    }

    #endregion

    #region ----- Config Shutdown Scripts
    <#
    David Segura
    22.11.11.1
    These scripts will be in the OSDCloud Workspace in Config\Scripts\Shutdown
    When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
    In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\*
    #>
    $Global:OSDCloud.ScriptShutdown = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.ScriptShutdown) {
        Write-SectionHeader '[i] Shutdown Scripts'
        $Global:OSDCloud.ScriptShutdown = $Global:OSDCloud.ScriptShutdown | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.ScriptShutdown) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- Automate AutopilotConfigurationFile.json
    $Global:OSDCloud.AutomateAutopilot = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "AutopilotConfigurationFile.json" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateAutopilot) {
        Write-SectionHeader '[i] Automate AutopilotConfigurationFile.json'
        $Global:OSDCloud.AutomateAutopilot = $Global:OSDCloud.AutomateAutopilot | Sort-Object -Property FullName | Select-Object -First 1
        foreach ($Item in $Global:OSDCloud.AutomateAutopilot) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($Item.FullName)"
            $null = Copy-Item -Path $Item.FullName -Destination 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Force -ErrorAction Ignore
        }
    }
    #endregion

    #region ----- Azure AutopilotConfigurationFile.json
    if ($Global:OSDCloud.AzOSDCloudAutopilotFile) {
        Write-SectionHeader '[i] Set Azure AutopilotConfigurationFile.json'
        Write-DarkGrayHost 'Autopilot Configuration File will be downloaded to C:\Windows\Provisioning\Autopilot'

        foreach ($Item in $Global:OSDCloud.AzOSDCloudAutopilotFile) {
            $ParamGetAzStorageBlobContent = @{
                CloudBlob = $Item.ICloudBlob
                Context = $Item.Context
                Destination = 'C:\Windows\Provisioning\Autopilot\'
                Force = $true
                ErrorAction = 'Stop'
            }

            try {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
            catch {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }
    }
    #endregion

    #region ----- Automate Provisioning Packages
    $Global:OSDCloud.AutomateProvisioning = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Provisioning" -Include "*.ppkg" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateProvisioning) {
        Write-SectionHeader '[i] Automate Provisioning Packages'
        $Global:OSDCloud.AutomateProvisioning = $Global:OSDCloud.AutomateProvisioning | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateProvisioning) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
            $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
            $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
        }
    }
    #endregion

    #region ----- Azure Provisioning Packages
    if ($Global:OSDCloud.AzOSDCloudPackage) {
        Write-SectionHeader '[i] Azure Provisioning Packages'
        Write-DarkGrayHost 'Provisioning Packages will be downloaded to C:\OSDCloud\Packages'

        foreach ($Item in $Global:OSDCloud.AzOSDCloudPackage) {
            $ParamGetAzStorageBlobContent = @{
                CloudBlob = $Item.ICloudBlob
                Context = $Item.Context
                Destination = 'C:\OSDCloud\Packages\'
                Force = $true
                ErrorAction = 'Stop'
            }

            try {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
            catch {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }
        $Packages = Get-ChildItem -Path 'C:\OSDCloud\Packages\' *.ppkg -Recurse -ErrorAction Ignore

        if ($Packages) {
            Write-DarkGrayHost 'Adding Provisioning Packages from C:\OSDCloud\Packages'
            foreach ($Item in $Packages) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
                $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
                $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
            }
        }
    }
    #endregion

    #region ----- Automate Shutdown Scripts
    $Global:OSDCloud.AutomateShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateShutdownScript) {
        Write-SectionHeader '[i] Automate Shutdown Scripts'
        $Global:OSDCloud.AutomateShutdownScript = $Global:OSDCloud.AutomateShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateShutdownScript) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- Automate Azure Shutdown Scripts
    if ($Global:OSDCloud.AzOSDCloudScript) {
        Write-SectionHeader '[i] Automate Azure Shutdown Scripts'
        foreach ($Item in $Global:OSDCloud.AzOSDCloudScript) {
            $ParamGetAzStorageBlobContent = @{
                CloudBlob = $Item.ICloudBlob
                Context = $Item.Context
                Destination = 'C:\OSDCloud\Scripts\'
                Force = $true
                ErrorAction = 'Stop'
            }

            try {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
            catch {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }
        $AzOSDCloudPostScript = Get-ChildItem -Path 'C:\OSDCloud\Scripts\' Invoke-WinPEShutdown*.ps1 -Recurse -ErrorAction Ignore
        foreach ($Item in $AzOSDCloudPostScript) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($Item.FullName)"
            & "Execute $($Item.FullName)"
        }
    }
    #endregion

    #region Complete
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud Finished"
    $Global:OSDCloud.TimeEnd = Get-Date
    $Global:OSDCloud.TimeSpan = New-TimeSpan -Start $Global:OSDCloud.TimeStart -End $Global:OSDCloud.TimeEnd
    $Global:OSDCloud | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\OSDCloud.json' -Encoding ascii -Width 2000 -Force
    if (Test-Path x:\windows\logs\DISM\dism.log){
        Copy-Item -Path x:\windows\logs\DISM\dism.log -Destination C:\OSDCloud\Logs\DISM-WinPE.log
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Completed in $($Global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))"

    if ($Global:OSDCloud.Restart) {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] WinPE is restarting in 30 seconds"
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Restart-Computer
        }
    }

    if ($Global:OSDCloud.Shutdown) {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] WinPE will shutdown in 30 seconds"
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Stop-Computer
        }
    }

    if ($OSDCloud.Test -eq $true) {
        Stop-Transcript
    }
    #endregion
}
