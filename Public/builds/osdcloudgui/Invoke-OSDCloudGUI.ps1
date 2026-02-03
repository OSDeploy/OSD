function Invoke-OSDCloudGUI {
    <#
    .SYNOPSIS
    This is the master OSDCloud Task Sequence
    
    .DESCRIPTION
    This is the master OSDCloud Task Sequence
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    
    #region [Initialization]
    function Write-DarkGrayDate {
        [CmdletBinding()]
        param (
            [Parameter(Position = 0)]
            [System.String]
            $Message
        )
        if ($Message) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] $Message"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] " -NoNewline
        }
    }
    function Write-DarkGrayHost {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [System.String]
            $Message
        )
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] $Message"
    }
    function Write-DarkGrayLine {
        [CmdletBinding()]
        param ()
        Write-Host -ForegroundColor DarkGray '========================================================================='
    }
    function Write-SectionHeader {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [System.String]
            $Message
        )
        Write-DarkGrayLine
        Write-DarkGrayDate
        Write-Host -ForegroundColor Cyan $Message
    }
    #endregion

    #region [Variables] OSDCloud Master Settings
    Write-DarkGrayHost "Initializing `$Global:OSDCloud"
    $global:OSDCloud = $null
    $global:OSDCloud = [ordered]@{
        LaunchMethod = $null
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
        IsOnBattery = $(Get-OSDGather -Property IsOnBattery)
        IsTest = ($env:SystemDrive -ne 'X:')
        IsVirtualMachine = $(Test-IsVM)
        IsWinPE = ($env:SystemDrive -eq 'X:')
        IsoMountDiskImage = $null
        IsoGetDiskImage = $null
        IsoGetVolume = $null
        Logs = "$env:TEMP\osdcloud-logs"
        Manufacturer = Get-MyComputerManufacturer -Brief
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
        OperatingSystems = [array](Get-OSDCloudOperatingSystems)
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
        Product = Get-MyComputerProduct
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
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        WindowsDefenderUpdate  = $null
        WindowsUpdate  = $null
        WindowsUpdateDrivers  = $null
        WindowsImage = $null
        WindowsImageCount = $null
        ZTI = [bool]$false
    }
    #endregion

    #region [Variables] Set Initialization Defaults
    <#  If this is a Virtual Machine and Skip Recovery Partition 
        OVERRIDE:
        $Global:MyOSDCloud.RecoveryPartition = $true
    #>
    if ($global:OSDCloud.IsVirtualMachine) {
        $global:OSDCloud.SkipRecoveryPartition = $true
    }
    #endregion

    #region [Variables] Merge Variables
    <#  Overwrite the OSDCloud Master Settings by using custom variables
        MyOSDCloud is the last and final customization variable
    #>
    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost 'Applying $Global:InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost 'Not Used $Global:InvokeOSDCloud'
    }

    if ($Global:StartOSDCloud) {
        Write-DarkGrayHost 'Applying $Global:StartOSDCloud'
        foreach ($Key in $Global:StartOSDCloud.Keys) {
            $global:OSDCloud.$Key = $Global:StartOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost 'Not Used $Global:StartOSDCloud'
    }

    if ($Global:StartOSDCloudCLI) {
        Write-DarkGrayHost 'Applying $Global:StartOSDCloudCLI'
        foreach ($Key in $Global:StartOSDCloudCLI.Keys) {
            $global:OSDCloud.$Key = $Global:StartOSDCloudCLI.$Key
        }
    }
    else {
        Write-DarkGrayHost 'Not Used $Global:StartOSDCloudCLI'
    }

    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost 'Reapplying $Global:InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost 'Not Used $Global:InvokeOSDCloud'
    }

    if ($Global:MyOSDCloud) {
        Write-DarkGrayHost 'Applying $Global:MyOSDCloud'
        foreach ($Key in $Global:MyOSDCloud.Keys) {
            $global:OSDCloud.$Key = $Global:MyOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost 'Not Used $Global:MyOSDCloud'
    }
    #endregion

    #region [Variables] Set Post-Merge Defaults
    $global:OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($global:OSDCloud.RecoveryPartition -eq $true) {
        $global:OSDCloud.SkipRecoveryPartition = [bool]$false
    }

    if ($global:OSDCloud.restartComputer -eq $true) {
        $global:OSDCloud.Restart = [bool]$true
    }

    if ($global:OSDCloud.SkipAllDiskSteps -eq $true) {
        Write-DarkGrayHost '$OSDCloud.SkipAllDiskSteps = $true'
        $global:OSDCloud.SkipClearDisk = $true
        $global:OSDCloud.SkipNewOSDisk = $true
    }

    if ($global:OSDCloud.IsWinPE -eq $false) {
        Write-DarkGrayHost '$OSDCloud.IsWinPE = $false'
        $global:OSDCloud.SkipClearDisk = $true
        $global:OSDCloud.SkipNewOSDisk = $true
    }

    if ($global:OSDCloud.ZTI -eq $true) {
        Write-DarkGrayHost '$OSDCloud.ZTI = $true'
        $global:OSDCloud.ClearDiskConfirm = $false
    }
    #endregion

    #region [Logs] Start-Transcript
    $LogsPath = $global:OSDCloud.Logs
    $Params = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        ItemType    = 'Directory'
        Path        = $LogsPath
    }
    if (-not (Test-Path $Params.Path)) {
        New-Item @Params | Out-Null
    }
    $global:OSDCloud.Transcript = Join-Path $LogsPath "osdcloud-transcript.log"
    
    # Make sure we are not currently transcribing
    try {
        Stop-Transcript
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    
    # Start transcribing
    try {
        Start-Transcript -Path $global:OSDCloud.Transcript -ErrorAction Stop
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    $global:OSDCloud | Out-File "$LogsPath\osdcloud-global-variables.log"
    #endregion

    #region [GaryBlok] SplashScreen
    if ($global:OSDCloud.SplashScreen -eq $true) {
        Write-SectionHeader "Setup SplashScreen"
        $RegPath = "HKLM:\SOFTWARE\OSDCloud"
        if (!(Test-Path -Path $RegPath)){New-Item -Path $RegPath -Force}
        New-ItemProperty -Path $RegPath -Name "OSVersion" -Value $global:OSDCloud.OSVersion
        New-ItemProperty -Path $RegPath -Name "OSReleaseID" -Value $global:OSDCloud.OSReleaseID
        New-ItemProperty -Path $RegPath -Name "OSEdition" -Value $global:OSDCloud.OSEdition
        New-ItemProperty -Path $RegPath -Name "OSLicense" -Value $global:OSDCloud.OSActivation
        New-ItemProperty -Path $RegPath -Name "OSActivation" -Value $global:OSDCloud.OSActivation
    }
    #endregion
        
    #region [GaryBlok] SetWiFi
    if ($global:OSDCloud.SetWiFi -eq $true){
        Write-SectionHeader "Gathering WiFi Information"
        Write-Host -ForegroundColor Yellow "Please Supply the SSID & Press Enter - CASE SENSITIVE"
        if (!($SSID)){$SSID = Read-Host}
        Write-Host -ForegroundColor Yellow "Please Supply the Password & Press Enter - CASE SENSITIVE"
        if (!($PSK)){$PSK = Read-Host -AsSecureString}
    }
    #endregion
        
    #region [GaryBlok] MS365Install
    if ($global:OSDCloud.MS365Install -eq $true){
        Write-SectionHeader "Gathering M365 Information"
        Write-Host -ForegroundColor Magenta "Please Supply the CompanyName & Press Enter - CASE SENSITIVE"
        if (!($M365CompanyName)){$M365CompanyName = Read-Host}
        if ($M365CompanyName -eq ""){$M365CompanyName = "Organization"}
    }
    #endregion

    #region [Automate] ..\OSDCloud\Config\Scripts\Startup\*.ps1
    <#
    These scripts will be in the OSDCloud Workspace in Config\Scripts\Startup
    When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
    In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\Startup\*
    #>
    # Write-SectionHeader '[i] Config Startup Scripts'
    $global:OSDCloud.ScriptStartup = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Config\Scripts\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Startup\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.ScriptStartup) {
        $global:OSDCloud.ScriptStartup = $global:OSDCloud.ScriptStartup | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.ScriptStartup) {
            Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] ..\OSDCloud\Config\Scripts\Shutdown\*.ps1
    # Write-SectionHeader '[i] Config Shutdown Scripts'
    $global:OSDCloud.ShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Config\Scripts\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Shutdown\" -Include '*.ps1' -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.ShutdownScript) {
        $global:OSDCloud.ShutdownScript = $global:OSDCloud.ShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.ShutdownScript) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] ..\OSDCloud\Automate\AutopilotConfigurationFile.json
    # Write-SectionHeader '[i] Automate AutopilotConfigurationFile.json'
    $global:OSDCloud.AutomateAutopilot = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\AutopilotConfigurationFile.json"
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "AutopilotConfigurationFile.json" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateAutopilot) {
        $global:OSDCloud.AutomateAutopilot = $global:OSDCloud.AutomateAutopilot | Sort-Object -Property FullName | Select-Object -First 1
        foreach ($Item in $global:OSDCloud.AutomateAutopilot) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] ..\OSDCloud\Automate\Provisioning\*.ppkg
    # Write-SectionHeader '[i] Automate Provisioning Package'
    $global:OSDCloud.AutomateProvisioning = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Provisioning\*.ppkg"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Provisioning" -Include "*.ppkg" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateProvisioning) {
        $global:OSDCloud.AutomateProvisioning = $global:OSDCloud.AutomateProvisioning | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.AutomateProvisioning) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] ..\OSDCloud\Automate\Startup\*.ps1
    # Write-SectionHeader '[i] Automate Startup Scripts'
    $global:OSDCloud.AutomateStartupScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Startup" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateStartupScript) {
        $global:OSDCloud.AutomateStartupScript = $global:OSDCloud.AutomateStartupScript | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.AutomateStartupScript) {
            Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] ..\OSDCloud\Automate\Shutdown\*.ps1
    # Write-SectionHeader '[i] Automate Shutdown Scripts'
    $global:OSDCloud.AutomateShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateShutdownScript) {
        $global:OSDCloud.AutomateShutdownScript = $global:OSDCloud.AutomateShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.AutomateShutdownScript) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region [Validation] LaunchMethod
    if ($global:OSDCloud.LaunchMethod) {
        $null = Install-Module -Name $global:OSDCloud.LaunchMethod -Force -ErrorAction Ignore -WarningAction Ignore
    }
    #endregion

    #region [Validation] Operating System Source
    # Write-SectionHeader "Validate Operating System Source"

    $global:OSDCloud.SectionPassed = $false
    if ($global:OSDCloud.AzOSDCloudImage) {
        $global:OSDCloud.SectionPassed = $true
    }
    if ($global:OSDCloud.ImageFileItem) {
        $global:OSDCloud.SectionPassed = $true
    }
    if ($global:OSDCloud.ImageFileDestination) {
        $global:OSDCloud.SectionPassed = $true
    }
    if ($global:OSDCloud.ImageFileUrl) {
        $global:OSDCloud.SectionPassed = $true
    }
    if ($global:OSDCloud.SectionPassed -eq $false) {
        Write-Warning "OSDCloud Failed"
        Write-Warning "An Operating System Source was not specified by any required Variables"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Try using Start-OSDCloud, Start-OSDCloudGUI, or Start-OSDCloudAzure"
        Write-Warning "Press Ctrl+C to exit"
        Start-Sleep -Seconds 86400
        Exit
    }
    #endregion
        
    #region [Configuration] Autopilot Profiles
    if ($global:OSDCloud.SkipAutopilot -ne $true) {
        Write-SectionHeader "Validate Autopilot Configuration"

        if ($global:OSDCloud.AutopilotJsonObject) {
            Write-DarkGrayHost 'Importing AutopilotJsonObject'
        }
        elseif ($global:OSDCloud.AutopilotJsonUrl) {
            Write-DarkGrayHost "Importing Autopilot Configuration $($global:OSDCloud.AutopilotJsonUrl)"
            if (Test-WebConnection -Uri $global:OSDCloud.AutopilotJsonUrl) {
                $global:OSDCloud.AutopilotJsonObject = (Invoke-WebRequest -Uri $global:OSDCloud.AutopilotJsonUrl).Content | ConvertFrom-Json
            }
        }
        elseif ($global:OSDCloud.AutopilotJsonItem) {
            $global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name $global:OSDCloud.AutopilotJsonItem.Name -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name $global:OSDCloud.AutopilotJsonItem.Name -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonItem = $global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
            if ($global:OSDCloud.AutopilotJsonItem) {
                $global:OSDCloud.AutopilotJsonObject = Get-Content $global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
            }
        }
        elseif ($global:OSDCloud.AutopilotJsonName) {
            $global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name $global:OSDCloud.AutopilotJsonName -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name $global:OSDCloud.AutopilotJsonName -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonItem = $global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
            if ($global:OSDCloud.AutopilotJsonItem) {
                $global:OSDCloud.AutopilotJsonObject = Get-Content $global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
            }
        }
        else {
            $global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
            $global:OSDCloud.AutopilotJsonChildItem = $global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"}

            if ($global:OSDCloud.AutopilotJsonChildItem) {
                if ($global:OSDCloud.ZTI -eq $true) {
                    $global:OSDCloud.AutopilotJsonItem = $global:OSDCloud.AutopilotJsonChildItem | Select-Object -First 1
                }
                else {
                    $global:OSDCloud.AutopilotJsonItem = Select-OSDCloudAutopilotJsonItem
                }

                if ($global:OSDCloud.AutopilotJsonItem) {
                    $global:OSDCloud.AutopilotJsonObject = Get-Content $global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
                }
            }
        }

        if ($global:OSDCloud.AutopilotJsonObject) {
            Write-DarkGrayHost "OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
            $($global:OSDCloud.AutopilotJsonObject) | Out-Host | Format-List
        }
        else {
            Write-Warning "AutopilotConfigurationFile.json will not be configured for this deployment"
        }
    }
    #endregion
        
    #region [Configuration] ODTFile
    if ($global:OSDCloud.SkipODT -ne $true) {
        $global:OSDCloud.ODTFiles = Find-OSDCloudODTFile
        
        if ($global:OSDCloud.ODTFiles) {
            Write-SectionHeader "Select Office Deployment Tool Configuration"
        
            $global:OSDCloud.ODTFile = Select-OSDCloudODTFile
            if ($global:OSDCloud.ODTFile) {
                Write-DarkGrayHost "Office Config: $($global:OSDCloud.ODTFile.FullName)"
            } 
            else {
                Write-Warning "OSDCloud Office Config will not be configured for this deployment"
            }
        }
    }
    #endregion
        
    #region [Configuration] Test Mode
    if ($global:OSDCloud.IsWinPE -eq $false) {
        Write-Warning "OSDCloud can only be run from WinPE"
        Write-Warning "OSDCloud is running in Test mode"
        Start-Sleep -Seconds 5
    }
    #endregion

    #region [Disk] Validate
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-validate-isdiskready]"
    $global:OSDCloud.SectionPassed = $false
    $global:OSDCloud.GetDiskFixed = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

    if ($global:OSDCloud.GetDiskFixed) {
        Write-DarkGrayHost "Fixed Disk is valid. OK."
    }
    else {
        Write-Warning "[$(Get-Date -format G)] Unable to detect a Fixed Disk."
        Write-Warning "[$(Get-Date -format G)] WinPE may need additional Disk, SCSI or Raid Drivers."
        Write-Warning 'Press Ctrl+C to cancel OSDCloud'
        Start-Sleep -Seconds 86400
        exit
    }
    #endregion

    #region [Disk] Remove USB DriveLetters
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-preinstall-removeusbdriveletter]"
    <#
        https://docs.microsoft.com/en-us/powershell/module/storage/remove-partitionaccesspath
        Partition Access Paths are being removed from USB Drive Letters
        This prevents issues when Drive Letters are reassigned
    #>
    # Store the USB Partitions
    $global:OSDCloud.USBPartitions = Get-USBPartition
    # Remove USB Drive Letters
    if ($global:OSDCloud.USBPartitions) {
        Write-DarkGrayHost "Removing USB Drive Letters. OK."

        if ($global:OSDCloud.IsWinPE -eq $true) {
            foreach ($Item in $global:OSDCloud.USBPartitions) {
                $Params = @{
                    AccessPath = "$($Item.DriveLetter):"
                    DiskNumber = $Item.DiskNumber
                    PartitionNumber = $Item.PartitionNumber
                    ErrorAction     = 'SilentlyContinue'
                }
                Remove-PartitionAccessPath @Params
                Start-Sleep -Seconds 3
            }
        }
    }
    #endregion
        
    #region [Disk] Clear-Disk
    
    # Log Pre New-OSDisk Partitions
    $DiskPartitions = (Get-CimInstance -ClassName Win32_DiskPartition -ErrorAction SilentlyContinue | Select-Object -Property *)
    $DiskPartitions | Out-File "$LogsPath\osdcloud-win32-diskpartition-pre.txt" -Encoding ascii

    if ($global:OSDCloud.SkipClearDisk -eq $true) {
        Write-DarkGrayHost '$OSDCloud.SkipClearDisk = $true'
    }

    if ($global:OSDCloud.SkipClearDisk -eq $false) {
        Write-DarkGrayHost '$OSDCloud.SkipClearDisk = $false'

        if (($global:OSDCloud.GetDiskFixed | Measure-Object).Count -ge 2) {
            Write-Warning "[$(Get-Date -format G)] OSDCloud has detected more than 1 Fixed Disk is installed. Clear-Disk with Confirm is required"
            $global:OSDCloud.ClearDiskConfirm = $true
        }

        if ($global:OSDCloud.ClearDiskConfirm -eq $true) {
            Write-DarkGrayHost '$OSDCloud.ClearDiskConfirm = $true'
            Clear-LocalDisk -Force -NoResults -ErrorAction Stop
        }
        else {
            Write-DarkGrayHost '$OSDCloud.ClearDiskConfirm = $false'
            Clear-LocalDisk -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    #endregion
    
    #region [Disk] New-OSDisk
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-preinstall-partitiondisk]"
    <#
    https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/configure-uefigpt-based-hard-drive-partitions
    New Partitions will be created using Microsoft Standard Layout
    #>
    if ($global:OSDCloud.SkipNewOSDisk -eq $true) {
        Write-DarkGrayHost '$OSDCloud.SkipNewOSDisk = $true'
    }

    if ($global:OSDCloud.SkipNewOSDisk -eq $false) {
        # Uses DiskPart instead of PS to create partitions, I think I'm going to depricate this soon.
        if ($global:OSDCloud.DiskPart -eq $true) {
            Start-OSDDiskPart
            Write-Host "=========================================================================" -ForegroundColor Cyan
            Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
            Write-Host "=========================================================================" -ForegroundColor Cyan
            $LocalVolumes = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}
            Write-Output $LocalVolumes
        }
        else {
            if ($global:OSDCloud.SkipRecoveryPartition -eq $true) {
                Write-DarkGrayHost "Recovery Partition will not be created. OK."
                New-OSDisk -PartitionStyle GPT -NoRecoveryPartition -Force -ErrorAction Stop
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
            }
            else {
                Write-DarkGrayHost "Recovery Partition will be created. OK."
                if ($Null -ne $global:OSDCloud.OSInstallDiskNumber){
                    New-OSDisk -PartitionStyle GPT -DiskNumber $global:OSDCloud.OSInstallDiskNumber -Force -ErrorAction Stop
                }
                else {
                    New-OSDisk -PartitionStyle GPT -Force -ErrorAction Stop
                }
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Start-Sleep -Seconds 5
            }
        }

        # Log Pre New-OSDisk Partitions
        $DiskPartitions = (Get-CimInstance -ClassName Win32_DiskPartition -ErrorAction SilentlyContinue | Select-Object -Property *)
        $DiskPartitions | Out-File "$LogsPath\osdcloud-win32-diskpartition-post.txt" -Encoding ascii

        #Make sure that there is a PSDrive 
        if (-NOT (Get-PSDrive -Name 'C')) {
            Write-Warning "[$(Get-Date -format G)] Failed to create a PSDrive FileSystem at C:\."
            Write-DarkGrayHost "Press Ctrl+C to exit OSDCloud"
            Start-Sleep -Seconds 86400
            exit
        }
    }
    #endregion

    #region [Disk] Restore USB DriveLetters
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-preinstall-restoreusbdriveletter]"
    if ($global:OSDCloud.USBPartitions) {
        Write-DarkGrayHost "Restoring USB Drive Letters. OK."
        if ($global:OSDCloud.IsWinPE -eq $true) {
            foreach ($Item in $global:OSDCloud.USBPartitions) {
                $Params = @{
                    AssignDriveLetter = $true
                    DiskNumber = $Item.DiskNumber
                    PartitionNumber = $Item.PartitionNumber
                    ErrorAction = 'SilentlyContinue'
                }
                Add-PartitionAccessPath @Params
                Start-Sleep -Seconds 5
            }
        }
    }
    #endregion
        
    #region [Preinstall] DebugMode
    $global:OSDCloud | Out-File "$LogsPath\osdcloud-global-variables.txt"
    Get-CimInstance -Namespace root/CIMV2/Security/MicrosoftTpm -ClassName Win32_Tpm | Out-File "$LogsPath\debug-win32-tpm.txt"
    Get-ComputerInfo | Out-File "$LogsPath\Get-ComputerInfo.log"
    Get-Win11Readiness | Out-File "$LogsPath\Get-Win11Readiness.txt"
    #endregion

    #region [Power] High Performance
    if ($global:OSDCloud.IsOnBattery -eq $true) {
        $Win32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)
        if ($Win32Battery.BatteryStatus -eq 1) {
            Write-DarkGrayHost "[Power] Device has $($Win32Battery.EstimatedChargeRemaining)% battery remaining"
        }
        Write-DarkGrayHost "[Power] High Performance will not be enabled while on battery"
    }
    elseif ($global:OSDCloud.IsWinPE -eq $false) {
        Write-DarkGrayHost '[Power] Device is not running in WinPE. Performance will not be adjusted'
    }
    elseif ($global:OSDCloud.Debug -eq $true) {
        Write-DarkGrayHost '[Power] Device is running in debug mode. Performance will not be adjusted'
    }
    else {
        powercfg.exe -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    #endregion

    #region [WindowsImage] Copy-Item Offline WindowsImage
    if ($global:OSDCloud.ImageFileItem) {
        Write-DarkGrayHost '[Offline] Copy offline WindowsImage'
        #It's possible that Drive Letters may have changed if a USB is used
        #Check to see if the image file exists already after the USB Drive has been reinitialized
        if (Test-Path $global:OSDCloud.ImageFileItem.FullName) {
            $global:OSDCloud.ImageFileSource = Get-Item -Path $global:OSDCloud.ImageFileItem.FullName
        }
        #Set the ImageFile Name if it does not exist
        if (!($global:OSDCloud.ImageFileName)) {
            $global:OSDCloud.ImageFileName = Split-Path -Path $global:OSDCloud.ImageFileItem.FullName -Leaf
        }
        #If the Source did not exist after the USB, have to do a best guess
        if (!($global:OSDCloud.ImageFileSource)) {
            $global:OSDCloud.ImageFileSource = Find-OSDCloudFile -Name $global:OSDCloud.ImageFileName -Path (Split-Path -Path (Split-Path -Path $global:OSDCloud.ImageFileItem.FullName -Parent) -NoQualifier) | Where-Object {$_.FullName -notlike "C:*"} | Select-Object -First 1
        }
        #Now that we have an ImageFileSource, everything is good
        if ($global:OSDCloud.ImageFileSource) {
            Write-DarkGrayHost "[Offline] Source: $($global:OSDCloud.ImageFileSource.FullName)"
            if (!(Test-Path 'C:\OSDCloud\OS')) {
                New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            if ($global:OSDCloud.ImageFileSource.FullName -match ".swm") {
                Copy-Item -Path "$($global:OSDCloud.ImageFileSource.Directory.FullName)\*.swm" -Destination 'C:\OSDCloud\OS' -Force -Verbose
            }
            else {
                Copy-Item -Path $global:OSDCloud.ImageFileSource.FullName -Destination 'C:\OSDCloud\OS' -Force
            }
            
            if (Test-Path "C:\OSDCloud\OS\$($global:OSDCloud.ImageFileSource.Name)") {
                $global:OSDCloud.ImageFileDestination = Get-Item -Path "C:\OSDCloud\OS\$($global:OSDCloud.ImageFileSource.Name)"
            }
        }
        if ($global:OSDCloud.ImageFileDestination) {
            Write-DarkGrayHost "[Offline] Destination: $($global:OSDCloud.ImageFileDestination.FullName)"
            $global:OSDCloud.ImageFileUrl = $null
        }
        else {
            Write-Warning "[$(Get-Date -format G)] OSDCloud Failed"
            Write-Warning "Could not copy the Windows Image to C:\OSDCloud\OS"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
    }
    #endregion
        
    #region [WindowsImage] Get-OSDCloudOperatingSystems
    if ($global:OSDCloud.AzOSDCloudImage) {
        #AzOSDCloud
    }
    elseif (!($global:OSDCloud.ImageFileDestination) -and (!($global:OSDCloud.ImageFileUrl))) {
        Write-SectionHeader "Get-OSDCloudOperatingSystems"
        Write-Warning "Invoke-OSDCloud was not set properly with an OS to Download"
        Write-Warning "You should be using Start-OSDCloud or Start-OSDCloudGUI"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Windows 10 Enterprise is being downloaded and installed out of convenience only"

        if (!($global:OSDCloud.GetFeatureUpdate)) {
            $global:OSDCloud.GetFeatureUpdate = Get-FeatureUpdate
        }
        if ($global:OSDCloud.GetFeatureUpdate) {
            $global:OSDCloud.GetFeatureUpdate = $global:OSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
            $global:OSDCloud.ImageFileName = $global:OSDCloud.GetFeatureUpdate.FileName
            $global:OSDCloud.ImageFileUrl = $global:OSDCloud.GetFeatureUpdate.FileUri
        }
        else {
            Write-Warning "[$(Get-Date -format G)] OSDCloud Failed"
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
    }
    #endregion

    #region [WindowsImage] Download from Azure Storage
    if ($global:OSDCloud.AzOSDCloudImage) {
        Write-SectionHeader "OSDCloud Azure Storage Windows Image Download"

        $global:OSDCloud.DownloadDirectory = "C:\OSDCloud\Azure\$($global:OSDCloud.AzOSDCloudImage.BlobClient.AccountName)\$($global:OSDCloud.AzOSDCloudImage.BlobClient.BlobContainerName)"
        $global:OSDCloud.DownloadName = $(Split-Path $global:OSDCloud.AzOSDCloudImage.Name -Leaf)
        $global:OSDCloud.DownloadFullName = "$($global:OSDCloud.DownloadDirectory)\$($global:OSDCloud.DownloadName)"

        #Export Image Information
        $global:OSDCloud.AzOSDCloudImage | ConvertTo-Json | Out-File -FilePath "$LogsPath\AzOSDCloudImage.json" -Encoding ascii -Width 2000

        $ParamGetAzStorageBlobContent = @{
            CloudBlob = $global:OSDCloud.AzOSDCloudImage.ICloudBlob
            Context = $global:OSDCloud.AzOSDCloudImage.Context
            Destination = $global:OSDCloud.DownloadFullName
            Force = $true
            ErrorAction = 'Stop'
        }

        $ParamGetItem = @{
            Path = $global:OSDCloud.DownloadFullName
            ErrorAction = 'Stop'
        }

        $ParamNewItem = @{
            Path = $global:OSDCloud.DownloadDirectory
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }

        if (Test-Path $global:OSDCloud.DownloadFullName) {
            Write-DarkGrayHost -Message "$($global:OSDCloud.DownloadFullName) already exists"

            $global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1

            if ($global:OSDCloud.AzOSDCloudImage.Length -eq $global:OSDCloud.ImageFileDestination.Length) {
                Write-DarkGrayHost -Message "Destination file size matches Azure Storage, skipping previous download"
            }
            else {
                Write-DarkGrayHost -Message "Existing file does not match Azure Storage, downloading updated file"

                try {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
                catch {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
            }
        }
        else {
            if (-not (Test-Path "$($global:OSDCloud.DownloadDirectory)")) {
                Write-DarkGrayHost -Message "Creating directory $($global:OSDCloud.DownloadDirectory)"
                $null = New-Item @ParamNewItem
            }

            try {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
            catch {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }
        
        $global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1
    }
    #endregion

    #region [WindowsImage] Download Operating System
    if (!($global:OSDCloud.ImageFileDestination) -and ($global:OSDCloud.ImageFileUrl)) {
        #Write-SectionHeader "Download Operating System"
        Write-DarkGrayHost "Downloading Operating System from URL"
        Write-DarkGrayHost "$($global:OSDCloud.ImageFileUrl)"

        $null = New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Ignore
        if (Test-WebConnection -Uri $global:OSDCloud.ImageFileUrl) {
            if ($global:OSDCloud.ImageFileName) {
                #=================================================
                #	Cache to USB
                #=================================================
                $OSDCloudUSB = Get-USBVolume | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {($_.FileSystemLabel -match "OSDCloud|BHIMAGE|USB-DATA")} | Where-Object {$_.SizeGB -ge 30} | Where-Object {$_.SizeRemainingGB -ge 6} | Select-Object -First 1
                
                if ($OSDCloudUSB -and $global:OSDCloud.OSVersion -and $global:OSDCloud.OSReleaseID) {
                    $OSDownloadChildPath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\OS\$($global:OSDCloud.OSVersion) $($global:OSDCloud.OSReleaseID)"
                    Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Downloading OSDCloud Offline OS $OSDownloadChildPath"

                    $OSDCloudUsbOS = Save-WebFile -SourceUrl $global:OSDCloud.ImageFileUrl -DestinationDirectory "$OSDownloadChildPath" -DestinationName $global:OSDCloud.ImageFileName

                    if ($OSDCloudUsbOS) {
                        Write-SectionHeader "Copying Offline OS to C:\OSDCloud\OS\$($OSDCloudUsbOS.Name)"
                        $null = Copy-Item -Path $OSDCloudUsbOS.FullName -Destination "C:\OSDCloud\OS" -Force

                        $global:OSDCloud.ImageFileDestination = Get-Item "C:\OSDCloud\OS\$($OSDCloudUsbOS.Name)"
                    }
                }
                else {
                    $global:OSDCloud.ImageFileDestination = Save-WebFile -SourceUrl $global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -DestinationName $global:OSDCloud.ImageFileName -ErrorAction Stop
                }
            }
            else {
                $global:OSDCloud.ImageFileDestination = Save-WebFile -SourceUrl $global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -ErrorAction Stop
            }
            if (!(Test-Path $global:OSDCloud.ImageFileDestination.FullName)) {
                $global:OSDCloud.ImageFileDestination = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd,*.iso | Select-Object -First 1
            }
        }
        else {
            Write-Warning "[$(Get-Date -format G)] OSDCloud Failed"
            Write-Warning "Could not verify an Internet connection for the Windows ImageFile"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }

        if ($global:OSDCloud.ImageFileDestination) {
            Write-Verbose -Message "ImageFileDestination: $($global:OSDCloud.ImageFileDestination.FullName)"
        }
    }
    #endregion

    #region [WindowsImage] Verify SHA1
    if ($Global:OSDCloud.CheckSHA1 -eq $true) {
        if (($global:OSDCloud.ImageFileDestination) -and ($global:OSDCloud.ImageFileDestination.FullName)) {
            $global:OSDCloud.ImageFileDestinationSHA1 = (Get-FileHash -Path $global:OSDCloud.ImageFileDestination.FullName -Algorithm SHA1).Hash
            $global:OSDCloud.ImageFileSHA1 = (Get-OSDCloudOperatingSystems | Where-Object {$_.FileName -eq $global:OSDCloud.ImageFileName}).SHA1
            if ($null -eq $Global:OSDCloud.ImageFileSHA1) {
                Write-Warning "[$(Get-Date -format G)] OSDCloud Warning"
                Write-Warning "No SHA1 Hash exists for $($Global:OSDCloud.ImageFileName) in the OSDCloud Catalog"
                Write-Warning "Skipping SHA1 Validation"
            }
            else {
                Write-DarkGrayHost "Microsoft Verified ESD SHA1: $($global:OSDCloud.ImageFileSHA1)"
                Write-DarkGrayHost "Downloaded ESD SHA1: $($global:OSDCloud.ImageFileDestinationSHA1)"
                if ($global:OSDCloud.ImageFileDestinationSHA1 -ne $global:OSDCloud.ImageFileSHA1) {
                    Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
                    Write-Warning "[$(Get-Date -format G)] WindowsImage SHA1 does not match the verified Microsoft ESD SHA1."
                    Write-Warning 'Press Ctrl+C to cancel OSDCloud'
                    Start-Sleep -Seconds 86400
                }
                else {
                    Write-Host -ForegroundColor Green "[$(Get-Date -format G)] WindowsImage SHA1 matches the verified Microsoft ESD SHA1. OK."
                }
            }
        }
    }
    #endregion

    #region [FAILURE] Unable to find a usable WindowsImage
    if (-not ($global:OSDCloud.ImageFileDestination)) {
        Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
        Write-Warning "[$(Get-Date -format G)] Unable to find a usable WindowsImage"
        Write-Warning 'Press Ctrl+C to cancel OSDCloud'
        Start-Sleep -Seconds 86400
    }
    #endregion
        
    #region [WindowsImage] Windows ISO
    if ($global:OSDCloud.ImageFileDestination.Extension -eq '.iso') {
        Write-DarkGrayHost "OSDCloud Deploy from Windows ISO"
        $global:OSDCloud.IsoGetDiskImage = Get-DiskImage -ImagePath $global:OSDCloud.ImageFileDestination.FullName

        # ISO is already mounted (which should not be happening)
        if ($global:OSDCloud.IsoGetDiskImage.Attached) {
            $global:OSDCloud.IsoGetVolume = $global:OSDCloud.IsoGetDiskImage | Get-Volume
            Write-DarkGrayHost "Windows ISO is attached to Drive Letter $($global:OSDCloud.IsoGetVolume.DriveLetter)"
        }
        else {
            Write-DarkGrayHost "Mounting Windows ISO $($global:OSDCloud.ImageFileDestination.FullName)"
            $global:OSDCloud.IsoMountDiskImage = Mount-DiskImage -ImagePath $global:OSDCloud.ImageFileDestination.FullName -PassThru -ErrorAction Stop

            if ($global:OSDCloud.IsoMountDiskImage.Attached) {
                Start-Sleep -Seconds 10
                $global:OSDCloud.IsoGetVolume = $global:OSDCloud.IsoMountDiskImage | Get-Volume

                Write-DarkGrayHost "Windows ISO is attached to Drive Letter $($global:OSDCloud.IsoGetVolume.DriveLetter)"
            }
            else {
                Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
                Write-Warning "Windows ISO did not mount properly"
                Write-Warning 'Press Ctrl+C to cancel OSDCloud'
                Start-Sleep -Seconds 86400
            }
        }
        $global:OSDCloud.ImageFileDestination = Get-ChildItem -Path "$($global:OSDCloud.IsoGetVolume.DriveLetter):\*" -Include *.wim,*.esd -Recurse | Sort-Object Length -Descending | Select-Object -First 1
        if (-not ($global:OSDCloud.ImageFileDestination)) {
            Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
            Write-Warning "Unable to find a WIM or ESD file on the Mounted Windows ISO"
            Write-Warning 'Press Ctrl+C to cancel OSDCloud'
            Start-Sleep -Seconds 86400
        }
    }
    #endregion
        
    #region [WindowsImage] Validate WindowsImage
    # Does the image exist?
    $ImagePath = $global:OSDCloud.ImageFileDestination.FullName
    if (-not (Test-Path $ImagePath)) {
        Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
        Write-Warning "WindowsImage does not exist at the ImagePath"
        Write-Warning $ImagePath
        Write-Warning 'Press Ctrl+C to cancel OSDCloud'
        Start-Sleep -Seconds 86400
    }

    # Does Get-WindowsImage work?
    try {
        $global:OSDCloud.WindowsImage = Get-WindowsImage -ImagePath $ImagePath -ErrorAction Stop
    }
    catch {
        Write-Warning "[$(Get-Date -format G)] OSDCloud FAILURE"
        Write-Warning "Unable to verify the Windows Image using Get-WindowsImage"
        Write-Warning $_
        Write-Warning "WindowsImage may not have downloaded completely"
        Write-Warning "WindowsImage may be corrupt"
        Write-Warning 'Press Ctrl+C to cancel OSDCloud'
        Start-Sleep -Seconds 86400
    }
    $global:OSDCloud.WindowsImageCount = ($global:OSDCloud.WindowsImage).Count

    # Does the WindowsImage contain an Image
    if ($null -eq $global:OSDCloud.WindowsImageCount) {
        Write-Warning "[$(Get-Date -format G)] Get-WindowsImage could not find an Image in $ImagePath"
        Write-Warning "[$(Get-Date -format G)] $_"
        Write-Warning 'Press Ctrl+C to exit OSDCloud'
        Start-Sleep -Seconds 86400
        exit
    }

    # Is there only one ImageIndex?
    if ($global:OSDCloud.WindowsImageCount -eq 1) {
        $global:OSDCloud.OSImageIndex = 1
    }
    #endregion

    #region [WindowsImage] Index EditionId Matching
    # Align the OSEdition with the OSEditionId
    if ($global:OSDCloud.OSEdition -eq 'Home') {
        $global:OSDCloud.OSEditionId = 'Core'
    }
    if ($global:OSDCloud.OSEdition -eq 'Home N') {
        $global:OSDCloud.OSEditionId = 'CoreN'
    }
    if ($global:OSDCloud.OSEdition -eq 'Home Single Language') {
        $global:OSDCloud.OSEditionId = 'CoreSingleLanguage'
    }
    if ($global:OSDCloud.OSEdition -eq 'Education') {
        $global:OSDCloud.OSEditionId = 'Education'
    }
    if ($global:OSDCloud.OSEdition -eq 'Education N') {
        $global:OSDCloud.OSEditionId = 'EducationN'
    }
    if ($global:OSDCloud.OSEdition -eq 'Pro') {
        $global:OSDCloud.OSEditionId = 'Professional'
    }
    if ($global:OSDCloud.OSEdition -eq 'Pro N') {
        $global:OSDCloud.OSEditionId = 'ProfessionalN'
    }
    if ($global:OSDCloud.OSEdition -eq 'Enterprise') {
        $global:OSDCloud.OSEditionId = 'Enterprise'
    }
    if ($global:OSDCloud.OSEdition -eq 'Enterprise N') {
        $global:OSDCloud.OSEditionId = 'EnterpriseN'
    }
    Write-DarkGrayHost "OSEditionId = $($global:OSDCloud.OSEditionId)"

    # Match the OSEditionId to the OSImageIndex
    if ($global:OSDCloud.OSEditionId) {
        $MatchingWindowsImage = $global:OSDCloud.WindowsImage | `
            ForEach-Object { Get-WindowsImage -ImagePath $global:OSDCloud.ImageFileDestination.FullName -Index $_.ImageIndex } | `
            Where-Object { $_.EditionId -eq $global:OSDCloud.OSEditionId }
        
        if ($MatchingWindowsImage) {
            if ($MatchingWindowsImage.Count -eq 1) {
                $global:OSDCloud.OSImageIndex = $MatchingWindowsImage.ImageIndex
            }
        }
    }
    Write-DarkGrayHost "OSImageIndex = $($global:OSDCloud.OSImageIndex)"

    # Does the WindowsImage contain the ImageIndex?
    if ($global:OSDCloud.WindowsImage | Where-Object {$_.ImageIndex -eq $global:OSDCloud.OSImageIndex}) {
        Write-DarkGrayHost "WindowsImage contains the required ImageIndex"
    }
    else {
        Write-SectionHeader "Select the Windows Image to expand"
        $SelectedWindowsImage = $global:OSDCloud.WindowsImage | Where-Object {$_.ImageSize -gt 3000000000}

        if ($SelectedWindowsImage) {
            $SelectedWindowsImage | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host
    
            do {
                $SelectReadHost = Read-Host -Prompt "Select an Image to apply by ImageIndex [Number]"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $SelectedWindowsImage.ImageIndex))))
    
            #$global:OSDCloud.OSImageIndex = $SelectedWindowsImage | Where-Object {$_.ImageIndex -eq $SelectReadHost}
            $global:OSDCloud.OSImageIndex = $SelectReadHost
        }
    }

    if ($global:OSDCloud.OSImageIndex) {
        $global:OSDCloud.WindowsImage | Where-Object {$_.ImageSize -gt 3000000000} | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host
    }
    else {
        #=================================================
        #	FAILED
        #=================================================
        Write-Warning "[$(Get-Date -format G)] OSDCloud Failed"
        Write-Warning "Could not find a proper Windows Image for deployment"
        Write-Warning "Press Ctrl+C to exit"
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
    if ($global:OSDCloud.ImageFileDestination.FullName -match ".swm") {
        $ExpandWindowsImage = @{
            ApplyPath = 'C:\'
            ErrorAction = 'Stop'
            ImagePath = $global:OSDCloud.ImageFileDestination.FullName
            Name = (Get-WindowsImage -ImagePath $global:OSDCloud.ImageFileDestination.FullName).ImageName
            ScratchDirectory = 'C:\OSDCloud\Temp'
            SplitImageFilePattern = ($global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm")
        }
        Write-DarkGrayHost "SplitImageFilePattern: $(($global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm"))"
        Write-DarkGrayHost "Name: $((Get-WindowsImage -ImagePath $global:OSDCloud.ImageFileDestination.FullName).ImageName)"
    }
    else {
        $ExpandWindowsImage = @{
            ApplyPath = 'C:\'
            ErrorAction = 'Stop'
            ImagePath = $global:OSDCloud.ImageFileDestination.FullName
            Index = $global:OSDCloud.OSImageIndex
            ScratchDirectory = 'C:\OSDCloud\Temp'
        }
    }
    #endregion

    #region [WindowsImage] Expand-WindowsImage
    Write-DarkGrayHost "ApplyPath: 'C:\'"
    Write-DarkGrayHost "ImagePath: $($global:OSDCloud.ImageFileDestination.FullName)"
    Write-DarkGrayHost "Index: $($global:OSDCloud.OSImageIndex)"
    Write-DarkGrayHost "Expanding WindowsImage"

    $global:OSDCloud.ExpandWindowsImage = $ExpandWindowsImage
    if ($global:OSDCloud.IsWinPE -eq $true) {
        try {
            Expand-WindowsImage @ExpandWindowsImage
        }
        catch {
            Write-Warning "[$(Get-Date -format G)] Expand-WindowsImage failed."
            Write-Warning "[$(Get-Date -format G)] $_"
            Write-Warning 'Press Ctrl+C to cancel OSDCloud'
            Start-Sleep -Seconds 86400
            exit
        }
    }
    #endregion

    #region [WindowsImage] Get-WindowsEdition
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-install-getwindowsedition]"
    if ($global:OSDCloud.IsWinPE -eq $true) {
        try {
            $WindowsEdition = (Get-WindowsEdition -Path 'C:\' -ErrorAction Stop | Out-String).Trim()
            Write-DarkGrayHost "$WindowsEdition"
        }
        catch {
            Write-Warning "[$(Get-Date -format G)] Unable to get Windows Edition. OK."
            Write-Warning "[$(Get-Date -format G)] $_"
        }
        finally {
            $Error.Clear()
        }
    }
    #endregion

    #region [OS] bcdboot
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-install-bcdboot]"
    if ($global:OSDCloud.IsWinPE -eq $true) {
        # Check what architecture we are using
        if ($env:PROCESSOR_ARCHITECTURE -match 'ARM64') {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] X:\Windows\System32\bcdboot.exe C:\Windows /c /v"
            $BCDBootOutput = & X:\Windows\System32\bcdboot.exe C:\Windows /c /v
            $BCDBootOutput | Out-File -FilePath "$LogPath\bcdboot.log" -Force
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] C:\Windows\System32\bcdboot.exe C:\Windows /c /v"
            $BCDBootOutput = & C:\Windows\System32\bcdboot.exe C:\Windows /c /v
            $BCDBootOutput | Out-File -FilePath "$LogPath\bcdboot.log" -Force
        }
    }
    #endregion

    #region [Logs] Restart Logs and Transcript
    if (Test-Path $global:OSDCloud.Transcript) {
        try {
            Stop-Transcript -ErrorAction Stop
        }
        catch {
            <#Do this if a terminating exception happens#>
        }
    }
    if (Test-Path $global:OSDCloud.Logs) {
        $null = robocopy $($global:OSDCloud.Logs) "C:\Windows\Temp\osdcloud-logs" *.* /e /move /ndl /nfl /r:0 /w:0
    }
    $global:OSDCloud.Logs = "C:\Windows\Temp\osdcloud-logs"
    $LogsPath = $global:OSDCloud.Logs
    $Params = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        ItemType    = 'Directory'
        Path        = $LogsPath
    }
    if (-not (Test-Path $Params.Path)) {
        New-Item @Params | Out-Null
    }
    $global:OSDCloud.Transcript = Join-Path $LogsPath "osdcloud-transcript.log"
    try {
        Start-Transcript -Path $global:OSDCloud.Transcript -Append -ErrorAction Stop
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    #endregion

    #region [OS] SetupDisplayedEula
    Write-DarkGrayHost "[HotFix] Updating the OOBE SetupDisplayedEula value in the registry. OK."
    $null = reg load HKLM\TempSOFTWARE "C:\Windows\System32\Config\SOFTWARE"
    $null = reg add HKLM\TempSOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE /v SetupDisplayedEula /t REG_DWORD /d 0x00000001 /f
    $null = reg unload HKLM\TempSOFTWARE
    #endregion

    #region [OS] Directories
    $OSDCloudDirectories = @(
        'C:\Drivers',
        'C:\OSDCloud\Packages',
        'C:\OSDCloud\Scripts',
        'C:\Windows\Panther',
        'C:\Windows\Provisioning\Autopilot',
        'C:\Windows\Setup\Scripts'
    )

    foreach ($Item in $OSDCloudDirectories) {
        if (-not (Test-Path $Item)) {
            $ParamNewItem = @{
                ErrorAction = 'Stop'
                Force = $true
                ItemType = 'Directory'
                Path = $Item
            }
            Write-DarkGrayHost -Message "[Directory] Creating $Item"
            $null = New-Item @ParamNewItem
        }
    }
    #endregion

    #region [Drivers] Recast
    Step-OSDCloudWinpeDriverRecast
    #endregion

    #region [Drivers] GaryBlok HP CMSL
    # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [step-drivers-driverpack]"
    # Check the Global Variables for a Driver Pack name
    if ($global:OSDCloud.HPCMSLDriverPackLatest -eq $true) {
        Write-DarkGrayHost "[DriverPack] Request to use HP CMSL to download Driver Pack, setting DriverPackName to None"
        if (Test-WebConnection -Uri "google.com") {
            $global:OSDCloud.DriverPackName = 'None' #Set to None to prevent any other DriverPack from being used
        }
        else {
            $global:OSDCloud.HPCMSLDriverPackLatest = $false
            Write-DarkGrayHost "[DriverPack] Unable to reach internet, will not attempt to download HP Driver Pack via CMSL"
        }
    }
    #endregion
    
    #region [Drivers] DriverPacks
    if ($global:OSDCloud.DriverPackName) {
        if ($global:OSDCloud.DriverPackName -match 'None') {
            Write-DarkGrayHost "[DriverPack] DriverPackName is set to None. OK."
            $global:OSDCloud.DriverPack = $null
            if ((Test-DISMFromOSDCloudUSB) -eq $true) {
                Write-DarkGrayHost "[DriverPack] Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
                Start-DISMFromOSDCloudUSB
                $DriverPPKGNeeded = $false
            }
            else {
                if ($global:OSDCloud.HPCMSLDriverPackLatest -eq $true) {
                    Write-DarkGrayHost "[DriverPack] Attempting to use HPCMSL Functions to download Latest Driver Pack for Model"
                    $HPDriverPack = Get-HPDriverPackLatest
                    if ($HPDriverPack -ne $false){
                        $HPDriverPackObject = @{
                            Name = $HPDriverPack.Name
                            Product = Get-MyComputerProduct
                            FileName = ($HPDriverPack.url).Split('/')[-1]
                            Url = $HPDriverPack.Url
                        }
                        $global:OSDCloud.DriverPack = $HPDriverPackObject
                        $global:OSDCloud.HPCMSLDriverPackLatestFound = $HPDriverPack
                        Write-DarkGrayHost "[DriverPack] Found HP Driver Pack via CMSL, Setting Variables"
                    }
                    else {
                        $global:OSDCloud.HPCMSLDriverPackLatest = $false
                    }
                }
            }
        }
        elseif ($global:OSDCloud.DriverPackName -match 'Microsoft Update Catalog') {
            Write-DarkGrayHost "[DriverPack] DriverPackName is set to Microsoft Update Catalog. OK."
            $global:OSDCloud.DriverPack = $null
        }
        else {
            $global:OSDCloud.DriverPack = Get-OSDCloudDriverPacks | Where-Object {$_.Name -eq $global:OSDCloud.DriverPackName} | Select-Object -First 1
        }
    }
    else {
        if ($global:OSDCloud.Product) {
            $global:OSDCloud.DriverPack = Get-OSDCloudDriverPack -Product $global:OSDCloud.Product | Select-Object -First 1
        }
        else {
            $global:OSDCloud.DriverPack = Get-OSDCloudDriverPack | Select-Object -First 1
        }
    }

    if ($global:OSDCloud.DriverPack) {
        Write-DarkGrayHost "[DriverPack] DriverPack has been matched to $($global:OSDCloud.DriverPack.Name)"
        $global:OSDCloud.DriverPackBaseName = ($global:OSDCloud.DriverPack.FileName).Split('.')[0]
    }

    if ($global:OSDCloud.AzOSDCloudBlobDriverPack -and $global:OSDCloud.DriverPackBaseName) {
        Write-DarkGrayHost "[DriverPack] Searching for DriverPack in Azure Storage"
        $global:OSDCloud.AzOSDCloudDriverPack = $global:OSDCloud.AzOSDCloudBlobDriverPack | Where-Object {$_.Name -match $global:OSDCloud.DriverPackBaseName} | Select-Object -First 1
        if ($global:OSDCloud.AzOSDCloudDriverPack) {
            Write-DarkGrayHost "[DriverPack] DriverPack has been located in Azure Storage"
            $global:OSDCloud.AzOSDCloudDriverPack | ConvertTo-Json | Out-File -FilePath "$LogsPath\AzOSDCloudDriverPack.json" -Encoding ascii -Width 2000
        }
    }

    if ($global:OSDCloud.DriverPack) {
        $DriverPackObject = $global:OSDCloud.DriverPack
        $Manufacturer = $DriverPackObject.Manufacturer
        $FileName = $DriverPackObject.FileName
        $Url = $DriverPackObject.Url
        #=================================================
        # Is there a URL?
        if (-not $($DriverPackObject.Url)) {
            Write-Warning "[$(Get-Date -format G)] [DriverPack] DriverPackObject does not have a Url to validate."
            $global:OSDCloud.DriverPack = $null
        }
    }

    if ($global:OSDCloud.DriverPack) {
        #=================================================
        # Is the DriverPack reachable?
        $IsOnline = $false
        try {
            $WebRequest = Invoke-WebRequest -Uri $DriverPackObject.Url -UseBasicParsing -Method Head
            if ($WebRequest.StatusCode -eq 200) {
                Write-DarkGrayHost "[DriverPack] URL returned a 200 status code. OK."
                $IsOnline = $true
            }
        }
        catch {
            Write-DarkGrayHost "[DriverPack] URL is not reachable."
        }
        #=================================================
        # Does the file exist on a Drive?
        $IsOffline = $false
        $FileName = Split-Path $DriverPackObject.Url -Leaf
        $MatchingFiles = @()
        $MatchingFiles = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
            Get-ChildItem "$($_.Name):\OSDCloud\DriverPacks\" -Include "$FileName" -File -Recurse -Force -ErrorAction Ignore
        }
        
        if ($MatchingFiles) {
            Write-DarkGrayHost "[DriverPack] DriverPack is available offline. OK."
            $IsOffline = $true
        }
        else {
            Write-DarkGrayHost "[DriverPack] DriverPack is not available offline."
        }
        #=================================================
        # Nothing to do if it is unavailable online and offline
        if ($IsOnline -eq $false -and $IsOffline -eq $false) {
            Write-Warning "[$(Get-Date -format G)] DriverPack is not available online or offline."
            $global:OSDCloud.DriverPack = $null
        }
    }

    if ($global:OSDCloud.DriverPack) {
        $ScriptsPath = "C:\Windows\Setup\Scripts"
        $SetupCompleteCmd = "$ScriptsPath\SetupComplete.cmd"
        $SetupSpecializeCmd = "C:\Windows\Temp\osdcloud\SetupSpecialize.cmd"
        #=================================================
        # Create DownloadPath Directory
        $DownloadPath = "C:\Windows\Temp\osdcloud\drivers-driverpack-download"
        $Params = @{
            ErrorAction = 'SilentlyContinue'
            Force       = $true
            ItemType    = 'Directory'
            Path        = $DownloadPath
        }
        if (!(Test-Path $Params.Path -ErrorAction SilentlyContinue)) {
            New-Item @Params | Out-Null
        }
        #=================================================
        # Example DriverPackObject
        <#
            CatalogVersion : 25.04.11
            Status         :
            ReleaseDate    : 24.09.23
            Manufacturer   : HP
            Model          : ZBook Firefly 16 inch G11 Mobile Workstation PC
            Legacy         :
            Product        : 8cd1
            Name           : HP ZBook Firefly 16 inch G11 Mobile Workstation PC Win11 24H2 sp155206
            PackageID      : sp155206
            FileName       : sp155206.exe
            Url            : https://ftp.hp.com/pub/softpaq/sp155001-155500/sp155206.exe
            OS             : Windows 11 x64
            OSReleaseId    : 24H2
            OSBuild        : 26100
            OSArchitecture : amd64
            HashMD5        : 862E812233F66654AFF1A1D2246644A5
            Guid           : e9ee2f88-5aa5-407b-935e-274b39be7c2b
        #>
        $SaveMyDriverPack = $null
        $global:OSDCloud.DriverPackBaseName = ($global:OSDCloud.DriverPack.FileName).Split('.')[0]
        Write-DarkGrayHost "[DriverPack] Matching DriverPack identified"
        Write-DarkGrayHost $($global:OSDCloud.DriverPack.Name)
        Write-DarkGrayHost "Product $($global:OSDCloud.DriverPack.Product)"
        Write-DarkGrayHost $($global:OSDCloud.DriverPack.FileName)
        Write-DarkGrayHost $($global:OSDCloud.DriverPack.Url)
        if ((Test-DISMFromOSDCloudUSB -PackageID $global:OSDCloud.DriverPack.PackageID) -eq $true) {
            $global:OSDCloud.DriverPackDISM = $true
            $global:OSDCloud.DriverPackName = 'None'
            Write-DarkGrayHost "[DriverPack] Found expanded DriverPack files on OSDCloudUSB, will DISM them into the Offline OS directly"
            #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
        }
        else{
            $global:OSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $global:OSDCloud.DriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
            $global:OSDCloud.DriverPackOffline = $global:OSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1
        }
        if ($global:OSDCloud.DriverPackOffline) {
            Write-DarkGrayHost "[DriverPack] DriverPack is available on OSDCloudUSB and will not be downloaded"
            Write-DarkGrayHost $global:OSDCloud.DriverPack.Name
            Write-DarkGrayHost $global:OSDCloud.DriverPackOffline.FullName
            #$global:OSDCloud.DriverPackSource = Find-OSDCloudFile -Name (Split-Path -Path $global:OSDCloud.DriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $global:OSDCloud.DriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
            $global:OSDCloud.DriverPackSource = $global:OSDCloud.DriverPackOffline
        }
        if ($global:OSDCloud.DriverPackSource) {
            Write-DarkGrayHost "[DriverPack] DriverPack is being copied from OSDCloudUSB at $($global:OSDCloud.DriverPackSource.FullName) to $DownloadPath"
            Copy-Item -Path $global:OSDCloud.DriverPackSource.FullName -Destination $DownloadPath -Force
            $global:OSDCloud.DriverPackExpand = $true
        }
        elseif ($global:OSDCloud.DriverPackDISM) {
            #Use the Expanded Drivers on the OSDCloudUSB drive
            Start-DISMFromOSDCloudUSB -PackageID $global:OSDCloud.DriverPack.PackageID
        }
        elseif ($global:OSDCloud.HPCMSLDriverPackLatestFound) {
            #Download HP Driver Pack from HP CMSL
            Write-DarkGrayHost "[DriverPack] DriverPack Downloading to $DownloadPath\$($global:OSDCloud.DriverPack.FileName)"
            Get-HPDriverPackLatest -download
            if (Test-Path -Path "$DownloadPath\$($global:OSDCloud.DriverPack.FileName)") {
                Write-DarkGrayHost -Message "[DriverPack] Confirmed Downloaded to $DownloadPath\$($global:OSDCloud.DriverPack.FileName)"
                $global:OSDCloud.DriverPackExpand = $true
                $global:OSDCloud.DriverPackName = 'None' #Skips adding MS Update Catalog drivers into Process
                #$global:OSDCloud.OSDCloudUnattend = $true #Skips installing the PPKG File to load drivers in Specialize
            }
        }
        elseif ($global:OSDCloud.AzOSDCloudDriverPack) {
            Write-DarkGrayHost "[DriverPack] DriverPack is being downloaded from Azure Storage to $DownloadPath"

            try {
                Get-AzStorageBlobContent -CloudBlob $global:OSDCloud.AzOSDCloudDriverPack.ICloudBlob -Context $global:OSDCloud.AzOSDCloudDriverPack.Context -Destination "$DownloadPath\$(Split-Path $global:OSDCloud.AzOSDCloudDriverPack.Name -Leaf)"
            }
            catch {
                Get-AzStorageBlobContent -CloudBlob $global:OSDCloud.AzOSDCloudDriverPack.ICloudBlob -Context $global:OSDCloud.AzOSDCloudDriverPack.Context -Destination "$DownloadPath\$(Split-Path $global:OSDCloud.AzOSDCloudDriverPack.Name -Leaf)"
            }
            $global:OSDCloud.DriverPackExpand = $true
        }
        elseif ($global:OSDCloud.DriverPack.Guid) {
            $SaveMyDriverPack = Save-MyDriverPack -DownloadPath $DownloadPath -Guid $global:OSDCloud.DriverPack.Guid
            $global:OSDCloud.DriverPackExpand = $true
        }
        if ($global:OSDCloud.DriverPackExpand) {
            $DriverPacks = Get-ChildItem -Path $DownloadPath -File
            $OSDCloudUSB = Get-USBVolume | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {($_.FileSystemLabel -match "OSDCloud|BHIMAGE|USB-DATA")} | Where-Object {$_.SizeGB -ge 30} | Where-Object {$_.SizeRemainingGB -ge 2} | Select-Object -First 1

            foreach ($Item in $DriverPacks) {
                if (-not (Test-Path $Item.FullName)) {
                    Continue
                }

                $SaveMyDriverPack = $Item.FullName
                $ExpandFile = $Item.FullName
                Write-DarkGrayHost "[DriverPack] $ExpandFile"

                # Verify file exists
                $OutFileObject = Get-Item $Item.FullName

                if ($OutFileObject) {
                    if ($OSDCloudUSB) {
                        $OSDCloudUSBDestination = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\$($global:OSDCloud.DriverPack.Manufacturer)"
                        Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Copying DriverPack $SaveMyDriverPack to OSDCloudUSB at $OSDCloudUSBDestination"
                        If (!(Test-Path $OSDCloudUSBDestination)) {
                            $null = New-Item -Path $OSDCloudUSBDestination -ItemType Directory -Force
                        }
                        $null = Copy-Item -Path $SaveMyDriverPack -Destination $OSDCloudUSBDestination -Force -PassThru -ErrorAction Stop
                    }
                    #=================================================
                    #   Cab
                    #=================================================
                    if ($Item.Extension -eq '.cab') {
                        Step-OSDCloudWinpeDriverPackCab -FileInfo $Item
                        Continue
                    }
                    #=================================================
                    #   Zip
                    #=================================================
                    if ($Item.Extension -eq '.zip') {
                        Step-OSDCloudWinpeDriverPackZip -FileInfo $Item
                        Continue
                    }
                    #=================================================
                    #   Dell Update Package
                    #=================================================
                    if (($Item.Extension -eq '.exe') -and ($Item.VersionInfo.FileDescription -match 'Dell')) {
                        Step-OSDCloudWinpeDriverPackDell -FileInfo $Item
                        Continue
                    }
                    #=================================================
                    #   HP Softpaq
                    #=================================================
                    if (($Item.Extension -eq '.exe') -and ($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper')) {
                        Step-OSDCloudWinpeDriverPackHp -FileInfo $Item
                        Continue
                    }
                    #=================================================
                    #   Lenovo
                    #   SetupSpecialize.cmd
                    #=================================================
                    if (($Item.Extension -eq '.exe') -and ($Item.VersionInfo.FileDescription -match 'Lenovo')) {
                        Step-OSDCloudWinpeDriverPackLenovo -FileInfo $Item
                        Continue
                    }
                    #=================================================
                    #   Surface
                    #   SetupComplete.cmd
                    #=================================================
                    if (($Item.Extension -eq '.msi') -and ($Item.Name -match 'surface')) {
                        Step-OSDCloudWinpeDriverPackSurface -FileInfo $Item
                        Continue
                    }
                    #=================================================
                }
            }
        }
    }
    #endregion

    #region [Drivers] Microsoft Update Catalog Firmware
    # Write-SectionHeader "Drivers - Microsoft Update Catalog Firmware"
    $FirmwareUpdatePath = "C:\Windows\Temp\osdcloud\drivers-firmware"

    if ($OSDCloud.IsOnBattery -eq $true) {
        Write-DarkGrayHost "[Microsoft Update Catalog] Firmware update is not enabled for devices on battery power"
    }
    elseif ($OSDCloud.IsVirtualMachine) {
        Write-DarkGrayHost "[Microsoft Update Catalog] Firmware update is not enabled for Virtual Machines"
    }
    else {
        if (Test-MicrosoftUpdateCatalog) {
            Write-DarkGrayHost "[Microsoft Update Catalog] Firmware updates will be downloaded from Microsoft Update Catalog to $FirmwareUpdatePath"
            Write-DarkGrayHost "[Microsoft Update Catalog] Some systems do not support a driver Firmware Update"
            Write-DarkGrayHost "[Microsoft Update Catalog] You may have to enable this setting in your BIOS or Firmware Settings"
            Save-SystemFirmwareUpdate -DestinationDirectory $FirmwareUpdatePath
            if ($global:OSDCloud.MSCatalogFirmware -eq $false) {
                Write-DarkGrayHost "[Microsoft Update Catalog] Firmware update is not enabled for this deployment"
            }
            else {
                if ((Test-Path $FirmwareUpdatePath) -and ($global:OSDCloud.IsWinPE -eq $true)) {
                    Add-OfflineServicingWindowsDriver -Path $FirmwareUpdatePath
                }
            }
        }
        else {
            Write-Warning "[Microsoft Update Catalog] Unable to download or find firware for his Device"
        }
    }
    #endregion

    #region [Drivers] Microsoft Update Catalog
    if ($global:OSDCloud.DriverPackName -eq 'None') {
        Write-DarkGrayHost "[Microsoft Update Catalog] Drivers from Microsoft Update Catalog will not be applied for this deployment"
    }
    else {
        if (Test-MicrosoftUpdateCatalog) {
            $DestinationDirectory = "C:\Windows\Temp\osdcloud\drivers-msupdate"
            if ($global:OSDCloud.DriverPackName -eq 'Microsoft Update Catalog') {
                Write-DarkGrayHost "[Microsoft Update Catalog] Drivers for all devices will be downloaded to $DestinationDirectory"
                Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                if (Test-Path $DestinationDirectory) {
                    if ($global:OSDCloud.IsWinPE -eq $true) {
                        Write-DarkGrayHost "[Drivers] Apply drivers in $DestinationDirectory"
                        Add-OfflineServicingWindowsDriver -Path $DestinationDirectory
                    }
                }
            }
            elseif ($null -eq $SaveMyDriverPack) {
                Write-DarkGrayHost "[Microsoft Update Catalog] Drivers for all devices will be downloaded to $DestinationDirectory"
                Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                if (Test-Path $DestinationDirectory) {
                    if ($global:OSDCloud.IsWinPE -eq $true) {
                        Write-DarkGrayHost "[Drivers] Apply drivers in $DestinationDirectory"
                        Add-OfflineServicingWindowsDriver -Path $DestinationDirectory
                    }
                }
            }
            else {
                if ($OSDCloud.MSCatalogDiskDrivers) {
                    $DestinationDirectory = "C:\Windows\Temp\osdcloud\drivers-disk"
                    Write-DarkGrayHost "[Microsoft Update Catalog] Drivers for PNPClass DiskDrive will be downloaded to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'DiskDrive'
                    if (Test-Path $DestinationDirectory) {
                        if ($global:OSDCloud.IsWinPE -eq $true) {
                            Write-DarkGrayHost "[Drivers] Apply drivers in $DestinationDirectory"
                            Add-OfflineServicingWindowsDriver -Path $DestinationDirectory
                        }
                    }
                }
                if ($OSDCloud.MSCatalogNetDrivers) {
                    $DestinationDirectory = "C:\Windows\Temp\osdcloud\drivers-net"
                    Write-DarkGrayHost "[Microsoft Update Catalog] Drivers for PNPClass Net will be downloaded to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'Net'
                    if (Test-Path $DestinationDirectory) {
                        if ($global:OSDCloud.IsWinPE -eq $true) {
                            Write-DarkGrayHost "[Drivers] Apply drivers in $DestinationDirectory"
                            Add-OfflineServicingWindowsDriver -Path $DestinationDirectory
                        }
                    }
                }
                if ($OSDCloud.MSCatalogScsiDrivers) {
                    $DestinationDirectory = "C:\Windows\Temp\osdcloud\drivers-scsi"
                    Write-DarkGrayHost "[Microsoft Update Catalog] Drivers for PNPClass SCSIAdapter will be downloaded to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'SCSIAdapter'
                    if (Test-Path $DestinationDirectory) {
                        if ($global:OSDCloud.IsWinPE -eq $true) {
                            Write-DarkGrayHost "[Drivers] Apply drivers in $DestinationDirectory"
                            Add-OfflineServicingWindowsDriver -Path $DestinationDirectory
                        }
                    }
                }
            }
        }
        if ((Test-DISMFromOSDCloudUSB) -eq $true) {
            Write-DarkGrayHost "[Drivers] Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
            #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
            Start-DISMFromOSDCloudUSB
            $DriverPPKGNeeded = $false
        }
    }
    #endregion

    #region [Drivers] Apply C:\Drivers
    if (Test-Path "C:\Drivers") {
        # Write-SectionHeader "Add Windows Driver with Offline Servicing (Add-OfflineServicingWindowsDriver)"
        # Write-Verbose -Message "https://docs.microsoft.com/en-us/powershell/module/dism/add-windowsdriver"
        Write-DarkGrayHost "[Drivers] Apply drivers in C:\Drivers"
        if ($global:OSDCloud.IsWinPE -eq $true) {
            Add-OfflineServicingWindowsDriver
        }
    }
    #endregion
   
    #region [GaryBlok] Add Wireless Profile to SetupComplete.cmd
    if (-not ($SSID)) {
        $SSID = Get-WiFiActiveProfileSSID
        if ($SSID) {
            $PSK = Get-WiFiProfileKey -SSID $SSID
            if ($PSK) {
                $global:OSDCloud.SetWiFi = $true
            }
        }
    }

    if ($global:OSDCloud.SetWiFi -eq $true) {
        Write-DarkGrayHost "[WiFi] Adding WiFi Tasks into JSON Config File for Action during Specialize" 
        $PSKText = [System.Net.NetworkCredential]::new("", $PSK).Password
        $HashTable = @{
            'Addons' = @{
                'SSID' = $SSID
                'PSK' = $PSKText 
            }
        }
        $HashVar = $HashTable | ConvertTo-Json
        $ConfigFile = "$LogsPath\wifi.json"
        try {
            [void][System.IO.Directory]::CreateDirectory($LogsPath)
        }
        catch {
            # Do nothing
        }
        $HashVar | Out-File $ConfigFile
    }
    
    # Creates the SetupComplete.cmd & SetupComplete.ps1 files in C:\Windows\Setup\scripts
    # SetupComplete.cmd calls SetupComplete.ps1, which does all of the actual work
    Write-DarkGrayHost "[Task] Creating SetupComplete.cmd and SetupComplete.ps1"
    Set-SetupCompleteCreateStart
    
    if ($null -eq $global:OSDCloud.SetWiFi) {
        $global:OSDCloud.SetWiFi = $false
    }
    Write-DarkGrayHost "[Variable] `$global:OSDCloud.SetWiFi = $($global:OSDCloud.SetWiFi) (Enable Wireless)"
    if ($global:OSDCloud.SetWiFi -eq $true) {
        $SetWiFi = $true
        Step-OSDCloudSetupCompleteSetWiFi
    }
    #endregion

    #region [GaryBlok] Additional Tasks
    # Do we have an internet connection?
    if (Test-WebConnection -Uri "google.com") {
        $WebConnection = $True
    }

    if ($global:OSDCloud.IsWinPE -eq $true) {
        Write-DarkGrayHost "[Variable] `$global:OSDCloud.WindowsDefenderUpdate = $($global:OSDCloud.WindowsDefenderUpdate) (Enable Windows Defender Update)"
        if ($global:OSDCloud.WindowsDefenderUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteDefenderUpdate
            }
            else {
                # Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Defender Updates"
            }
        }
        Write-DarkGrayHost "[Variable] `$global:OSDCloud.WindowsUpdate = $($global:OSDCloud.WindowsUpdate) (Enable Windows Update)"
        if ($global:OSDCloud.WindowsUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdate
            }
            else {
                # Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Windows Updates"
            }
        }

        Write-DarkGrayHost "[Variable] `$global:OSDCloud.WindowsUpdateDrivers = $($global:OSDCloud.WindowsUpdateDrivers) (Windows Update Drivers)"
        if ($global:OSDCloud.WindowsUpdateDrivers -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdateDriver
            }
            else {
                # Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Windows Update Driver Updates"
            }
        }
        
        Write-DarkGrayHost "[Variable] `$global:OSDCloud.DevMode = $($global:OSDCloud.DevMode) (Enable DevMode)"
        if ($global:OSDCloud.DevMode -eq $true) {
            Write-DarkGrayHost "[Variable] `$global:OSDCloud.NetFx3 = $($global:OSDCloud.NetFx3) (Enable NetFX3)"
            if ($global:OSDCloud.NetFx3 -eq $true){
                if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                    Set-SetupCompleteNetFX
                }
                else {
                    # Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling NetFX Install"
                }
            }
        }
        if ($Null -eq $global:OSDCloud.SetTimeZone){$global:OSDCloud.SetTimeZone = $false}    
        Write-DarkGrayHost "[Variable] `$global:OSDCloud.SetTimeZone = $($global:OSDCloud.SetTimeZone) (Set TimeZone)"
        if ($global:OSDCloud.SetTimeZone -eq $true) {
            if ($WebConnection -eq $true) {
                Set-TimeZoneFromIP
            }
            else {
                Set-SetupCompleteTimeZone
            }
        }

        Write-DarkGrayHost "[Variable] `$global:OSDCloud.OEMActivation = $($global:OSDCloud.OEMActivation) (Enable OEM Activation)"
        if ($global:OSDCloud.OEMActivation -eq $true) {
            Set-SetupCompleteOEMActivation
        }
    }
    #endregion
    #=================================================
    #region [GaryBlok] Dell Updates Config for Specialize Phase
    if (($global:OSDCloud.DevMode -eq $true) -and ($WebConnection -eq $true)) {
        if (($global:OSDCloud.DCUInstall -eq $true) -or ($global:OSDCloud.DCUDrivers -eq $true) -or ($global:OSDCloud.DCUFirmware -eq $true) -or ($global:OSDCloud.DCUBIOS -eq $true) -or ($global:OSDCloud.DCUAutoUpdateEnable -eq $true) -or ($global:OSDCloud.DellTPMUpdate -eq $true)){
            
            #Set Enable Specialize to be triggered later
            $EnableSpecialize = $true

            Write-Host -ForegroundColor Cyan "Adding Dell Tasks into JSON Config File for Action during Specialize" 
            Write-DarkGrayHost "Install Dell Command Update = $($global:OSDCloud.DCUInstall) | Run DCU Drivers = $($global:OSDCloud.DCUDrivers) | Run DCU Firmware = $($global:OSDCloud.DCUFirmware)"
            Write-DarkGrayHost "Run DCU BIOS = $($global:OSDCloud.DCUBIOS) | Enable DCU Auto Update = $($global:OSDCloud.DCUAutoUpdateEnable) | DCU TPM Update = $($global:OSDCloud.DellTPMUpdate) " 
            $HashTable = @{
                'Updates' = @{
                    'DCUInstall' = $global:OSDCloud.DCUInstall
                    'DCUDrivers' = $global:OSDCloud.DCUDrivers
                    'DCUFirmware' = $global:OSDCloud.DCUFirmware
                    'DCUBIOS' = $global:OSDCloud.DCUBIOS
                    'DCUAutoUpdateEnable' = $global:OSDCloud.DCUAutoUpdateEnable
                    'DellTPMUpdate' = $global:OSDCloud.DellTPMUpdate
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
    #region [GaryBlok] HP Updates Config for Specialize Phase
    #Set Specialize JSON
    
    if (($global:OSDCloud.HPIAAll -eq $true) -or ($global:OSDCloud.HPIADrivers -eq $true) -or ($global:OSDCloud.HPIAFirmware -eq $true) -or ($global:OSDCloud.HPIASoftware -eq $true) -or ($global:OSDCloud.HPTPMUpdate -eq $true) -or ($global:OSDCloud.HPBIOSUpdate -eq $true)){
        if ($WebConnection) {  #This all requires the device to be online to download updates
            if (Test-HPIASupport){
                #Set Enable Specialize to be triggered later
                #$EnableSpecialize = $true #Disabling on 24.1.7, adding lower into the process only if TPM update is needed


                Write-SectionHeader "HP Enterprise Options Setup"
                Write-Host -ForegroundColor DarkGray " Confirmed Internet Connectivity"
                Write-Host -ForegroundColor DarkGray " Confirmed HP Tools Supported [Test-HPIASupport]"
                $HPFeaturesEnabled = $true
                write-host -ForegroundColor DarkGray " Confirm HPCMSL Installed [Install-ModuleHPCMSL]"
                Install-ModuleHPCMSL
                #If BIOS Update Desired, Confirm Update Available, if Not, set to False
                if ($global:OSDCloud.HPBIOSUpdate -eq $true){
                    [version]$HPBIOSVersion = Get-HPBIOSVersion
                    [version]$Latest = $((Get-HPBIOSUpdates -Latest).ver)
                    Write-Output "Checking HP BIOS Version via HPCMSL"
                    Write-Output " HP BIOS Ver Available: $Latest"
                    Write-Output " Installed BIOS Ver: $HPBIOSVersion"
                    #If Latest BIOS Available is Less than or Equal to Installed BIOS, Disable BIOS Update
                    if ($Latest -le $HPBIOSVersion){
                        $global:OSDCloud.HPBIOSUpdate = $false
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

                if ($global:OSDCloud.HPTPMUpdate -eq $true){
                    $TPMResult = Get-HPTPMDetermine
                    if (($TPMResult -ne "SP94937") -and ($TPMResult -ne "SP87753")){
                        Write-Host -ForegroundColor DarkGray "Switching HP TPM off, as no TPM Update is available"
                        $global:OSDCloud.HPTPMUpdate = $false
                    }
                }
                if (($global:OSDCloud.HPTPMUpdate -eq $true) -or ($global:OSDCloud.HPBIOSUpdate -eq $true)){
                    if ($HPSureAdminMode -eq "On"){
                        Write-Host "HP Sure Admin Enabled, Unable to Modify HP BIOS Settings or Perform HP BIOS / TPM Updates" -ForegroundColor Yellow
                        if ($global:OSDCloud.HPBIOSUpdate -eq $true){
                            $global:OSDCloud.HPBIOSUpdate = $false  #Set to False if Sure Admin Enable
                            $HPBIOSWinUpdate = $true #Attempt to use Windows Update Version Instead
                        }
                        $global:OSDCloud.HPTPMUpdate = $false
                    }
                    else { #Sure Admin Mode is Off
                        if ($global:OSDCloud.HPBIOSUpdate -eq $true){   
                            try { #Test for BIOS Password
                                Write-Host -ForegroundColor DarkGray "Testing for HP BIOS Password"
                                $PasswordSet = Get-HPBIOSSetupPasswordIsSet -ErrorAction SilentlyContinue
                            }
                            catch {
                                <#Do this if a terminating exception happens#>
                            }
                            if ($PasswordSet -eq $true) { 
                                Write-Host -ForegroundColor Yellow "Device currently has BIOS Setup Password, Attempting to use Get-HPBIOSWindowsUpdate Later in Process"
                                $HPBIOSWinUpdate = $true
                            }
                            else{ #No Password & No Sure Recover and there must be an update, so lets try to update it.
                                Write-Host -ForegroundColor Gray "Starting HP BIOS Update Process Job using HPCMSL [Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore]"
                                Write-Host -ForegroundColor DarkGray " Current Firmware: $(Get-HPBIOSVersion)"
                                Write-Host -ForegroundColor DarkGray " Staging Update: $((Get-HPBIOSUpdates -Latest).ver) "
                                #Details: https://developers.hp.com/hp-client-management/doc/Get-HPBiosUpdates
                                $timeoutSeconds = 60 # 1 Minite Timeout for BIOS Update
                                $code = {
                                    Start-Transcript -Path "$LogsPath\HPBIOSUpdateJob.log"
                                    Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore -ErrorAction SilentlyContinue -Verbose
                                    Stop-Transcript
                                }
                                #Start the Job
                                $HPBIOSUpdateNotes = "Attempted in WinPE - Update to $((Get-HPBIOSUpdates -Latest).ver)"
                                $Installing = Start-Job -ScriptBlock $code
                                # Report the job ID (for diagnostic purposes)
                                write-host -ForegroundColor DarkGray " BIOS Update Job ID: $($Installing.Id)"
                                Write-Host -ForegroundColor DarkGray " See Log: $LogsPath\HPBIOSUpdateJob.log for Details"
                                
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
                                if (Test-Path -Path "$LogsPath\HPBIOSUpdateJob.log"){
                                    Write-Host -ForegroundColor Cyan " $((Get-content -Path "$LogsPath\HPBIOSUpdateJob.log" -ReadCount 1) | Select-Object -last 6 | Select-Object -First 1)"
                                }
                                
                            }
                        }
                    }
                }

                if ($global:OSDCloud.HPTPMUpdate -eq $true){
                    Write-Host -ForegroundColor DarkGray "HP TPM Update: $(Get-HPTPMDetermine)"
                    Set-HPTPMBIOSSettings
                    if (Get-HPTPMDetermine -ne "False"){
                        Test-HPTPMFromOSDCloudUSB -TryToCopy
                        Invoke-HPTPMEXEDownload
                        $EnableSpecialize = $true
                    }
                    else {
                        #$global:OSDCloud.HPTPMUpdate = $false
                    }
                }
                
                if ($Null -eq $global:OSDCloud.HPIADrivers){$global:OSDCloud.HPIADrivers = $false}
                if ($Null -eq $global:OSDCloud.HPIAFirmware){$global:OSDCloud.HPIAFirmware = $false}
                if ($Null -eq $global:OSDCloud.HPIASoftware){$global:OSDCloud.HPIASoftware = $false}
                if ($Null -eq $global:OSDCloud.HPIAALL){$global:OSDCloud.HPIAALL = $false}
                if ($Null -eq $global:OSDCloud.HPTPMUpdate){$global:OSDCloud.HPTPMUpdate = $false}
                if ($Null -eq $global:OSDCloud.HPBIOSUpdate){$global:OSDCloud.HPBIOSUpdate = $false}
                if ($Null -eq $HPBIOSUpdateNotes){$HPBIOSUpdateNotes = "NA"}
                if ($Null -eq $HPBIOSWinUpdate){$HPBIOSWinUpdate = $false}

                Write-Host -ForegroundColor DarkGray "Adding HP Tasks into JSON Config File for Action during Specialize and Setup Complete"
                Write-DarkGrayHost "HPIA Drivers = $($global:OSDCloud.HPIADrivers) | HPIA Firmware = $($global:OSDCloud.HPIAFirmware) | HPIA Software = $($global:OSDCloud.HPIASoftware) | HPIA All = $($global:OSDCloud.HPIAAll) "
                Write-DarkGrayHost "HP TPM Update = $($global:OSDCloud.HPTPMUpdate) | HP BIOS Update = $($global:OSDCloud.HPBIOSUpdate) | HP BIOS WU Update = $HPBIOSWinUpdate" 

                $HPHashTable = @{
                    'HPUpdates' = @{
                        'HPIADrivers' = $global:OSDCloud.HPIADrivers
                        'HPIAFirmware' = $global:OSDCloud.HPIAFirmware
                        'HPIASoftware' = $global:OSDCloud.HPIASoftware
                        'HPIAAll' = $global:OSDCloud.HPIAALL
                        'HPTPMUpdate' = $global:OSDCloud.HPTPMUpdate
                        'HPBIOSUpdate' = $global:OSDCloud.HPBIOSUpdate
                        'HPBIOSWinUpdate' = $HPBIOSWinUpdate
                        'HPBIOSUpdateNotes' = $HPBIOSUpdateNotes
                    }
                }
                if (($global:OSDCloud.HPIAALL -eq $true) -or ($global:OSDCloud.HPIADrivers -eq $true) -or ($global:OSDCloud.HPIASoftware -eq $true) -or ($global:OSDCloud.HPIAFirmware -eq $true)){
                    Write-Host -ForegroundColor Yellow "Running HPIA during Setup Complete will add about 20 Minutes to OOBE (Just a moment...)"
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
            else { Write-DarkGrayHost "Failed Function Test-HPIASupport Function:This is Not a Supported HP Device, Skipping HP Enterprise Functions"}
        }
        else { Write-DarkGrayHost "No Interent Found, Skipping HP Device Updates"}
    }
    
                    
    #endregion
    #=================================================
    #Extra Items Config for Specialize Phase
    if (($global:OSDCloud.PauseSpecialize -eq $true) -and ($global:OSDCloud.DevMode -eq $true)) {
        
        #Set Enable Specialize to be triggered later
        $EnableSpecialize = $true

        if ($WebConnection){
            Write-Host -ForegroundColor Cyan "Adding Pause Tasks into JSON Config File for Action during Specialize" 
            $HashTable = @{
                'Addons' = @{
                    'Pause' = $global:OSDCloud.PauseSpecialize
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
        if ($global:OSDCloud.IsWinPE -eq $true) {
            Write-DarkGrayHost  "Set-OSDCloudUnattendSpecialize"
            Set-OSDCloudUnattendSpecialize
        }
    }
    if ($Null -eq $global:OSDCloud.Bitlocker){$global:OSDCloud.Bitlocker = $false}
    Write-DarkGrayHost "[Variable] `$global:OSDCloud.Bitlocker = $($global:OSDCloud.Bitlocker) (Enable Bitlocker)"
    if ($global:OSDCloud.Bitlocker -eq $true){
        Set-BitlockerRegValuesXTS256
        Set-SetupCompleteBitlocker
    }
    #endregion

    #region [Autopilot] AutopilotConfigurationFile.json
    if ($global:OSDCloud.AutopilotJsonObject) {
        Write-SectionHeader "Applying AutopilotConfigurationFile.json"
        Write-DarkGrayHost 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        $global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion

    #region [OOBEDeploy] OSDeploy.OOBEDeploy.json
    if ($global:OSDCloud.OOBEDeployJsonObject) {
        Write-SectionHeader "Applying OSDeploy.OOBEDeploy.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $global:OSDCloud.OOBEDeployJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json' -Encoding ascii -Width 2000 -Force
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

    #region [AutopilotOOBE] OSDeploy.AutopilotOOBE.json
    if ($global:OSDCloud.AutopilotOOBEJsonObject) {
        Write-SectionHeader "Applying OSDeploy.AutopilotOOBE.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion

    #region [ODTFile] Stage Office Config
    <#
    This region was added to enble installing Office in the Specialize phase
    It is probably not recommended to run this section, just showing that it is possible
    Recommended to remove this region by end of 2022
    David Segura
    #>
    if ($global:OSDCloud.ODTFile) {
        Write-SectionHeader "Stage Office Config"

        if (!(Test-Path $global:OSDCloud.ODTTarget)) {
            New-Item -Path $global:OSDCloud.ODTTarget -ItemType Directory -Force | Out-Null
        }

        if (Test-Path $global:OSDCloud.ODTFile.FullName) {
            Copy-Item -Path $global:OSDCloud.ODTFile.FullName -Destination $global:OSDCloud.ODTConfigFile -Force
        }

        $global:OSDCloud.ODTSetupFile = Join-Path $global:OSDCloud.ODTFile.Directory 'setup.exe'
        Write-Verbose -Verbose "ODTSetupFile: $($global:OSDCloud.ODTSetupFile)"
        if (Test-Path $global:OSDCloud.ODTSetupFile) {
            Copy-Item -Path $global:OSDCloud.ODTSetupFile -Destination $global:OSDCloud.ODTTarget -Force
        }

        $global:OSDCloud.ODTSource = Join-Path $global:OSDCloud.ODTFile.Directory 'Office'
        Write-Verbose -Verbose "ODTSource: $($global:OSDCloud.ODTSource)"
        if (Test-Path $global:OSDCloud.ODTSource) {
            Invoke-Exe robocopy "$($global:OSDCloud.ODTSource)" "$($global:OSDCloud.ODTTargetData)" *.* /s /ndl /nfl /z /b
        }
    }
    #endregion

    #region [Logs] Export OS Information
    <#
    The goal of this section is to export TXT files that contain information about the deployed Operating System
    This information can then be reviewed after deployment in C:\Windows\Temp\osdcloud-logs
    You can use this information to write scripts to remove AppxProvisionedPackage, or perform other tasks
    
    This region has no dependencies with anything else in OSDCloud and can be removed if needed
    David Segura
    #>
    #Grab Build from WinPE, as 24H2 has issues with some of these commands:
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $CurrentOSBuild = $($CurrentOSInfo.GetValue('CurrentBuild'))

    if (Get-Command Get-AppxProvisionedPackage -ErrorAction Ignore) {
        Write-DarkGrayHost "[Logs] Export WinPE PowerShell Commands to $LogsPath\Get-CommandWinPE.txt"
        $Report = Get-Command -ErrorAction Ignore | Where-Object {($_.CommandType -eq 'Cmdlet') -or ($_.CommandType -eq 'Function')} | Where-Object {$_.ModuleName -gt 0} | Sort-Object ModuleName, Name, Version
        $Report | Select-Object ModuleName, Name, Version | Out-File -FilePath "$LogsPath\Get-CommandWinPE.txt" -Force -Encoding ascii

        if (Get-Command Get-AppxProvisionedPackage) {
            Write-DarkGrayHost "[Logs] Export Appx Provisioned Packages to $LogsPath\Get-AppxProvisionedPackage.txt"
            $Report = Get-AppxProvisionedPackage -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object DisplayName
            $Report | Select-Object DisplayName | Out-File -FilePath "$LogsPath\Get-AppxProvisionedPackage.txt" -Force -Encoding ascii
        }

        if (Get-Command Get-WindowsCapability) {
            Write-DarkGrayHost "[Logs] Export Windows Capability to $LogsPath\Get-WindowsCapability.txt"
            if ($CurrentOSBuild -eq "26100"){
                $ArgumentList = "/Image=C:\ /Get-Capabilities"
                $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput "$LogsPath\Get-WindowsCapability.txt"
            }
            else {
                $Report = Get-WindowsCapability -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object Name
                $Report | Select-Object Name, State | Out-File -FilePath "$LogsPath\Get-WindowsCapability.txt" -Force -Encoding ascii
            }
        }

        if (Get-Command Get-WindowsEdition) {
            Write-DarkGrayHost "[Logs] Export Windows Edition to $LogsPath\Get-WindowsEdition.txt"
            $Report = Get-WindowsEdition -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object Edition
            $Report | Select-Object Edition | Out-File -FilePath "$LogsPath\Get-WindowsEdition.txt" -Force -Encoding ascii
        }

        if (Get-Command Get-WindowsOptionalFeature) {
            Write-DarkGrayHost "[Logs] Export Windows Optional Features to $LogsPath\Get-WindowsOptionalFeature.txt"
            $Report = Get-WindowsOptionalFeature -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object FeatureName
            $Report | Select-Object FeatureName, State | Out-File -FilePath "$LogsPath\Get-WindowsOptionalFeature.txt" -Force -Encoding ascii
        }

        if (Get-Command Get-WindowsPackage) {
            Write-DarkGrayHost "[Logs] Export Windows Packages to $LogsPath\Get-WindowsPackage.txt"
            if ($CurrentOSBuild -eq "26100"){
                $ArgumentList = "/Image=C:\ /Get-Packages"
                $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput "$LogsPath\Get-WindowsPackage.txt"
            }
            else {
                $Report = Get-WindowsPackage -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object PackageName
                $Report | Select-Object PackageName, PackageState, ReleaseType | Out-File -FilePath "$LogsPath\Get-WindowsPackage.txt" -Force -Encoding ascii
            }
        }

        if (Test-Path "X:\Windows\Logs\DISM\dism.log") {
            Copy-Item -Path "X:\Windows\Logs\DISM\dism.log" -Destination "$LogsPath\DISM-WinPE.log"
        }
    }
    #endregion

    #region [PowerShell] Save-Module
    # Write-SectionHeader "Saving PowerShell Modules and Scripts"
    if ($global:OSDCloud.IsWinPE -eq $true) {
        $PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'

        if (-NOT (Test-Path "$PowerShellSavePath\Configuration")) {
            New-Item -Path "$PowerShellSavePath\Configuration" -ItemType Directory -Force | Out-Null
        }
        if (-NOT (Test-Path "$PowerShellSavePath\Modules")) {
            New-Item -Path "$PowerShellSavePath\Modules" -ItemType Directory -Force | Out-Null
        }
        if (-NOT (Test-Path "$PowerShellSavePath\Scripts")) {
            New-Item -Path "$PowerShellSavePath\Scripts" -ItemType Directory -Force | Out-Null
        }
        
        if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
            try {
                Write-DarkGrayHost "[Save PS Module] OSD"
                Save-Module -Name OSD -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] Unable to Save-Module OSD to $PowerShellSavePath\Modules"
                Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
            }

            try {
                Write-DarkGrayHost "[Save PS Module] PackageManagement"
                Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] Unable to Save-Module PackageManagement to $PowerShellSavePath\Modules"
            }

            try {
                Write-DarkGrayHost "[Save PS Module] PowerShellGet"
                Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] Unable to Save-Module PowerShellGet to $PowerShellSavePath\Modules"
            }

            try {
                Write-DarkGrayHost "[Save PS Module] WindowsAutopilotIntune"
                Save-Module -Name WindowsAutopilotIntune -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] Unable to Save-Module WindowsAutopilotIntune to $PowerShellSavePath\Modules"
            }

            try {
                Write-DarkGrayHost "[Save PS Script] Get-WindowsAutopilotInfo"
                Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellSavePath\Scripts" -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] Unable to Save-Script Get-WindowsAutopilotInfo to $PowerShellSavePath\Scripts"
            }
            if ($HPFeaturesEnabled) {
                try {
                    Write-DarkGrayHost "[Save PS Module] WindowsAutopilotIntune"
                    Save-Module -Name HPCMSL -AcceptLicense -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning "[$(Get-Date -format G)] Unable to Save-Module HPCMSL to $PowerShellSavePath\Modules"
                }
            }
        }
        else {
            Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name PackageManagement -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name PowerShellGet -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name WindowsAutopilotIntune -Destination "$PowerShellSavePath\Modules"
            if ($HPFeaturesEnabled) {
                Write-Verbose -Verbose "Copy-PSModuleToFolder -Name HPCMSL to $PowerShellSavePath\Modules"
                Copy-PSModuleToFolder -Name HPCMSL -Destination "$PowerShellSavePath\Modules"
            }
            $OSDCloudOfflinePath = Find-OSDCloudOfflinePath
        
            foreach ($Item in $OSDCloudOfflinePath) {
                if (Test-Path "$($Item.FullName)\PowerShell\Required") {
                    Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
                    robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /s /ndl /njh /njs
                }
            }
        }
    }
    #endregion
 
    #region [GaryBlok] Debug and Dev Mode
    if ($WebConnection -eq $True){
        if ($global:OSDCloud.DebugMode -eq $true){
            Write-SectionHeader "DebugMode Enabled"
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
            osdcloud-addcmtrace
            osdcloud-addmouseoobe
            #sdcloud-UpdateModuleFilesManually
            #osdcloud-WinpeUpdateDefender
        }
    }
    #endregion

    #region [GaryBlok] Finish SetupComplete.cmd
    # Checks for SetupComplete.cmd file on USB Drive, if finds one, sets OSD process to run the SetupComplete
    # Flashdrive\OSDCloud\Config\Scripts\SetupComplete
    if (Get-SetupCompleteOSDCloudUSB -eq $true){
        Set-SetupCompleteOSDCloudUSB
    }
    # Makes it so that if SetupComplete finds C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd, it will run it.
    else{
        Set-SetupCompleteOSDCloudCustom
    }

    #This appends the two lines at the end of SetupComplete Script to Stop Transcription and to Restart Computer
    if ($global:OSDCloud.SetupCompleteNoRestart -eq $true) {
        Write-DarkGrayHost "[Optional] `$global:OSDCloud.SetupComplete = $($global:OSDCloud.SetupCompleteNoRestart) (SetupComplete.cmd No Restart)"
        Set-SetupCompleteCreateFinish -NoRestart
    }
    else {
        Set-SetupCompleteCreateFinish
    }
    #endregion

    #region [Config] Shutdown Scripts
    <#
    David Segura
    22.11.11.1
    These scripts will be in the OSDCloud Workspace in Config\Scripts\Shutdown
    When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
    In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\*
    #>
    $global:OSDCloud.ScriptShutdown = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.ScriptShutdown) {
        Write-SectionHeader 'Shutdown Scripts'
        $global:OSDCloud.ScriptShutdown = $global:OSDCloud.ScriptShutdown | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.ScriptShutdown) {
            Write-DarkGrayHost "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] AutopilotConfigurationFile.json
    $global:OSDCloud.AutomateAutopilot = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "AutopilotConfigurationFile.json" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateAutopilot) {
        Write-SectionHeader 'Automate AutopilotConfigurationFile.json'
        $global:OSDCloud.AutomateAutopilot = $global:OSDCloud.AutomateAutopilot | Sort-Object -Property FullName | Select-Object -First 1
        foreach ($Item in $global:OSDCloud.AutomateAutopilot) {
            Write-DarkGrayHost "$($Item.FullName)"
            $null = Copy-Item -Path $Item.FullName -Destination 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Force -ErrorAction Ignore
        }
    }
    #endregion

    #region [Azure] AutopilotConfigurationFile.json
    if ($global:OSDCloud.AzOSDCloudAutopilotFile) {
        Write-SectionHeader 'Set Azure AutopilotConfigurationFile.json'
        Write-DarkGrayHost 'Autopilot Configuration File will be downloaded to C:\Windows\Provisioning\Autopilot'

        foreach ($Item in $global:OSDCloud.AzOSDCloudAutopilotFile) {
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

    #region [Automate] Provisioning Packages
    $global:OSDCloud.AutomateProvisioning = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Provisioning" -Include "*.ppkg" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateProvisioning) {
        Write-SectionHeader 'Automate Provisioning Packages'
        $global:OSDCloud.AutomateProvisioning = $global:OSDCloud.AutomateProvisioning | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.AutomateProvisioning) {
            Write-DarkGrayHost "dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
            $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
            $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
        }
    }
    #endregion

    #region [Azure] Provisioning Packages
    if ($global:OSDCloud.AzOSDCloudPackage) {
        Write-SectionHeader 'Azure Provisioning Packages'
        Write-DarkGrayHost 'Provisioning Packages will be downloaded to C:\OSDCloud\Packages'

        foreach ($Item in $global:OSDCloud.AzOSDCloudPackage) {
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
                Write-DarkGrayHost "dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
                $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
                $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
            }
        }
    }
    #endregion

    #region [Automate] Shutdown Scripts
    $global:OSDCloud.AutomateShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($global:OSDCloud.AutomateShutdownScript) {
        Write-SectionHeader 'Automate Shutdown Scripts'
        $global:OSDCloud.AutomateShutdownScript = $global:OSDCloud.AutomateShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $global:OSDCloud.AutomateShutdownScript) {
            Write-DarkGrayHost "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region [Automate] Azure Shutdown Scripts
    if ($global:OSDCloud.AzOSDCloudScript) {
        Write-SectionHeader 'Automate Azure Shutdown Scripts'
        foreach ($Item in $global:OSDCloud.AzOSDCloudScript) {
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
            Write-DarkGrayHost "$($Item.FullName)"
            & "Execute $($Item.FullName)"
        }
    }
    #endregion

    #region [Step-OSDCloudWinpeCleanup]
    Step-OSDCloudWinpeCleanup
    #endregion

    #region [End]
    Write-SectionHeader "OSDCloud Finished"
    $global:OSDCloud.TimeEnd = Get-Date
    $global:OSDCloud.TimeSpan = New-TimeSpan -Start $global:OSDCloud.TimeStart -End $global:OSDCloud.TimeEnd
    $global:OSDCloud | ConvertTo-Json | Out-File -FilePath "$LogsPath\OSDCloud.json" -Encoding ascii -Width 2000 -Force
    Write-DarkGrayHost "Completed in $($global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))"

    if ($global:OSDCloud.Restart) {
        Write-Warning "WinPE is restarting in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($global:OSDCloud.IsWinPE -eq $true) {
            Restart-Computer
        }
    }

    if ($global:OSDCloud.Shutdown) {
        Write-Warning "WinPE will shutdown in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($global:OSDCloud.IsWinPE -eq $true) {
            Stop-Computer
        }
    }
    # Stop transcription
    try {
        Stop-Transcript -ErrorAction Stop    
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    #endregion
}
