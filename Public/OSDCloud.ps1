function Invoke-OSDCloud {
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
    
    #region Initialization
    function Write-DarkGrayDate {
        [CmdletBinding()]
        param (
            [Parameter(Position = 0)]
            [System.String]
            $Message
        )
        if ($Message) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $Message"
        }
        else {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
        }
    }
    function Write-DarkGrayHost {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [System.String]
            $Message
        )
        Write-Host -ForegroundColor DarkGray $Message
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
    function Write-SectionSuccess {
        [CmdletBinding()]
        param (
            [Parameter(Position = 0)]
            [System.String]
            $Message = 'Success!'
        )
        Write-DarkGrayDate
        Write-Host -ForegroundColor Green $Message
    }
    #endregion

    #region ----- OSDCloud Master Settings
    Write-DarkGrayHost "[i] Initializing `$Global.OSDCloud"
    $Global:OSDCloud = $null
    $Global:OSDCloud = [ordered]@{
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
        Logs = "$env:SystemDrive\OSDCloud\Logs"
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
        OSImageIndex = 1
        OSLanguage = $null
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSVersion = 'Windows 10'
        Product = Get-MyComputerProduct
        Restart = [bool]$false
        ScreenshotCapture = $false
        ScreenshotPath = "$env:TEMP\Screenshots"
        ScriptStartup = $null
        ScriptShutdown = $null
        SectionPassed = $true
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

    #region Set Initialization Defaults
    <#  If this is a Virtual Machine and Skip Recovery Partition 
        OVERRIDE:
        $Global:MyOSDCloud.RecoveryPartition = $true
    #>
    if ($Global:OSDCloud.IsVirtualMachine) {
        $Global:OSDCloud.SkipRecoveryPartition = $true
    }
    #endregion

    #region ----- Merge Variables
    <#  Overwrite the OSDCloud Master Settings by using custom variables
        MyOSDCloud is the last and final customization variable
    #>
    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global.InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost '[i] Not Used $Global.InvokeOSDCloud'
    }

    if ($Global:StartOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global.StartOSDCloud'
        foreach ($Key in $Global:StartOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:StartOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost '[i] Not Used $Global.StartOSDCloud'
    }

    if ($Global:StartOSDCloudCLI) {
        Write-DarkGrayHost '[i] Applying $Global.StartOSDCloudCLI'
        foreach ($Key in $Global:StartOSDCloudCLI.Keys) {
            $Global:OSDCloud.$Key = $Global:StartOSDCloudCLI.$Key
        }
    }
    else {
        Write-DarkGrayHost '[i] Not Used $Global.StartOSDCloudCLI'
    }

    if ($Global:InvokeOSDCloud) {
        Write-DarkGrayHost '[i] Reapplying $Global.InvokeOSDCloud'
        foreach ($Key in $Global:InvokeOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:InvokeOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost '[i] Not Used $Global.InvokeOSDCloud'
    }

    if ($Global:MyOSDCloud) {
        Write-DarkGrayHost '[i] Applying $Global.MyOSDCloud'
        foreach ($Key in $Global:MyOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:MyOSDCloud.$Key
        }
    }
    else {
        Write-DarkGrayHost '[i] Not Used $Global.MyOSDCloud'
    }
    #endregion

    #region Set Post-Merge Defaults
    $Global:OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

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
        Write-DarkGrayHost '$OSDCloud.IsWinPE = $false'
        $Global:OSDCloud.SkipClearDisk = $true
        $Global:OSDCloud.SkipNewOSDisk = $true
    }

    if ($Global:OSDCloud.ZTI -eq $true) {
        Write-DarkGrayHost '$OSDCloud.ZTI = $true'
        $Global:OSDCloud.ClearDiskConfirm = $false
    }
    #endregion

    #region Initialize OSDCloud Logs
    Write-SectionHeader 'Initialize OSDCloud Logs'
    $ParamNewItem = @{
        Path = $Global:OSDCloud.Logs
        ItemType = 'Directory'
        Force = $true
        ErrorAction = 'Stop'
    }

    if ($Global:OSDCloud.IsWinPE) {
        if (-not (Test-Path $Global:OSDCloud.Logs)) {
            $null = New-Item @ParamNewItem
        }
    }
    #endregion

    #region Gary Blok Initialize
        #region Global:OSDCloud.DebugMode
        if ($Global:OSDCloud.DebugMode -eq $true){
            Write-SectionHeader "DebugMode Write OSDCloud Vars"
            Write-DarkGrayHost "Writing OSDCloud Variables to $($env:temp)\OSDCloudVars.log"
            $OSDCloud | Out-File $env:temp\OSDCloudVars.log
        }
        #endregion
        
        #region Global:OSDCloud.SplashScreen
        if ($Global:OSDCloud.SplashScreen -eq $true){
            Write-SectionHeader "Setup SplashScreen"
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
            Write-SectionHeader "Gathering WiFi Information"
            Write-Host -ForegroundColor Yellow "Please Supply the SSID & Press Enter - CASE SENSITIVE"
            if (!($SSID)){$SSID = Read-Host}
            Write-Host -ForegroundColor Yellow "Please Supply the Password & Press Enter - CASE SENSITIVE"
            if (!($PSK)){$PSK = Read-Host -AsSecureString}
        }
        #endregion
        
        #region Global:OSDCloud.MS365Install
        if ($Global:OSDCloud.MS365Install -eq $true){
            Write-SectionHeader "Gathering M365 Information"
            Write-Host -ForegroundColor Magenta "Please Supply the CompanyName & Press Enter - CASE SENSITIVE"
            if (!($M365CompanyName)){$M365CompanyName = Read-Host}
            if ($M365CompanyName -eq ""){$M365CompanyName = "Organization"}
        }
        #endregion

    #endregion

    #region ----- ..\OSDCloud\Config\Scripts\Startup\*.ps1
    <#
    These scripts will be in the OSDCloud Workspace in Config\Scripts\Startup
    When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
    In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\Startup\*
    #>
    Write-SectionHeader '[i] Config Startup Scripts'
    $Global:OSDCloud.ScriptStartup = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Config\Scripts\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Startup\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.ScriptStartup) {
        $Global:OSDCloud.ScriptStartup = $Global:OSDCloud.ScriptStartup | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.ScriptStartup) {
            Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Config\Scripts\Shutdown\*.ps1
    Write-SectionHeader '[i] Config Shutdown Scripts'
    $Global:OSDCloud.ShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Config\Scripts\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Shutdown\" -Include '*.ps1' -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.ShutdownScript) {
        $Global:OSDCloud.ShutdownScript = $Global:OSDCloud.ShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.ShutdownScript) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\AutopilotConfigurationFile.json
    Write-SectionHeader '[i] Automate AutopilotConfigurationFile.json'
    $Global:OSDCloud.AutomateAutopilot = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\AutopilotConfigurationFile.json"
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "AutopilotConfigurationFile.json" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateAutopilot) {
        $Global:OSDCloud.AutomateAutopilot = $Global:OSDCloud.AutomateAutopilot | Sort-Object -Property FullName | Select-Object -First 1
        foreach ($Item in $Global:OSDCloud.AutomateAutopilot) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Provisioning\*.ppkg
    Write-SectionHeader '[i] Automate Provisioning Package'
    $Global:OSDCloud.AutomateProvisioning = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Provisioning\*.ppkg"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Provisioning" -Include "*.ppkg" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateProvisioning) {
        $Global:OSDCloud.AutomateProvisioning = $Global:OSDCloud.AutomateProvisioning | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateProvisioning) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Startup\*.ps1
    Write-SectionHeader '[i] Automate Startup Scripts'
    $Global:OSDCloud.AutomateStartupScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Startup" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateStartupScript) {
        $Global:OSDCloud.AutomateStartupScript = $Global:OSDCloud.AutomateStartupScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateStartupScript) {
            Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Shutdown\*.ps1
    Write-SectionHeader '[i] Automate Shutdown Scripts'
    $Global:OSDCloud.AutomateShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Write-DarkGrayHost "$($_.Root)OSDCloud\Automate\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateShutdownScript) {
        $Global:OSDCloud.AutomateShutdownScript = $Global:OSDCloud.AutomateShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateShutdownScript) {
            Write-Host -ForegroundColor Gray "Staging $($Item.FullName)"
        }
    }
    #endregion

    #region Launch Validation
        #region Install-Module LaunchMethod
        if ($Global:OSDCloud.LaunchMethod) {
            $null = Install-Module -Name $Global:OSDCloud.LaunchMethod -Force -ErrorAction Ignore -WarningAction Ignore
        }
        #endregion

        #region Validate Operating System Source
        Write-SectionHeader "Validate Operating System Source"

        $Global:OSDCloud.SectionPassed = $false
        if ($Global:OSDCloud.AzOSDCloudImage) {
            $Global:OSDCloud.SectionPassed = $true
        }
        if ($Global:OSDCloud.ImageFileItem) {
            $Global:OSDCloud.SectionPassed = $true
        }
        if ($Global:OSDCloud.ImageFileDestination) {
            $Global:OSDCloud.SectionPassed = $true
        }
        if ($Global:OSDCloud.ImageFileUrl) {
            $Global:OSDCloud.SectionPassed = $true
        }
        if ($Global:OSDCloud.SectionPassed -eq $false) {
            Write-Warning "OSDCloud Failed"
            Write-Warning "An Operating System Source was not specified by any required Variables"
            Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
            Write-Warning "Try using Start-OSDCloud, Start-OSDCloudGUI, or Start-OSDCloudAzure"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
        else {
            #Write-SectionSuccess
        }
        #endregion
        
        #region Autopilot Profiles
        if ($Global:OSDCloud.SkipAutopilot -ne $true) {
            Write-SectionHeader "Validate Autopilot Configuration"

            if ($Global:OSDCloud.AutopilotJsonObject) {
                Write-DarkGrayHost 'Importing AutopilotJsonObject'
            }
            elseif ($Global:OSDCloud.AutopilotJsonUrl) {
                Write-DarkGrayHost "Importing Autopilot Configuration $($Global:OSDCloud.AutopilotJsonUrl)"
                if (Test-WebConnection -Uri $Global:OSDCloud.AutopilotJsonUrl) {
                    $Global:OSDCloud.AutopilotJsonObject = (Invoke-WebRequest -Uri $Global:OSDCloud.AutopilotJsonUrl).Content | ConvertFrom-Json
                }
            }
            elseif ($Global:OSDCloud.AutopilotJsonItem) {
                $Global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name $Global:OSDCloud.AutopilotJsonItem.Name -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name $Global:OSDCloud.AutopilotJsonItem.Name -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonItem = $Global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
                if ($Global:OSDCloud.AutopilotJsonItem) {
                    $Global:OSDCloud.AutopilotJsonObject = Get-Content $Global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
                }
            }
            elseif ($Global:OSDCloud.AutopilotJsonName) {
                $Global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name $Global:OSDCloud.AutopilotJsonName -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name $Global:OSDCloud.AutopilotJsonName -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonItem = $Global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
                if ($Global:OSDCloud.AutopilotJsonItem) {
                    $Global:OSDCloud.AutopilotJsonObject = Get-Content $Global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
                }
            }
            else {
                $Global:OSDCloud.AutopilotJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonChildItem += Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
                $Global:OSDCloud.AutopilotJsonChildItem = $Global:OSDCloud.AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"}

                if ($Global:OSDCloud.AutopilotJsonChildItem) {
                    if ($Global:OSDCloud.ZTI -eq $true) {
                        $Global:OSDCloud.AutopilotJsonItem = $Global:OSDCloud.AutopilotJsonChildItem | Select-Object -First 1
                    }
                    else {
                        $Global:OSDCloud.AutopilotJsonItem = Select-OSDCloudAutopilotJsonItem
                    }

                    if ($Global:OSDCloud.AutopilotJsonItem) {
                        $Global:OSDCloud.AutopilotJsonObject = Get-Content $Global:OSDCloud.AutopilotJsonItem.FullName | ConvertFrom-Json
                    }
                }
            }

            if ($Global:OSDCloud.AutopilotJsonObject) {
                Write-DarkGrayHost "OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
                $($Global:OSDCloud.AutopilotJsonObject) | Out-Host | Format-List
            }
            else {
                Write-Warning "AutopilotConfigurationFile.json will not be configured for this deployment"
            }
        }
        #endregion
        
        #region Global:OSDCloud.ODTFile
        if ($Global:OSDCloud.SkipODT -ne $true) {
            $Global:OSDCloud.ODTFiles = Find-OSDCloudODTFile
            
            if ($Global:OSDCloud.ODTFiles) {
                Write-SectionHeader "Select Office Deployment Tool Configuration"
            
                $Global:OSDCloud.ODTFile = Select-OSDCloudODTFile
                if ($Global:OSDCloud.ODTFile) {
                    Write-DarkGrayHost "Office Config: $($Global:OSDCloud.ODTFile.FullName)"
                } 
                else {
                    Write-Warning "OSDCloud Office Config will not be configured for this deployment"
                }
            }
        }
        #endregion
        
        #region Global:OSDCloud.IsWinPE
        Write-SectionHeader "Validate WinPE"

        if ($Global:OSDCloud.IsWinPE -eq $false) {
            Write-Warning "OSDCloud can only be run from WinPE"
            Write-Warning "OSDCloud is running in Test mode"
            Start-Sleep -Seconds 5
        }
        #endregion

    #endregion

    #region Disk
        #region Validate Fixed Disk
        Write-SectionHeader 'Validate Fixed Disks'

        $Global:OSDCloud.SectionPassed = $false

        $Global:OSDCloud.GetDiskFixed = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if ($Global:OSDCloud.GetDiskFixed) {
            $Global:OSDCloud.SectionPassed = $true
        }
        else {
            $Global:OSDCloud.SectionPassed = $false
        }

        if ($Global:OSDCloud.SectionPassed -eq $false) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
            Write-Warning "Unable to locate a Fixed Disk. You may need to add additional HDC Drivers to WinPE"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
        else {
            #Write-SectionSuccess
        }
        #endregion
    
        #region Remove-PartitionAccessPath
        <#
        https://docs.microsoft.com/en-us/powershell/module/storage/remove-partitionaccesspath
        Partition Access Paths are being removed from USB Drive Letters
        This prevents issues when Drive Letters are reassigned
        #>
        $Global:OSDCloud.USBPartitions = Get-USBPartition
        if ($Global:OSDCloud.USBPartitions) {
            Write-SectionHeader "Removing USB drive letters"

            if ($Global:OSDCloud.IsWinPE -eq $true) {
                foreach ($USBPartition in $Global:OSDCloud.USBPartitions) {

                    $RemovePartitionAccessPath = @{
                        AccessPath = "$($USBPartition.DriveLetter):"
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }

                    Remove-PartitionAccessPath @RemovePartitionAccessPath -ErrorAction Stop
                    Start-Sleep -Seconds 3
                }
            }
        }
        #endregion
        
        #region Clear-Disk
        <#
        https://docs.microsoft.com/en-us/powershell/module/storage/clear-disk
        Fixed Disks must be cleared before new partitions can be created
        #>
        Write-SectionHeader "Clear-Disk"

        if ($Global:OSDCloud.SkipClearDisk -eq $true) {
            Write-DarkGrayHost '$OSDCloud.SkipClearDisk = $true'
        }

        if ($Global:OSDCloud.SkipClearDisk -eq $false) {
            Write-DarkGrayHost '$OSDCloud.SkipClearDisk = $false'

            if (($Global:OSDCloud.GetDiskFixed | Measure-Object).Count -ge 2) {
                Write-DarkGrayHost 'More than 1 Fixed Disk is present, Clear-Disk Confirm is required'
                $Global:OSDCloud.ClearDiskConfirm = $true
            }

            if ($Global:OSDCloud.ClearDiskConfirm -eq $true) {
                Write-DarkGrayHost '$OSDCloud.ClearDiskConfirm = $true'
                Clear-LocalDisk -Force -NoResults -ErrorAction Stop
            }
            else {
                Write-DarkGrayHost '$OSDCloud.ClearDiskConfirm = $false'
                Clear-LocalDisk -Force -NoResults -Confirm:$false -ErrorAction Stop
            }
        }
        #endregion
        
        #region New-OSDisk
        <#
        https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/configure-uefigpt-based-hard-drive-partitions
        New Partitions will be created using Microsoft Standard Layout
        #>

        Write-SectionHeader "New-OSDisk"
        if ($Global:OSDCloud.SkipNewOSDisk -eq $true) {
            Write-DarkGrayHost '$OSDCloud.SkipNewOSDisk = $true'
        }

        if ($Global:OSDCloud.SkipNewOSDisk -eq $false) {
            if ($Global:OSDCloud.DebugMode -eq $true){
                Write-DarkGrayHost "Capturing Disk Information Pre Modifications"
                $OSDISKPre = (Get-OSDGather -Full).DiskPartition
            }
           # Uses DiskPart instead of PS to create partitions, I think I'm going to depricate this soon.
            if ($Global:OSDCloud.DiskPart -eq $true) {
                Start-OSDDiskPart
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
                $LocalVolumes = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}
                Write-Output $LocalVolumes
            }
            else {
                if ($Global:OSDCloud.SkipRecoveryPartition -eq $true) {
                    New-OSDisk -PartitionStyle GPT -NoRecoveryPartition -Force -ErrorAction Stop
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                    Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                }
                else {
                    if ($Null -ne $Global:OSDCloud.OSInstallDiskNumber){
                        New-OSDisk -PartitionStyle GPT -DiskNumber $Global:OSDCloud.OSInstallDiskNumber -Force -ErrorAction Stop
                    }
                    else {New-OSDisk -PartitionStyle GPT -Force -ErrorAction Stop}
                    
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                    Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                    Write-Host "=========================================================================" -ForegroundColor Cyan
                    #Wait a few seconds to make sure the Disk is set
                    Start-Sleep -Seconds 5
                }
            }

            #Make sure that there is a PSDrive 
            if (-NOT (Get-PSDrive -Name 'C')) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "New-OSDisk didn't work. There is no PSDrive FileSystem at C:\"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }
            if ($Global:OSDCloud.DebugMode -eq $true){
                Write-DarkGrayHost "Capturing Disk Information Post Modifications"
                $OSDISKPost = (Get-OSDGather -Full).DiskPartition
            }
        }
        #endregion
        
        #region Add-PartitionAccessPath
        if ($Global:OSDCloud.USBPartitions) {
            Write-SectionHeader 'Restoring USB Drive Letters'

            if ($Global:OSDCloud.IsWinPE -eq $true) {
                foreach ($USBPartition in $Global:OSDCloud.USBPartitions) {

                    $ParamAddPartitionAccessPath = @{
                        AssignDriveLetter = $true
                        DiskNumber = $USBPartition.DiskNumber
                        PartitionNumber = $USBPartition.PartitionNumber
                    }
                    Add-PartitionAccessPath @ParamAddPartitionAccessPath; Start-Sleep -Seconds 5
                }
            }
        }
        #endregion
    #endregion Disk
    
    #region Pre-Image
        #region Global:OSDCloud.ScreenshotCapture
        if ($Global:OSDCloud.ScreenshotCapture) {
            Write-SectionHeader 'Moving Screenshots to C:\OSDCloud\Screenshots'
            Write-Verbose -Message 'https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy'
            Stop-ScreenPNGProcess
            Invoke-Exe robocopy "$($Global:OSDCloud.ScreenshotPath)" C:\OSDCloud\Screenshots *.* /s /ndl /nfl /njh /njs
            Start-ScreenPNGProcess -Directory 'C:\OSDCloud\Screenshots'
            $Global:OSDCloud.ScreenshotPath = 'C:\OSDCloud\Screenshots'
        }
        #endregion
        
        #region Global:OSDCloud.Transcript
        Write-SectionHeader 'Saving PowerShell Transcript to C:\OSDCloud\Logs'
        Write-Verbose -Message 'https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript'
        if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
            New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        
        $Global:OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
        Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $Global:OSDCloud.Transcript) -ErrorAction Ignore
        #endregion
        
        #region Global:OSDCloud.DebugMode
        if ($Global:OSDCloud.DebugMode -eq $true) {
            Write-SectionHeader 'DebugMode: Capture Data to Logs'
            Write-DarkGrayHost "OSD Module: $((Get-Module -Name OSD -ListAvailable | Select-Object -First 1).Version)"
            Write-DarkGrayHost "Manufacurer | Model | Product : $(Get-MyComputerManufacturer) | $(Get-MyComputerModel) | $(Get-MyComputerProduct)"
            Write-DarkGrayHost 'Writing Information to C:\OSDCloud\Logs\OSDCloudDebug.log'
            
            Write-DarkGrayHost ' OSDCloud Variables'
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log'
            'OSD Cloud Variables' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            $OSDCloud | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            
            Write-DarkGrayHost ' Windows 11 Readiness'
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            'Windows 11 Readiness' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            Get-Win11Readiness | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            
            Write-DarkGrayHost ' TPM Information'
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            'TPM Information' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            Get-CimInstance -Namespace root/CIMV2/Security/MicrosoftTpm -ClassName Win32_Tpm | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            
            Write-DarkGrayHost ' My Computer Info'
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            'My Computer Info' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            '=========================================================================' | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            Get-ComputerInfo | Out-File 'C:\OSDCloud\Logs\OSDCloudDebug.log' -Append
            
            $OSDISKPre | Out-File 'C:\OSDCloud\Logs\OSDCloudDiskPartPre.log'
            $OSDISKPost | Out-File 'C:\OSDCloud\Logs\OSDCloudDiskPartPost.log'
        }
        #endregion
        
        #region Powercfg High Performance
        #https://docs.microsoft.com/en-us/windows/win32/power/power-policy-settings
        Write-SectionHeader 'Powercfg High Performance'

        if ($Global:OSDCloud.IsOnBattery -eq $true) {
            $Win32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)
            if ($Win32Battery.BatteryStatus -eq 1) {
                Write-DarkGrayHost "Device has $($Win32Battery.EstimatedChargeRemaining)% battery remaining"
            }
            Write-DarkGrayHost 'High Performance will not be enabled while on battery'
        }
        elseif ($Global:OSDCloud.IsWinPE -eq $false) {
            Write-DarkGrayHost 'Device is not running in WinPE. Performance will not be adjusted'
        }
        elseif ($Global:OSDCloud.Debug -eq $true) {
            Write-DarkGrayHost 'Device is running in debug mode. Performance will not be adjusted'
        }
        else {
            Write-DarkGrayHost 'Enable powercfg High Performance'
            Invoke-Exe powercfg.exe -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        }
        #endregion
    #endregion

    #region Deploy Windows Image
        #region Copy-Item Offline WindowsImage
        if ($Global:OSDCloud.ImageFileItem) {
            Write-SectionHeader "Copy Offline Windows Image (Copy-Item)"
            Write-Verbose -Message "Copying Microsoft Windows Image from Offline Source"
            #It's possible that Drive Letters may have changed if a USB is used
            #Check to see if the image file exists already after the USB Drive has been reinitialized
            if (Test-Path $Global:OSDCloud.ImageFileItem.FullName) {
                $Global:OSDCloud.ImageFileSource = Get-Item -Path $Global:OSDCloud.ImageFileItem.FullName
            }
            #Set the ImageFile Name if it does not exist
            if (!($Global:OSDCloud.ImageFileName)) {
                $Global:OSDCloud.ImageFileName = Split-Path -Path $Global:OSDCloud.ImageFileItem.FullName -Leaf
            }
            #If the Source did not exist after the USB, have to do a best guess
            if (!($Global:OSDCloud.ImageFileSource)) {
                $Global:OSDCloud.ImageFileSource = Find-OSDCloudFile -Name $Global:OSDCloud.ImageFileName -Path (Split-Path -Path (Split-Path -Path $Global:OSDCloud.ImageFileItem.FullName -Parent) -NoQualifier) | Where-Object {$_.FullName -notlike "C:*"} | Select-Object -First 1
            }
            #Now that we have an ImageFileSource, everything is good
            if ($Global:OSDCloud.ImageFileSource) {
                Write-DarkGrayHost "-Source $($Global:OSDCloud.ImageFileSource.FullName)"
                if (!(Test-Path 'C:\OSDCloud\OS')) {
                    New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }
                if ($Global:OSDCloud.ImageFileSource.FullName -match ".swm"){
                    Copy-Item -Path "$($Global:OSDCloud.ImageFileSource.Directory.FullName)\*.swm" -Destination 'C:\OSDCloud\OS' -Force -Verbose
                }
                else {
                    Copy-Item -Path $Global:OSDCloud.ImageFileSource.FullName -Destination 'C:\OSDCloud\OS' -Force
                }
                
                if (Test-Path "C:\OSDCloud\OS\$($Global:OSDCloud.ImageFileSource.Name)") {
                    $Global:OSDCloud.ImageFileDestination = Get-Item -Path "C:\OSDCloud\OS\$($Global:OSDCloud.ImageFileSource.Name)"
                }
            }
            if ($Global:OSDCloud.ImageFileDestination) {
                Write-DarkGrayHost "-Destination $($Global:OSDCloud.ImageFileDestination.FullName)"
                $Global:OSDCloud.ImageFileUrl = $null
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "Could not copy the Windows Image to C:\OSDCloud\OS"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }
        }
        #endregion
        
        #region Get-OSDCloudOperatingSystems
        if ($Global:OSDCloud.AzOSDCloudImage) {
            #AzOSDCloud
        }
        elseif (!($Global:OSDCloud.ImageFileDestination) -and (!($Global:OSDCloud.ImageFileUrl))) {
            Write-SectionHeader "Get-OSDCloudOperatingSystems"
            Write-Warning "Invoke-OSDCloud was not set properly with an OS to Download"
            Write-Warning "You should be using Start-OSDCloud or Start-OSDCloudGUI"
            Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
            Write-Warning "Windows 10 Enterprise is being downloaded and installed out of convenience only"

            if (!($Global:OSDCloud.GetFeatureUpdate)) {
                $Global:OSDCloud.GetFeatureUpdate = Get-FeatureUpdate
            }
            if ($Global:OSDCloud.GetFeatureUpdate) {
                $Global:OSDCloud.GetFeatureUpdate = $Global:OSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
                $Global:OSDCloud.ImageFileName = $Global:OSDCloud.GetFeatureUpdate.FileName
                $Global:OSDCloud.ImageFileUrl = $Global:OSDCloud.GetFeatureUpdate.FileUri
                $Global:OSDCloud.OSImageIndex = 6
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "Unable to locate a Windows Feature Update"
                Write-Warning "OSDCloud cannot continue"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }
        }
        #endregion

        #region WindowsImage Download Azure Storage
        if ($Global:OSDCloud.AzOSDCloudImage) {
            Write-SectionHeader "OSDCloud Azure Storage Windows Image Download"

            $Global:OSDCloud.DownloadDirectory = "C:\OSDCloud\Azure\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.AccountName)\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.BlobContainerName)"
            $Global:OSDCloud.DownloadName = $(Split-Path $Global:OSDCloud.AzOSDCloudImage.Name -Leaf)
            $Global:OSDCloud.DownloadFullName = "$($Global:OSDCloud.DownloadDirectory)\$($Global:OSDCloud.DownloadName)"

            #Export Image Information
            $Global:OSDCloud.AzOSDCloudImage | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\AzOSDCloudImage.json' -Encoding ascii -Width 2000

            $ParamGetAzStorageBlobContent = @{
                CloudBlob = $Global:OSDCloud.AzOSDCloudImage.ICloudBlob
                Context = $Global:OSDCloud.AzOSDCloudImage.Context
                Destination = $Global:OSDCloud.DownloadFullName
                Force = $true
                ErrorAction = 'Stop'
            }

            $ParamGetItem = @{
                Path = $Global:OSDCloud.DownloadFullName
                ErrorAction = 'Stop'
            }

            $ParamNewItem = @{
                Path = $Global:OSDCloud.DownloadDirectory
                ItemType = 'Directory'
                Force = $true
                ErrorAction = 'Stop'
            }

            if (Test-Path $Global:OSDCloud.DownloadFullName) {
                Write-DarkGrayHost -Message "$($Global:OSDCloud.DownloadFullName) already exists"

                $Global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1

                if ($Global:OSDCloud.AzOSDCloudImage.Length -eq $Global:OSDCloud.ImageFileDestination.Length) {
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
                if (-not (Test-Path "$($Global:OSDCloud.DownloadDirectory)")) {
                    Write-DarkGrayHost -Message "Creating directory $($Global:OSDCloud.DownloadDirectory)"
                    $null = New-Item @ParamNewItem
                }

                try {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
                catch {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
            }
            
            $Global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1
        }
        #endregion

        #region WindowsImage Download
        if (!($Global:OSDCloud.ImageFileDestination) -and ($Global:OSDCloud.ImageFileUrl)) {
            Write-SectionHeader "Download Operating System"
            Write-DarkGrayHost "$($Global:OSDCloud.ImageFileUrl)"

            $null = New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Ignore
            if (Test-WebConnection -Uri $Global:OSDCloud.ImageFileUrl) {
                if ($Global:OSDCloud.ImageFileName) {
                    #=================================================
                    #	Cache to USB
                    #=================================================
                    $OSDCloudUSB = Get-USBVolume | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Where-Object {$_.SizeRemainingGB -ge 5} | Select-Object -First 1
                    
                    if ($OSDCloudUSB -and $Global:OSDCloud.OSVersion -and $Global:OSDCloud.OSReleaseID) {
                        $OSDownloadChildPath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\OS\$($Global:OSDCloud.OSVersion) $($Global:OSDCloud.OSReleaseID)"
                        Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Downloading OSDCloud Offline OS $OSDownloadChildPath"

                        $OSDCloudUsbOS = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory "$OSDownloadChildPath" -DestinationName $Global:OSDCloud.ImageFileName

                        if ($OSDCloudUsbOS) {
                            Write-SectionHeader "Copying Offline OS to C:\OSDCloud\OS\$($OSDCloudUsbOS.Name)"
                            $null = Copy-Item -Path $OSDCloudUsbOS.FullName -Destination "C:\OSDCloud\OS" -Force

                            $Global:OSDCloud.ImageFileDestination = Get-Item "C:\OSDCloud\OS\$($OSDCloudUsbOS.Name)"
                        }
                    }
                    else {
                        $Global:OSDCloud.ImageFileDestination = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -DestinationName $Global:OSDCloud.ImageFileName -ErrorAction Stop
                    }
                }
                else {
                    $Global:OSDCloud.ImageFileDestination = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -ErrorAction Stop
                }
                if (!(Test-Path $Global:OSDCloud.ImageFileDestination.FullName)) {
                    $Global:OSDCloud.ImageFileDestination = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd,*.iso | Select-Object -First 1
                }
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "Could not verify an Internet connection for the Windows ImageFile"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }

            if ($Global:OSDCloud.ImageFileDestination) {
                Write-Verbose -Message "ImageFileDestination: $($Global:OSDCloud.ImageFileDestination.FullName)"
            }
        }
        #endregion
        #region CheckSHA1
        if ($Global.OSDCloud.CheckSHA1 -eq $true){
            if (($Global:OSDCloud.ImageFileDestination) -and ($Global:OSDCloud.ImageFileDestination.FullName)){
                $Global:OSDCloud.ImageFileDestinationSHA1 = (Get-FileHash -Path $Global:OSDCloud.ImageFileDestination.FullName -Algorithm SHA1).Hash
                $Global:OSDCloud.ImageFileSHA1 = (Get-OSDCloudOperatingSystems | Where-Object {$_.FileName -eq $Global:OSDCloud.ImageFileName}).SHA1
                if ($Global:OSDCloud.ImageFileDestinationSHA1 -ne $Global:OSDCloud.ImageFileSHA1){
                    Write-Warning "SHA1 Mismatch"
                    Write-Warning "Downloaded ESD SHA1: $($Global:OSDCloud.ImageFileDestinationSHA1)"
                    Write-Warning "Catalog ESD SHA1: $($Global:OSDCloud.ImageFileSHA1)"
                    Write-Warning "Press Ctrl+C to exit"
                    Start-Sleep -Seconds 86400
                }
                else {
                    Write-Host -ForegroundColor Green "SHA1 Match"
                    Write-Host -ForegroundColor DarkGray " Catalog ESD SHA1:    $(($Global:OSDCloud.ImageFileSHA1).ToUpper())"
                    Write-Host -ForegroundColor DarkGray " Downloaded ESD SHA1: $($Global:OSDCloud.ImageFileDestinationSHA1)"
                }
            }
        }
        #endregion
        #region Global:OSDCloud.ImageFileDestination
        if (-not ($Global:OSDCloud.ImageFileDestination)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
            Write-Warning "The Windows Image Source did not download properly to the Destination"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
        #endregion
        
        #region ISO Disk Image File
        if ($Global:OSDCloud.ImageFileDestination.Extension -eq '.iso') {
            Write-SectionHeader "OSDCloud Windows ISO Deployment"

            $Global:OSDCloud.IsoGetDiskImage = Get-DiskImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName

            #ISO is already mounted (which should not be happening)
            if ($Global:OSDCloud.IsoGetDiskImage.Attached) {
                $Global:OSDCloud.IsoGetVolume = $Global:OSDCloud.IsoGetDiskImage | Get-Volume
                Write-DarkGrayHost "Windows ISO is attached to Drive Letter $($Global:OSDCloud.IsoGetVolume.DriveLetter)"
            }
            else {
                Write-DarkGrayHost "Mounting Windows ISO $($Global:OSDCloud.ImageFileDestination.FullName)"
                $Global:OSDCloud.IsoMountDiskImage = Mount-DiskImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName -PassThru -ErrorAction Stop

                if ($Global:OSDCloud.IsoMountDiskImage.Attached) {
                    Start-Sleep -Seconds 10
                    $Global:OSDCloud.IsoGetVolume = $Global:OSDCloud.IsoMountDiskImage | Get-Volume

                    Write-DarkGrayHost "Windows ISO is attached to Drive Letter $($Global:OSDCloud.IsoGetVolume.DriveLetter)"
                }
                else {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                    Write-Warning "The Windows ISO did not mount properly"
                    Write-Warning "Press Ctrl+C to exit"
                    Start-Sleep -Seconds 86400
                    Exit
                }
            }
            $Global:OSDCloud.ImageFileDestination = Get-ChildItem -Path "$($Global:OSDCloud.IsoGetVolume.DriveLetter):\*" -Include *.wim,*.esd -Recurse | Sort-Object Length -Descending | Select-Object -First 1

            if (-not ($Global:OSDCloud.ImageFileDestination)) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "Unable to find a WIM or ESD file on the Mounted Windows ISO"
                Write-Warning "Press Ctrl+C to exit"
                Start-Sleep -Seconds 86400
                Exit
            }
        }
        #endregion
        
        #region Validate WindowsImage Index
        Write-SectionHeader "Validate WindowsImage Index"
        if (Test-Path $Global:OSDCloud.ImageFileDestination.FullName) {
            $Global:OSDCloud.WindowsImage = Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName -ErrorAction Stop
            $Global:OSDCloud.WindowsImageCount = ($Global:OSDCloud.WindowsImage).Count

            #Bad Image
            if ($null -eq $Global:OSDCloud.WindowsImageCount) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "Could not read the Windows Image properly"
                Start-Sleep -Seconds 86400
                Stop-Computer -Force
                Exit
            }

            #TODO: Make sure the ImageIndex is 1
            elseif ($Global:OSDCloud.WindowsImageCount -eq 1) {
                $Global:OSDCloud.OSImageIndex = 1
            }

            #AUTO ImageIndex
            elseif ($Global:OSDCloud.OSImageIndex -match 'AUTO') {
                $Global:OSDCloud.OSImageIndex = 'AUTO'
            }
            elseif (-not ($Global:OSDCloud.OSImageIndex)) {
                $Global:OSDCloud.OSImageIndex = 'AUTO'
            }
            elseif ($null -eq $Global:OSDCloud.OSImageIndex) {
                $Global:OSDCloud.OSImageIndex = 'AUTO'
            }

            if ($Global:OSDCloud.OSImageIndex -ne 'AUTO') {
                #Home Single Language Correction
                if (($OSActivation -eq 'Retail') -and ($Global:OSDCloud.WindowsImageCount -eq 9)) {
                    if ($OSEdition -eq 'Home Single Language') {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                        Write-Warning "This ESD does not contain a Home Single Edition Index"
                        Write-Warning "Restart OSDCloud and select a different Edition"
                        Start-Sleep -Seconds 86400
                        Stop-Computer -Force
                        Exit
                    }
                    if ($OSEdition -notmatch 'Home') {
                        Write-DarkGrayHost "This ESD does not contain a Home Single Edition Index"
                        Write-DarkGrayHost "Adjusting selected ImageIndex by -1"
                        $Global:OSDCloud.OSImageIndex = ($Global:OSDCloud.OSImageIndex - 1)
                        Write-DarkGrayHost "ImageIndex: $($Global:OSDCloud.OSImageIndex)"
                    }
                }
            }
        }
        else {
            #=================================================
            #	FAILED
            #=================================================
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
            Write-Warning "Could not find a proper Windows Image for deployment"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }

        if ($Global:OSDCloud.OSImageIndex -eq 'AUTO') {
            Write-SectionHeader "Select the Windows Image to expand"
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
        else {
            $Global:OSDCloud.WindowsImage | Where-Object {$_.ImageSize -gt 3000000000} | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host
        }
        #endregion

        #region Expand-WindowsImage
        Write-SectionHeader "Expand-WindowsImage"
        Write-DarkGrayHost "ApplyPath: 'C:\'"
        Write-DarkGrayHost "ImagePath: $($Global:OSDCloud.ImageFileDestination.FullName)"
        Write-DarkGrayHost "Index: $($Global:OSDCloud.OSImageIndex)"
        Write-DarkGrayHost "ScratchDirectory: 'C:\OSDCloud\Temp'"

        $ParamNewItem = @{
            Path = 'C:\OSDCloud\Temp'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
            Write-DarkGrayHost -Message 'Creating ScratchDirectory C:\OSDCloud\Temp'
            $null = New-Item @ParamNewItem
        }
        if ($Global:OSDCloud.ImageFileDestination.FullName -match ".swm"){
            $ExpandWindowsImage = @{
                Name = (Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName).ImageName
                ApplyPath = 'C:\'
                ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
                SplitImageFilePattern = ($Global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm")
                ScratchDirectory = 'C:\OSDCloud\Temp'
                ErrorAction = 'Stop'
            }
            Write-DarkGrayHost "SplitImageFilePattern: $(($Global:OSDCloud.ImageFileDestination.FullName).replace("install.swm","install*.swm"))"
            Write-DarkGrayHost "Name: $((Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileDestination.FullName).ImageName)"
        }
        else {
            $ExpandWindowsImage = @{
                ApplyPath = 'C:\'
                ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
                Index = $Global:OSDCloud.OSImageIndex
                ScratchDirectory = 'C:\OSDCloud\Temp'
                ErrorAction = 'Stop'
            }
        }

        $Global:OSDCloud.ExpandWindowsImage = $ExpandWindowsImage
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Write-DarkGrayHost -Message 'Expand-WindowsImage'
            Expand-WindowsImage @ExpandWindowsImage
        }
        #endregion

        #region Get-WindowsEdition
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Write-SectionHeader 'Get-WindowsEdition'
            $WindowsEdition = (Get-WindowsEdition -Path 'C:\' | Out-String).Trim()
            $WindowsEdition | Write-Host
        }
        #endregion

        #region BCDBoot
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Write-SectionHeader 'BCDBoot with Verbose Logging'
            #https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di?view=windows-11
            #Updated configuration that should clear existing UEFI Boot entires and fix the Dell issue
            Invoke-Exe C:\Windows\System32\bcdboot.exe C:\Windows /v /c
        }
        #endregion
    #endregion WindowsImage

    #region Content Directories
    Write-SectionHeader 'Create Content Directories'

    if (-NOT (Test-Path 'C:\Drivers')) {
        $ParamNewItem = @{
            Path = 'C:\Drivers'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\Drivers'
        $null = New-Item @ParamNewItem
    }
    if (-NOT (Test-Path 'C:\OSDCloud\Packages')) {
        $ParamNewItem = @{
            Path = 'C:\OSDCloud\Packages'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\OSDCloud\Packages'
        $null = New-Item @ParamNewItem
    }
    if (-NOT (Test-Path 'C:\OSDCloud\Scripts')) {
        $ParamNewItem = @{
            Path = 'C:\OSDCloud\Scripts'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\OSDCloud\Scripts'
        $null = New-Item @ParamNewItem
    }
    if (-NOT (Test-Path 'C:\Windows\Panther')) {
        $ParamNewItem = @{
            Path = 'C:\Windows\Panther'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\Windows\Panther'
        $null = New-Item @ParamNewItem
    }
    if (-NOT (Test-Path 'C:\Windows\Provisioning\Autopilot')) {
        $ParamNewItem = @{
            Path = 'C:\Windows\Provisioning\Autopilot'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\Windows\Provisioning\Autopilot'
        $null = New-Item @ParamNewItem
    }
    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
        $ParamNewItem = @{
            Path = 'C:\Windows\Setup\Scripts'
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }
        Write-DarkGrayHost -Message 'Creating C:\Windows\Setup\Scripts'
        $null = New-Item @ParamNewItem
    }
    #endregion

    #region Drivers
        #region Get-OSDCloudDriverPack
        Write-SectionHeader 'OSDCloud DriverPack'
        #Check the Global Variables for a Driver Pack name
        if ($Global:OSDCloud.HPCMSLDriverPackLatest -eq $true){
            Write-DarkGrayHost "Request to use HP CMSL to download Driver Pack, setting DriverPackName to None"
            if (Test-WebConnection -Uri "google.com") {
                $Global:OSDCloud.DriverPackName = 'None' #Set to None to prevent any other DriverPack from being used
            }
            else {
                $Global:OSDCloud.HPCMSLDriverPackLatest = $false
                Write-DarkGrayHost "Unable to reach internet, will not attempt to download HP Driver Pack via CMSL"
            }
        }
        
        if ($Global:OSDCloud.DriverPackName) {
            if ($Global:OSDCloud.DriverPackName -match 'None') {
                Write-DarkGrayHost "DriverPack is set to None"
                $Global:OSDCloud.DriverPack = $null
                if ((Test-DISMFromOSDCloudUSB) -eq $true){
                    Write-DarkGrayHost "Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                    #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
                    Start-DISMFromOSDCloudUSB
                    $DriverPPKGNeeded = $false
                }
                else {
                    if ($Global:OSDCloud.HPCMSLDriverPackLatest -eq $true){
                        
                        Write-DarkGrayHost "Attempting to use HPCMSL Functions to download Latest Driver Pack for Model"
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
                            Write-DarkGrayHost "Found HP Driver Pack via CMSL, Setting Variables"
                        }
                        else {
                            $Global:OSDCloud.HPCMSLDriverPackLatest = $false
                        }
                    }
                }
            }
            elseif ($Global:OSDCloud.DriverPackName -match 'Microsoft Update Catalog') {
                Write-DarkGrayHost "DriverPack is set to Microsoft Update Catalog"
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

        if ($Global:OSDCloud.DriverPack) {
            Write-DarkGrayHost "DriverPack has been matched to $($Global:OSDCloud.DriverPack.Name)"
            $Global:OSDCloud.DriverPackBaseName = ($Global:OSDCloud.DriverPack.FileName).Split('.')[0]
        }

        if ($Global:OSDCloud.AzOSDCloudBlobDriverPack -and $Global:OSDCloud.DriverPackBaseName) {
            Write-DarkGrayHost "Searching for DriverPack in Azure Storage"
            $Global:OSDCloud.AzOSDCloudDriverPack = $Global:OSDCloud.AzOSDCloudBlobDriverPack | Where-Object {$_.Name -match $Global:OSDCloud.DriverPackBaseName} | Select-Object -First 1
            if ($Global:OSDCloud.AzOSDCloudDriverPack) {
                Write-DarkGrayHost "DriverPack has been located in Azure Storage"
                $Global:OSDCloud.AzOSDCloudDriverPack | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\AzOSDCloudDriverPack.json' -Encoding ascii -Width 2000
            }
        }

        if ($Global:OSDCloud.DriverPack) {
            $SaveMyDriverPack = $null
            $Global:OSDCloud.DriverPackBaseName = ($Global:OSDCloud.DriverPack.FileName).Split('.')[0]
            Write-DarkGrayHost "Matching DriverPack identified"
            Write-DarkGrayHost "-Name $($Global:OSDCloud.DriverPack.Name)"
            Write-DarkGrayHost "-BaseName $($Global:OSDCloud.DriverPackBaseName)"
            Write-DarkGrayHost "-Product $($Global:OSDCloud.DriverPack.Product)"
            Write-DarkGrayHost "-FileName $($Global:OSDCloud.DriverPack.FileName)"
            Write-DarkGrayHost "-Url $($Global:OSDCloud.DriverPack.Url)"
            if ((Test-DISMFromOSDCloudUSB -PackageID $Global:OSDCloud.DriverPack.PackageID) -eq $true){
                $Global:OSDCloud.DriverPackDISM = $true
                $Global:OSDCloud.DriverPackName = 'None'
                Write-DarkGrayHost "Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
            }
            else{
                $Global:OSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $Global:OSDCloud.DriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
                $Global:OSDCloud.DriverPackOffline = $Global:OSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1
            }
            if ($Global:OSDCloud.DriverPackOffline) {
                Write-DarkGrayHost "DriverPack is available on OSDCloudUSB and will not be downloaded"
                Write-DarkGrayHost $Global:OSDCloud.DriverPack.Name
                Write-DarkGrayHost $Global:OSDCloud.DriverPackOffline.FullName
                #$Global:OSDCloud.DriverPackSource = Find-OSDCloudFile -Name (Split-Path -Path $Global:OSDCloud.DriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $Global:OSDCloud.DriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
                $Global:OSDCloud.DriverPackSource = $Global:OSDCloud.DriverPackOffline
            }
            if ($Global:OSDCloud.DriverPackSource) {
                Write-DarkGrayHost "DriverPack is being copied from OSDCloudUSB at $($Global:OSDCloud.DriverPackSource.FullName) to C:\Drivers"
                Copy-Item -Path $Global:OSDCloud.DriverPackSource.FullName -Destination 'C:\Drivers' -Force
                $Global:OSDCloud.DriverPackExpand = $true
            }
            elseif ($Global:OSDCloud.DriverPackDISM){
                #Use the Expanded Drivers on the OSDCloudUSB drive
                Start-DISMFromOSDCloudUSB -PackageID $Global:OSDCloud.DriverPack.PackageID
            }
            elseif ($Global:OSDCloud.HPCMSLDriverPackLatestFound){
                #Download HP Driver Pack from HP CMSL

                Write-DarkGrayHost "Driver Pack Downloading to c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"
                Get-HPDriverPackLatest -download
                if (Test-Path -Path "c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"){
                    Write-DarkGrayHost -Message "Confirmed Downloaded to c:\Drivers\$($Global:OSDCloud.DriverPack.FileName)"
                    $Global:OSDCloud.DriverPackExpand = $true
                    $Global:OSDCloud.DriverPackName = 'None' #Skips adding MS Update Catalog drivers into Process
                    #$Global:OSDCloud.OSDCloudUnattend = $true #Skips installing the PPKG File to load drivers in Specialize
                }
            }
            elseif ($Global:OSDCloud.AzOSDCloudDriverPack) {
                Write-DarkGrayHost "DriverPack is being downloaded from Azure Storage to C:\Drivers"

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
                            Write-DarkGrayHost "DriverPack CAB is being expanded to $DestinationPath"
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
                            Write-DarkGrayHost "DriverPack ZIP is being expanded to $DestinationPath"
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
                            Write-DarkGrayHost "Dell Update Package is being expanded to $DestinationPath"
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
                                Write-DarkGrayHost "7zip not found, unable to expand HP Softpaq"
                                Write-DarkGrayHost "Please add 7zip your OSDCloud Boot Media to use this feature"
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
                            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying Driver Pack $DriverPackPath to OSDCloudUSB at $OSDCloudUSBDestination"
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
        Write-SectionHeader "Microsoft Update Catalog Firmware"

        if ($OSDCloud.IsOnBattery -eq $true) {
            Write-DarkGrayHost "Microsoft Update Catalog Firmware is not enabled for devices on battery power"
        }
        elseif ($OSDCloud.IsVirtualMachine) {
            Write-DarkGrayHost "Microsoft Update Catalog Firmware is not enabled for Virtual Machines"
        }
        elseif ($Global:OSDCloud.MSCatalogFirmware -eq $false) {
            Write-DarkGrayHost "Microsoft Update Catalog Firmware is not enabled for this deployment"
        }
        else {
            if (Test-MicrosoftUpdateCatalog) {
                Write-DarkGrayHost "Firmware Updates will be downloaded from Microsoft Update Catalog to C:\Drivers\Firmware"
                Write-DarkGrayHost "Some systems do not support a driver Firmware Update"
                Write-DarkGrayHost "You may have to enable this setting in your BIOS or Firmware Settings"
        
                Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'
            }
            else {
                Write-Warning "Unable to download or find firware for his Device"
            }
        }
        #endregion

        #region Save-MsUpCatDriver
        Write-SectionHeader "Microsoft Update Catalog Drivers"

        if ($Global:OSDCloud.DriverPackName -eq 'None') {
            Write-DarkGrayHost "Drivers from Microsoft Update Catalog will not be applied for this deployment"
        }
        else {
            if (Test-MicrosoftUpdateCatalog) {
                $DestinationDirectory = 'C:\Drivers\MsUpCatDrivers'
                if ($Global:OSDCloud.DriverPackName -eq 'Microsoft Update Catalog') {
                    Write-DarkGrayHost "Drivers for all devices will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                }
                elseif ($null -eq $SaveMyDriverPack) {
                    Write-DarkGrayHost "Drivers for all devices will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                    Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory
                }
                else {
                    if ($OSDCloud.MSCatalogDiskDrivers) {
                        Write-DarkGrayHost "Drivers for PNPClass DiskDrive will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'DiskDrive'
                    }
                    if ($OSDCloud.MSCatalogNetDrivers) {
                        Write-DarkGrayHost "Drivers for PNPClass Net will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'Net'
                    }
                    if ($OSDCloud.MSCatalogScsiDrivers) {
                        Write-DarkGrayHost "Drivers for PNPClass SCSIAdapter will be downloaded from Microsoft Update Catalog to $DestinationDirectory"
                        Save-MsUpCatDriver -DestinationDirectory $DestinationDirectory -PNPClass 'SCSIAdapter'
                    }
                }
            }
            if ((Test-DISMFromOSDCloudUSB) -eq $true){
                Write-DarkGrayHost "Found expanded Driver Pack files on OSDCloudUSB, will DISM them into the Offline OS directly"
                #Found Expanded Driver Package on OSDCloudUSB, will DISM Directly from that
                Start-DISMFromOSDCloudUSB
                $DriverPPKGNeeded = $false
            }
        }
        #endregion
        
        #region Add-OfflineServicingWindowsDriver
        Write-SectionHeader "Add Windows Driver with Offline Servicing (Add-OfflineServicingWindowsDriver)"
        Write-Verbose -Message "https://docs.microsoft.com/en-us/powershell/module/dism/add-windowsdriver"
        Write-DarkGrayHost "Drivers in C:\Drivers are being added to the offline Windows Image"
        Write-DarkGrayHost "This process can take up to 20 minutes"
        Write-Verbose -Message "Add-OfflineServicingWindowsDriver"
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Add-OfflineServicingWindowsDriver
        }
        #endregion

        #region Specialize Driver Pack installation
        if ($Global:OSDCloud.OSDCloudUnattend -eq $true) {
            Write-SectionHeader "Set Specialize Unattend.xml (Set-OSDCloudUnattendSpecialize)"
            Write-DarkGrayHost "C:\Windows\Panther\Invoke-OSDSpecialize.xml is being applied as an Unattend file"
            Write-DarkGrayHost "This will enable the extraction and installation of HP, Lenovo, and Microsoft Surface Drivers if necessary"
            if ($Global:OSDCloud.IsWinPE -eq $true) {
                if ($Global:OSDCloud.DevMode -eq $true){
                    Write-DarkGrayHost "Running in DEV Mode, running Set-OSDCloudUnattendSpecializeDEV instead"
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
                Write-SectionHeader "OSDCloud DriverPack Provisioning Package"
                Write-DarkGrayHost "This will enable the extraction and installation of HP, Dell, Lenovo, and Microsoft Surface Drivers"
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
    
    Write-SectionHeader "[i] Creating SetupComplete.cmd and SetupComplete.ps1"
    #Creates the SetupComplete.cmd & SetupComplete.ps1 files in C:\Windows\Setup\scripts
    #SetupComplete.cmd calls SetupComplete.ps1, which does all of the actual work
    Set-SetupCompleteCreateStart
    
    Write-DarkGrayHost "[i] Enable Wireless from Global Variable `$Global:OSDCloud.SetWiFi is set to $($Global:OSDCloud.SetWiFi)"
    if ($Global:OSDCloud.SetWiFi -eq $true) {
        $SetWiFi = $true
        Set-SetupCompleteSetWiFi
    }
    if ($Global:OSDCloud.IsWinPE -eq $true) {
        Write-DarkGrayHost "[i] Enable Windows Defender Update from Global Variable `$Global:OSDCloud.WindowsDefenderUpdate is set to $($Global:OSDCloud.WindowsDefenderUpdate)"
        if ($Global:OSDCloud.WindowsDefenderUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteDefenderUpdate
            }
            else {
                Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Defender Updates"
            }
        }
        Write-DarkGrayHost "[i] Enable Windows Update from Global Variable `$Global:OSDCloud.WindowsUpdate is set to $($Global:OSDCloud.WindowsUpdate)"
        if ($Global:OSDCloud.WindowsUpdate -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdate
            }
            else {
                Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Windows Updates"
            }
        }

        Write-DarkGrayHost "[i] Enable Windows Update Drivers from Global Variable `$Global:OSDCloud.WindowsUpdateDrivers is set to $($Global:OSDCloud.WindowsUpdateDrivers)"
        if ($Global:OSDCloud.WindowsUpdateDrivers -eq $true){
            if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                Set-SetupCompleteStartWindowsUpdateDriver
            }
            else {
                Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling Windows Update Driver Updates"
            }
        }
        
        Write-DarkGrayHost "[i] Enable DevMode from Global Variable `$Global:OSDCloud.DevMode is set to $($Global:OSDCloud.DevMode)"
        if ($Global:OSDCloud.DevMode -eq $true) {
            Write-DarkGrayHost "[i] Enable NetFx3 from Global Variable `$Global:OSDCloud.NetFx3 is set to $($Global:OSDCloud.NetFx3)"
            if ($Global:OSDCloud.NetFx3 -eq $true){
                if ($WebConnection -eq $True -or $SetWiFi -eq $True) {
                    Set-SetupCompleteNetFX
                }
                else {
                    Write-DarkGrayHost "No Internet or Future WiFi Configured, disabling NetFX Install"
                }
            }
        }
            
        Write-DarkGrayHost "[i] Enable Set TimeZone from Global Variable `$Global:OSDCloud.SetTimeZone is set to $($Global:OSDCloud.SetTimeZone)"
        if ($Global:OSDCloud.SetTimeZone -eq $true) {
            if ($WebConnection -eq $true) {
                Set-TimeZoneFromIP
            }
            else {
                Set-SetupCompleteTimeZone
            }
        }

        Write-DarkGrayHost "[i] Enable OEM Activation from Global Variable `$Global:OSDCloud.OEMActivation is set to $($Global:OSDCloud.OEMActivation)"
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
            Write-DarkGrayHost "Install Dell Command Update = $($Global:OSDCloud.DCUInstall) | Run DCU Drivers = $($Global:OSDCloud.DCUDrivers) | Run DCU Firmware = $($Global:OSDCloud.DCUFirmware)"
            Write-DarkGrayHost "Run DCU BIOS = $($Global:OSDCloud.DCUBIOS) | Enable DCU Auto Update = $($Global:OSDCloud.DCUAutoUpdateEnable) | DCU TPM Update = $($Global:OSDCloud.DellTPMUpdate) " 
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


                Write-SectionHeader "HP Enterprise Options Setup"
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
                    $HPSureAdminState = Get-HPSureAdminState -ErrorAction SilentlyContinue
                }
                catch{
                    Write-Host -ForegroundColor DarkGray "Unable to Test for HP Sure Admin State"
                }
                if ($HPSureAdminState) {$HPSureAdminMode = $HPSureAdminState.SureAdminMode}

                if ($Global:OSDCloud.HPTPMUpdate -eq $true){
                    if (Get-HPTPMDetermine -ne "True"){
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
                Write-DarkGrayHost "HPIA Drivers = $($Global:OSDCloud.HPIADrivers) | HPIA Firmware = $($Global:OSDCloud.HPIAFirmware) | HPIA Software = $($Global:OSDCloud.HPIADrivers) | HPIA All = $($Global:OSDCloud.HPIAAll) "
                Write-DarkGrayHost "HP TPM Update = $($Global:OSDCloud.HPTPMUpdate) | HP BIOS Update = $($Global:OSDCloud.HPBIOSUpdate) | HP BIOS WU Update = $HPBIOSWinUpdate" 

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

    Write-DarkGrayHost "[i] Enable Bitlocker from Global Variable `$Global:OSDCloud.Bitlocker is set to $($Global:OSDCloud.Bitlocker)"
    if ($Global:OSDCloud.Bitlocker -eq $true){
        Set-BitlockerRegValuesXTS256
        Set-SetupCompleteBitlocker
    }

    # HERE
    #endregion

    #region Post Image
        #region AutopilotConfigurationFile.json
        if ($Global:OSDCloud.AutopilotJsonObject) {
            Write-SectionHeader "Applying AutopilotConfigurationFile.json"
            Write-DarkGrayHost 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
            $Global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
        }
        #endregion

        #region SetupDisplayedEula
        Write-SectionHeader "Set SetupDisplayedEula Registry for TPM"
        Invoke-Exe reg load HKLM\TempSOFTWARE "C:\Windows\System32\Config\SOFTWARE"
        Invoke-Exe reg add HKLM\TempSOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE /v SetupDisplayedEula /t REG_DWORD /d 0x00000001 /f
        Invoke-Exe reg unload HKLM\TempSOFTWARE
        #endregion
    #endregion

    #region ----- OSDeploy.OOBEDeploy.json
    if ($Global:OSDCloud.OOBEDeployJsonObject) {
        Write-SectionHeader "Applying OSDeploy.OOBEDeploy.json"
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
        Write-SectionHeader "Applying OSDeploy.AutopilotOOBE.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion

    #region Pre-End Deployment
        #region Stage Office Config
        <#
        This region was added to enble installing Office in the Specialize phase
        It is probably not recommended to run this section, just showing that it is possible
        Recommended to remove this region by end of 2022
        David Segura
        #>
        if ($Global:OSDCloud.ODTFile) {
            Write-SectionHeader "Stage Office Config"

            if (!(Test-Path $Global:OSDCloud.ODTTarget)) {
                New-Item -Path $Global:OSDCloud.ODTTarget -ItemType Directory -Force | Out-Null
            }

            if (Test-Path $Global:OSDCloud.ODTFile.FullName) {
                Copy-Item -Path $Global:OSDCloud.ODTFile.FullName -Destination $Global:OSDCloud.ODTConfigFile -Force
            }

            $Global:OSDCloud.ODTSetupFile = Join-Path $Global:OSDCloud.ODTFile.Directory 'setup.exe'
            Write-Verbose -Verbose "ODTSetupFile: $($Global:OSDCloud.ODTSetupFile)"
            if (Test-Path $Global:OSDCloud.ODTSetupFile) {
                Copy-Item -Path $Global:OSDCloud.ODTSetupFile -Destination $Global:OSDCloud.ODTTarget -Force
            }

            $Global:OSDCloud.ODTSource = Join-Path $Global:OSDCloud.ODTFile.Directory 'Office'
            Write-Verbose -Verbose "ODTSource: $($Global:OSDCloud.ODTSource)"
            if (Test-Path $Global:OSDCloud.ODTSource) {
                Invoke-Exe robocopy "$($Global:OSDCloud.ODTSource)" "$($Global:OSDCloud.ODTTargetData)" *.* /s /ndl /nfl /z /b
            }
        }
        #endregion

        #region Export OS Information
        <#
        The goal of this section is to export TXT files that contain information about the deployed Operating System
        This information can then be reviewed after deployment in C:\OSDCloud\Logs
        You can use this information to write scripts to remove AppxProvisionedPackage, or perform other tasks
        
        This region has no dependencies with anything else in OSDCloud and can be removed if needed
        David Segura
        #>
        #Grab Build from WinPE, as 24H2 has issues with some of these commands:
        $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $CurrentOSBuild = $($CurrentOSInfo.GetValue('CurrentBuild'))

        if (Get-Command Get-AppxProvisionedPackage -ErrorAction Ignore) {
            Write-SectionHeader "Export Operating System Information"

            Write-DarkGrayHost 'Export WinPE PowerShell Commands to C:\OSDCloud\Logs\Get-CommandWinPE.txt'
            $Report = Get-Command -ErrorAction Ignore | Where-Object {($_.CommandType -eq 'Cmdlet') -or ($_.CommandType -eq 'Function')} | Where-Object {$_.ModuleName -gt 0} | Sort-Object ModuleName, Name, Version
            $Report | Select-Object ModuleName, Name, Version | Out-File -FilePath 'C:\OSDCloud\Logs\Get-CommandWinPE.txt' -Force -Encoding ascii

            if (Get-Command Get-AppxProvisionedPackage) {
                Write-DarkGrayHost 'Export Appx Provisioned Packages to C:\OSDCloud\Logs\Get-AppxProvisionedPackage.txt'
                $Report = Get-AppxProvisionedPackage -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object DisplayName
                $Report | Select-Object DisplayName | Out-File -FilePath 'C:\OSDCloud\Logs\Get-AppxProvisionedPackage.txt' -Force -Encoding ascii
            }

            if (Get-Command Get-WindowsCapability) {
                Write-DarkGrayHost 'Export Windows Capability to C:\OSDCloud\Logs\Get-WindowsCapability.txt'
                if ($CurrentOSBuild -eq "26100"){
                    $ArgumentList = "/Image=C:\ /Get-Capabilities"
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput 'C:\OSDCloud\Logs\Get-WindowsCapability.txt'
                }
                else {
                    $Report = Get-WindowsCapability -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object Name
                    $Report | Select-Object Name, State | Out-File -FilePath 'C:\OSDCloud\Logs\Get-WindowsCapability.txt' -Force -Encoding ascii
                }
            }

            if (Get-Command Get-WindowsEdition) {
                Write-DarkGrayHost 'Export Windows Edition to C:\OSDCloud\Logs\Get-WindowsEdition.txt'
                $Report = Get-WindowsEdition -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object Edition
                $Report | Select-Object Edition | Out-File -FilePath 'C:\OSDCloud\Logs\Get-WindowsEdition.txt' -Force -Encoding ascii
            }

            if (Get-Command Get-WindowsOptionalFeature) {
                Write-DarkGrayHost 'Export Windows Optional Features to C:\OSDCloud\Logs\Get-WindowsOptionalFeature.txt'
                $Report = Get-WindowsOptionalFeature -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object FeatureName
                $Report | Select-Object FeatureName, State | Out-File -FilePath 'C:\OSDCloud\Logs\Get-WindowsOptionalFeature.txt' -Force -Encoding ascii
            }

            if (Get-Command Get-WindowsPackage) {
                Write-DarkGrayHost 'Export Windows Packages to C:\OSDCloud\Logs\Get-WindowsPackage.txt'
                if ($CurrentOSBuild -eq "26100"){
                    $ArgumentList = "/Image=C:\ /Get-Packages"
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput 'C:\OSDCloud\Logs\Get-WindowsPackage.txt'
                }
                else {
                    $Report = Get-WindowsPackage -Path C:\ -ErrorAction Ignore | Select-Object * | Sort-Object PackageName
                    $Report | Select-Object PackageName, PackageState, ReleaseType | Out-File -FilePath 'C:\OSDCloud\Logs\Get-WindowsPackage.txt' -Force -Encoding ascii
                }
            }
        }
        #endregion

        #region Save-Module
        Write-SectionHeader "Saving PowerShell Modules and Scripts"
        if ($Global:OSDCloud.IsWinPE -eq $true) {
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
                Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"

                try {
                    Save-Module -Name OSD -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Module OSD to $PowerShellSavePath\Modules"
                }

                try {
                    Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Module PackageManagement to $PowerShellSavePath\Modules"
                }

                try {
                    Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Module PowerShellGet to $PowerShellSavePath\Modules"
                }

                try {
                    Save-Module -Name WindowsAutopilotIntune -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Module WindowsAutopilotIntune to $PowerShellSavePath\Modules"
                }

                try {
                    Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellSavePath\Scripts" -ErrorAction Stop
                }
                catch {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Script Get-WindowsAutopilotInfo to $PowerShellSavePath\Scripts"
                }
                if ($HPFeaturesEnabled) {
                    try {
                        Save-Module -Name HPCMSL -AcceptLicense -Path "$PowerShellSavePath\Modules" -Force -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to Save-Module HPCMSL to $PowerShellSavePath\Modules"
                    }
                }
            }
            else {
                Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to $PowerShellSavePath\Modules"
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
    #endregion
 
    #region Gary Blok Debug and Dev Mode
    if ($WebConnection -eq $True){
        if ($Global:OSDCloud.DebugMode -eq $true){
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
    Set-SetupCompleteCreateFinish
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
            Write-DarkGrayHost "Execute $($Item.FullName)"
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
            Write-DarkGrayHost "$($Item.FullName)"
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
            Write-DarkGrayHost "dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
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
                Write-DarkGrayHost "dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
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
            Write-DarkGrayHost "Execute $($Item.FullName)"
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
            Write-DarkGrayHost "$($Item.FullName)"
            & "Execute $($Item.FullName)"
        }
    }
    #endregion

    #region Complete
    Write-SectionHeader "OSDCloud Finished"
    $Global:OSDCloud.TimeEnd = Get-Date
    $Global:OSDCloud.TimeSpan = New-TimeSpan -Start $Global:OSDCloud.TimeStart -End $Global:OSDCloud.TimeEnd
    $Global:OSDCloud | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\OSDCloud.json' -Encoding ascii -Width 2000 -Force
    if (Test-Path x:\windows\logs\DISM\dism.log){
        Copy-Item -Path x:\windows\logs\DISM\dism.log -Destination C:\OSDCloud\Logs\DISM-WinPE.log
    }
    Write-DarkGrayHost "Completed in $($Global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))"

    if ($Global:OSDCloud.Screenshot) {
        Start-Sleep -Seconds 5
        Stop-ScreenPNGProcess
        Write-DarkGrayHost "Screenshots: $($Global:OSDCloud.Screenshot)"
    }

    if ($Global:OSDCloud.Restart) {
        Write-Warning "WinPE is restarting in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Restart-Computer
        }
    }

    if ($Global:OSDCloud.Shutdown) {
        Write-Warning "WinPE will shutdown in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
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
