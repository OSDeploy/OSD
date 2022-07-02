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
    #=================================================
    #region Master Parameters
    $Global:OSDCloud = $null
    $Global:OSDCloud = [ordered]@{
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
        AzOSDCloudBlobImage = $Global:AzOSDCloudBlobImage
        AzOSDCloudBlobDriverPack = $Global:AzOSDCloudBlobDriverPack
        AzOSDCloudBlobPackage = $Global:AzOSDCloudBlobPackage
        AzOSDCloudDriverPack = $null
        AzOSDCloudImage = $Global:AzOSDCloudImage
        AzOSDCloudPackage = $null
        AzStorageAccounts = $Global:AzStorageAccounts
        AzStorageContext = $Global:AzStorageContext
        BuildName = 'OSDCloud'
        ClearDiskConfirm = [bool]$true
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
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileDestination = $null
        ImageFileUrl = $null
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
        OSBuild = $null
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $null
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSImageIndex = 1
        OSLanguage = $null
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSLicense = $null
        OSVersion = 'Windows 10'
        Product = Get-MyComputerProduct
        Restart = [bool]$false
        ScreenshotCapture = $false
        ScreenshotPath = "$env:TEMP\Screenshots"
        SectionPassed = $true
        Shutdown = [bool]$false
        SkipAllDiskSteps = [bool]$false
        SkipAutopilot = [bool]$false
        SkipAutopilotOOBE = [bool]$false
        SkipClearDisk = [bool]$false
        SkipODT = [bool]$false
        SkipOOBEDeploy = [bool]$false
        SkipNewOSDisk = [bool]$false
        SkipRecoveryPartition = [bool]$false
        RecoveryPartition = $null
        TimeEnd = $null
        TimeSpan = $null
        TimeStart = Get-Date
        Transcript = $null
        USBPartitions = $null
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        WindowsDefenderUpdate  = $true
        WindowsImage = $null
        WindowsImageCount = $null
        ZTI = [bool]$false
    }
    #endregion
    #=================================================
    #region Set Pre-Merge Defaults
    if ($Global:OSDCloud.IsVirtualMachine) {
        $Global:OSDCloud.SkipRecoveryPartition = $true
    }
    #endregion
    #=================================================
    #region Merge Parameters
    if ($Global:StartOSDCloud) {
        foreach ($Key in $Global:StartOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:StartOSDCloud.$Key
        }
    }
    if ($Global:MyOSDCloud) {
        foreach ($Key in $Global:MyOSDCloud.Keys) {
            $Global:OSDCloud.$Key = $Global:MyOSDCloud.$Key
        }
    }
    #endregion





    #=================================================
    #region Helper Functions
    function Write-DarkGrayDate {
        [CmdletBinding()]
        param (
            [Parameter(Position=0)]
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
            [Parameter(Mandatory=$true, Position=0)]
            [System.String]
            $Message
        )
        Write-Host -ForegroundColor DarkGray $Message
    }
    function Write-DarkGrayLine {
        [CmdletBinding()]
        param ()
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    function Write-SectionHeader {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true, Position=0)]
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
            [Parameter(Position=0)]
            [System.String]
            $Message = 'Success!'
        )
        Write-DarkGrayDate
        Write-Host -ForegroundColor Green $Message
    }
    #endregion


        #=================================================
    #region Debug Mode
    if ($Global:OSDCloud.DebugMode -eq $true){
        Write-SectionHeader "DebugMode Write OSDCloud Vars"
        Write-DarkGrayHost "Writing OSDCloud Variables to $($env:temp)\OSDCloudVars.log"
        $OSDCloud | Out-File $env:temp\OSDCloudVars.log
    }
    #endregion
    #=================================================


    #=================================================
    #region Set Post-Merge Defaults
    $Global:OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($Global:OSDCloud.RecoveryPartition -eq $true) {
        $Global:OSDCloud.SkipRecoveryPartition = [bool]$false
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
    #=================================================
    #region OSDCloud Logs
    Write-SectionHeader 'OSDCloud Logs'

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
    #=================================================
    #region Fixed Disks
    Write-SectionHeader 'Validate Fixed Disks'

    $Global:OSDCloud.SectionPassed = $false

    $Global:OSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

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
    #=================================================
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
    #=================================================
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
    #=================================================
    #region Office Configuration
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
    #=================================================
    #region Require WinPE
    Write-SectionHeader "Validate WinPE"

    if ($Global:OSDCloud.IsWinPE -eq $false) {
        Write-Warning "OSDCloud can only be run from WinPE"
        Write-Warning "OSDCloud is running in Test mode"
        Start-Sleep -Seconds 5
    }
    #endregion
    #=================================================
    #region Remove USB Partition Access Path
    <#
    https://docs.microsoft.com/en-us/powershell/module/storage/remove-partitionaccesspath
    Partition Access Paths are being removed from USB Drive Letters
    This prevents issues when Drive Letters are reassigned
    #>
    $Global:OSDCloud.USBPartitions = Get-Partition.usb
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
    #=================================================
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
            Clear-Disk.fixed -Force -NoResults -ErrorAction Stop
        }
        else {
            Write-DarkGrayHost '$OSDCloud.ClearDiskConfirm = $false'
            Clear-Disk.fixed -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    #endregion
    #=================================================
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
        if ($Global:OSDCloud.SkipRecoveryPartition -eq $true) {
            New-OSDisk -PartitionStyle GPT -NoRecoveryPartition -Force -ErrorAction Stop
            Write-Host "=========================================================================" -ForegroundColor Cyan
            Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
            Write-Host "=========================================================================" -ForegroundColor Cyan
        }
        else {
            New-OSDisk -PartitionStyle GPT -Force -ErrorAction Stop
            Write-Host "=========================================================================" -ForegroundColor Cyan
            Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
            Write-Host "=========================================================================" -ForegroundColor Cyan
            #Wait a few seconds to make sure the Disk is set
            Start-Sleep -Seconds 5
        }

        #Make sure that there is a PSDrive 
        if (-NOT (Get-PSDrive -Name 'C')) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
            Write-Warning "New-OSDisk didn't work. There is no PSDrive FileSystem at C:\"
            Write-Warning "Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
    }
    #endregion
    #=================================================
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
    #=================================================
    #region ScreenshotCapture
    if ($Global:OSDCloud.ScreenshotCapture) {
        Write-SectionHeader "Moving Screenshots to C:\OSDCloud\Screenshots"
        Write-Verbose -Message "https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy"
        Stop-ScreenPNGProcess
        Invoke-Exe robocopy "$($Global:OSDCloud.ScreenshotPath)" C:\OSDCloud\Screenshots *.* /s /ndl /nfl /njh /njs
        Start-ScreenPNGProcess -Directory 'C:\OSDCloud\Screenshots'
        $Global:OSDCloud.ScreenshotPath = 'C:\OSDCloud\Screenshots'
    }
    #endregion
    #=================================================
    #region Transcript
    Write-SectionHeader "Saving PowerShell Transcript to C:\OSDCloud\Logs"

    Write-Verbose -Message "https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    
    $Global:OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $Global:OSDCloud.Transcript) -ErrorAction Ignore
    #endregion
    #=================================================
    #region Performance Final
    #https://docs.microsoft.com/en-us/windows/win32/power/power-policy-settings
    Write-SectionHeader "Powercfg High Performance"

    if ($Global:OSDCloud.IsOnBattery -eq $true) {
        Write-DarkGrayHost "Device is on battery power. Performance will not be adjusted"
    }
    elseif ($Global:OSDCloud.IsWinPE -eq $false) {
        Write-DarkGrayHost "Device is not running in WinPE. Performance will not be adjusted"
    }
    elseif ($Global:OSDCloud.Debug -eq $true) {
        Write-DarkGrayHost "Device is running in debug mode. Performance will not be adjusted"
    }
    else {
        Write-DarkGrayHost "Enable powercfg High Performance"
        Invoke-Exe powercfg.exe -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    #endregion
    #=================================================
    #region Image File Offline
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
            Copy-Item -Path $Global:OSDCloud.ImageFileSource.FullName -Destination 'C:\OSDCloud\OS' -Force
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
    #=================================================
    #region Get Image File
    if ($Global:OSDCloud.AzOSDCloudImage) {
        #AzOSDCloud
    }
    elseif (!($Global:OSDCloud.ImageFileDestination) -and (!($Global:OSDCloud.ImageFileUrl))) {
        Write-SectionHeader "Get-FeatureUpdate"
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
    #=================================================
    #region Azure Storage Windows Image Download
    if ($Global:OSDCloud.AzOSDCloudImage) {
        Write-SectionHeader "OSDCloud Azure Storage Windows Image Download"

        $Global:OSDCloud.DownloadDirectory = "C:\OSDCloud\Azure\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.AccountName)\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.BlobContainerName)"
        $Global:OSDCloud.DownloadName = $(Split-Path $Global:OSDCloud.AzOSDCloudImage.Name -Leaf)
        $Global:OSDCloud.DownloadFullName = "$($Global:OSDCloud.DownloadDirectory)\$($Global:OSDCloud.DownloadName)"

        #Export Image Information
        $Global:OSDCloud.AzOSDCloudImage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudImage.json" -Encoding ascii -Width 2000

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
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }
        else {
            if (-not (Test-Path "$($Global:OSDCloud.DownloadDirectory)")) {
                Write-DarkGrayHost -Message "Creating directory $($Global:OSDCloud.DownloadDirectory)"
                $null = New-Item @ParamNewItem
            }
            Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
        }
        
        $Global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1
    }
    #endregion
    #=================================================
    #region Image Download
    if (!($Global:OSDCloud.ImageFileDestination) -and ($Global:OSDCloud.ImageFileUrl)) {
        Write-SectionHeader "Download Operating System"
        Write-DarkGrayHost "$($Global:OSDCloud.ImageFileUrl)"

        $null = New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Ignore

        if (Test-WebConnection -Uri $Global:OSDCloud.ImageFileUrl) {
            if ($Global:OSDCloud.ImageFileName) {
                #=================================================
                #	Cache to USB
                #=================================================
                $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Where-Object {$_.SizeRemainingGB -ge 5} | Select-Object -First 1
                
                if ($OSDCloudUSB -and $Global:OSDCloud.OSVersion -and $Global:OSDCloud.OSBuild) {
                    $OSDownloadChildPath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\OS\$($Global:OSDCloud.OSVersion) $($Global:OSDCloud.OSBuild)"
                    Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Downloading to OSDCloudUSB at $OSDownloadChildPath"

                    $OSDCloudUsbOS = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory "$OSDownloadChildPath" -DestinationName $Global:OSDCloud.ImageFileName

                    if ($OSDCloudUsbOS) {
                        Write-SectionHeader "Copying Operating System to C:\OSDCloud\OS\$($OSDCloudUsbOS.Name)"
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
    #=================================================
    #region ImageFileDestination
    if (-not ($Global:OSDCloud.ImageFileDestination)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
        Write-Warning "The Windows Image Source did not download properly to the Destination"
        Write-Warning "Press Ctrl+C to exit"
        Start-Sleep -Seconds 86400
        Exit
    }
    #endregion
    #=================================================
    #region ISO Image File
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
    #=================================================
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
            if (($OSLicense -eq 'Retail') -and ($Global:OSDCloud.WindowsImageCount -eq 9)) {
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
    #=================================================
    #region Expand-WindowsImage
    Write-SectionHeader "Expand-WindowsImage"

    #Expand-WindowsImage
    Write-DarkGrayHost "ApplyPath: 'C:\'"
    Write-DarkGrayHost "ImagePath: $($Global:OSDCloud.ImageFileDestination.FullName)"
    Write-DarkGrayHost "Index: $($Global:OSDCloud.OSImageIndex)"
    Write-DarkGrayHost "ScratchDirectory: 'C:\OSDCloud\Temp'"

    #Scratch Directory
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

    #Expand-WindowsImage Params
    $ExpandWindowsImage = @{
        ApplyPath = 'C:\'
        ImagePath = $Global:OSDCloud.ImageFileDestination.FullName
        Index = $Global:OSDCloud.OSImageIndex
        ScratchDirectory = 'C:\OSDCloud\Temp'
        ErrorAction = 'Stop'
    }
    $Global:OSDCloud.ExpandWindowsImage = $ExpandWindowsImage

    if ($Global:OSDCloud.IsWinPE -eq $true) {
        Expand-WindowsImage @ExpandWindowsImage

        $SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
        if (-NOT (Get-PSDrive -Name S)) {
            $SystemDrive | Set-Partition -NewDriveLetter 'S'
        }
        bcdboot C:\Windows /s S: /f ALL
        Start-Sleep -Seconds 10
        $SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
    }
    #endregion
    #=================================================
    #region Get-WindowsEdition
    Write-SectionHeader 'Get-WindowsEdition'
    Get-WindowsEdition -Path 'C:\' | Out-Host
    #endregion
    #=================================================
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
    #=================================================
    #region Packages
    Write-SectionHeader 'OSDCloud Azure Container as a Task Sequence'
    if ($Global:OSDCloud.AzOSDCloudPackage) {
        foreach ($Item in $Global:OSDCloud.AzOSDCloudPackage) {
            $ParamGetAzStorageBlobContent = @{
                CloudBlob = $Item.ICloudBlob
                Context = $Item.Context
                Destination = 'C:\OSDCloud\Packages\'
                Force = $true
                ErrorAction = 'Stop'
            }
            $null = Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
        }

        $Packages = Get-ChildItem -Path 'C:\OSDCloud\Packages\' *.ppkg -Recurse -ErrorAction Ignore
        foreach ($Item in $Packages) {
            Write-DarkGrayHost "Add-ProvisioningPackage $($Item.FullName)"
            $Dism = "dism.exe"
            $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:$($Item.FullName)"
            $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
        }
    }
    #endregion
    #=================================================
    #region Validate OSDCloud Driver Pack
    Write-SectionHeader "OSDCloud DriverPack"
    if ($Global:OSDCloud.DriverPackName) {
        if ($Global:OSDCloud.DriverPackName -match 'None') {
            Write-DarkGrayHost "DriverPack is set to None"
            $Global:OSDCloud.DriverPack = $null
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
        $Global:OSDCloud.DriverPack = Get-OSDCloudDriverPack | Select-Object -First 1
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
            $Global:OSDCloud.AzOSDCloudDriverPack | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudDriverPack.json" -Encoding ascii -Width 2000
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
        $Global:OSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $Global:OSDCloud.DriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
        $Global:OSDCloud.DriverPackOffline = $Global:OSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1
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
        elseif ($Global:OSDCloud.AzOSDCloudDriverPack) {
            Write-DarkGrayHost "DriverPack is being downloaded from Azure Storage to C:\Drivers"
            Get-AzStorageBlobContent -CloudBlob $Global:OSDCloud.AzOSDCloudDriverPack.ICloudBlob -Context $Global:OSDCloud.AzOSDCloudDriverPack.Context -Destination "C:\Drivers\$(Split-Path $Global:OSDCloud.AzOSDCloudDriverPack.Name -Leaf)"
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
            }
        }

        if ($SaveMyDriverPack) {
            if (-not ($Global:OSDCloud.DriverPackSource)) {
                #=================================================
                #	Cache to OSDCloudUSB
                #=================================================
                $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Where-Object {$_.SizeRemainingGB -ge 2} | Select-Object -First 1
                if ($OSDCloudUSB) {
                    $OSDCloudUSBDestination = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\$($Global:OSDCloud.Manufacturer)"
                    Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying Driver Pack to OSDCloudUSB at $OSDCloudUSBDestination"
                    If (! (Test-Path $OSDCloudUSBDestination)) {
                        $null = New-Item -Path $OSDCloudUSBDestination -ItemType Directory -Force
                    }
                    $null = Copy-Item -Path $SaveMyDriverPack.FullName -Destination $OSDCloudUSBDestination -Force -PassThru -ErrorAction Stop
                }
            }
        }
    }
    #endregion
    #=================================================
    #region MSCatalogFirmware Final
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
    #=================================================
    #region MSCatalogDrivers Final
    Write-SectionHeader "Microsoft Update Catalog Drivers"

    if ($Global:OSDCloud.DriverPackName -eq 'None') {
        Write-DarkGrayHost "Drivers from Microsoft Update Catalog will not be applied for this deployment"
    }
    else {
        if (Test-MicrosoftUpdateCatalog) {
            if ($Global:OSDCloud.DriverPackName -eq 'Microsoft Update Catalog') {
                Write-DarkGrayHost "Drivers for all devices will be downloaded from Microsoft Update Catalog to C:\Drivers"
                Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'
            }
            elseif ($null -eq $SaveMyDriverPack) {
                Write-DarkGrayHost "Drivers for all devices will be downloaded from Microsoft Update Catalog to C:\Drivers"
                Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'
            }
            else {
                if ($OSDCloud.MSCatalogDiskDrivers) {
                    Write-DarkGrayHost "Drivers for PNPClass DiskDrive will be downloaded from Microsoft Update Catalog to C:\Drivers"
                    Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'DiskDrive'
                }
                if ($OSDCloud.MSCatalogNetDrivers) {
                    Write-DarkGrayHost "Drivers for PNPClass Net will be downloaded from Microsoft Update Catalog to C:\Drivers"
                    Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'
                }
                if ($OSDCloud.MSCatalogScsiDrivers) {
                    Write-DarkGrayHost "Drivers for PNPClass SCSIAdapter will be downloaded from Microsoft Update Catalog to C:\Drivers"
                    Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'SCSIAdapter'
                }
            }
        }
    }
    #endregion
    <# - Found that when you update Defender Offline... it hangs specialize phase... no idea why
    #=================================================
    #region osdcloud-WinpeUpdateDefender
    Write-SectionHeader "Updates Windows Defender Offline (osdcloud-WinpeUpdateDefender)"
    Write-DarkGrayHost "Defender Platform & Defs are being updated in Offline Image"
    Write-DarkGrayHost "This process can take up to 5 minutes"
    Write-Verbose -Message "osdcloud-WinpeUpdateDefender "
    if ($Global:OSDCloud.IsWinPE -eq $true) {
        if ($Global:OSDCloud.WindowsDefenderUpdate -eq $true){
            osdcloud-WinpeUpdateDefender 
        }
    }
    #endregion
    #>
    #=================================================
    #region Set-OSDCloudUnattendSpecialize
    Write-SectionHeader "Set Specialize Unattend.xml (Set-OSDCloudUnattendSpecialize)"
    Write-DarkGrayHost "C:\Windows\Panther\Invoke-OSDSpecialize.xml is being applied as an Unattend file"
    Write-DarkGrayHost "This will enable the extraction and installation of HP, Lenovo, and Microsoft Surface Drivers if necessary"
    Write-Verbose -Message "Set-OSDCloudUnattendSpecialize"
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
    #endregion
    
    #=================================================
    #region Create SetupComplete Files.
    if ($Global:OSDCloud.DevMode -eq $true){
        Write-SectionHeader "Creating SetupComplete Files and populating with requested tasks."
    
        osdcloud-SetupCompleteCreateStart

        if ($Global:OSDCloud.IsWinPE -eq $true) {
            if ($Global:OSDCloud.WindowsDefenderUpdate -eq $true){
                osdcloud-SetupCompleteDefenderUpdate
            }
        }
        #endregion

        #=================================================
        #region HyperV Config for Specialize Phase
        if (($Global:OSDCloud.HyperVSetName -eq $true) -or ($Global:OSDCloud.HyperVEjectISO -eq $true) ){
            Write-DarkGrayHost "Starting HyperV Modifications"
            if ($Global:OSDCloud.HyperVSetName -eq $true){
                Write-DarkGrayHost "Adding HyperV Tasks into JSON Config File for Action during Specialize" 
                $HashTable = @{
                    'Updates' = @{
                        'HyperVSetName' = $Global:OSDCloud.HyperVSetName                   
                    }
                }
                $HashVar = $HashTable | ConvertTo-Json
                $ConfigPath = "c:\osdcloud\configs"
                $ConfigFile = "$ConfigPath\HYPERV.JSON"
                try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
                catch {}
                $HashVar | Out-File $ConfigFile

                #Leverage SetupComplete.cmd to run HP Tools
                Write-DarkGrayHost "HyperV Set Computer Name = $($Global:OSDCloud.HyperVSetName)"
                Write-DarkGrayHost "Adding Function to Rename Computer to HyperV VM Name into SetupComplete"
                osdcloud-HyperVSetupComplete
            }        
            if ($Global:OSDCloud.HyperVEjectISO -eq $true){
                Write-DarkGrayHost "Ejecting ISO from VM"
                osdcloud-EjectCD
            }
        }

        #endregion
        
        
        #=================================================
        #region Dell Updates Config for Specialize Phase
        if (($Global:OSDCloud.DCUInstall -eq $true) -or ($Global:OSDCloud.DCUDrivers -eq $true) -or ($Global:OSDCloud.DCUFirmware -eq $true) -or ($Global:OSDCloud.DCUBIOS -eq $true) -or ($Global:OSDCloud.DCUAutoUpdateEnable -eq $true) -or ($Global:OSDCloud.DellTPMUpdate -eq $true)){
            $DellFeaturesEnabled = $true
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

        #endregion

        #=================================================
        #region HP Updates Config for Specialize Phase
        #Set Specialize JSON
        if (($Global:OSDCloud.HPIAAll -eq $true) -or ($Global:OSDCloud.HPIADrivers -eq $true) -or ($Global:OSDCloud.HPIAFirmware -eq $true) -or ($Global:OSDCloud.HPIASoftware -eq $true) -or ($Global:OSDCloud.HPTPMUpdate -eq $true) -or ($Global:OSDCloud.HPBIOSUpdate -eq $true)){
            Write-SectionHeader "HP Enterprise Options Setup"
            $HPFeaturesEnabled = $true
            Write-Host -ForegroundColor DarkGray "Adding HP Tasks into JSON Config File for Action during Specialize"
            Write-DarkGrayHost "HPIA Drivers = $($Global:OSDCloud.HPIADrivers) | HPIA Firmware = $($Global:OSDCloud.HPIAFirmware) | HPIA Software = $($Global:OSDCloud.HPIADrivers) | HPIA All = $($Global:OSDCloud.HPIAAll) "
            Write-DarkGrayHost "HP TPM Update = $($Global:OSDCloud.HPTPMUpdate) | HP BIOS Update = $($Global:OSDCloud.HPBIOSUpdate)" 
            $HPHashTable = @{
                'HPUpdates' = @{
                    'HPIADrivers' = $Global:OSDCloud.HPIADrivers
                    'HPIAFirmware' = $Global:OSDCloud.HPIAFirmware
                    'HPIASoftware' = $Global:OSDCloud.HPIASoftware
                    'HPIAAll' = $Global:OSDCloud.HPIAALL
                    'HPTPMUpdate' = $Global:OSDCloud.HPTPMUpdate
                    'HPBIOSUpdate' = $Global:OSDCloud.HPBIOSUpdate
                }
            }
            $HPHashVar = $HPHashTable | ConvertTo-Json
            $ConfigPath = "c:\osdcloud\configs"
            $ConfigFile = "$ConfigPath\HP.JSON"
            try {[void][System.IO.Directory]::CreateDirectory($ConfigPath)}
            catch {}
            $HPHashVar | Out-File $ConfigFile
            osdcloud-HPIADownload
            
            #Stage HP TPM Update EXE
            if ($Global:OSDCloud.HPTPMUpdate -eq $true){
                osdcloud-HPTPMBIOSSettings
                osdcloud-HPTPMEXEDownload
            }   


            #Leverage SetupComplete.cmd to run HP Tools
            osdcloud-HPSetupCompleteAppend
        }
    }
    #endregion
    #=================================================
    #region AutopilotConfigurationFile.json
    if ($Global:OSDCloud.AutopilotJsonObject) {
        Write-SectionHeader "Applying AutopilotConfigurationFile.json"
        Write-DarkGrayHost 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        $Global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion
    #=================================================
    #region OSDeploy.OOBEDeploy.json
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
start "Install-Module OSD" /wait PowerShell -NoL -C Install-Module OSD -Force -Verbose

:: Start-OOBEDeploy
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json
start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy

exit
'@
        $SetCommand | Out-File -FilePath "C:\Windows\OOBEDeploy.cmd" -Encoding ascii -Width 2000 -Force
    }
    #endregion
    #=================================================
    #region OSDeploy.AutopilotOOBE.json
    if ($Global:OSDCloud.AutopilotOOBEJsonObject) {
        Write-SectionHeader "Applying OSDeploy.AutopilotOOBE.json"
        Write-DarkGrayHost 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #endregion
    #=================================================
    #region Stage Office Config
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
    #=================================================
    #region Save PowerShell Modules to OSDisk
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
            if ($HPFeaturesEnabled){
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
            if ($HPFeaturesEnabled){Copy-PSModuleToFolder -Name HPCMSL -Destination "$PowerShellSavePath\Modules"}
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
    #=================================================
    #region Debug & Dev Mode
    if ($Global:OSDCloud.DebugMode -eq $true){
        Write-SectionHeader "DebugMode Enabled"
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
        osdcloud-addcmtrace
        osdcloud-addmouseoobe
        osdcloud-UpdateModuleFilesManually
        #osdcloud-WinpeUpdateDefender
    }
    if ($Global:OSDCloud.DevMode -eq $true){
        Write-SectionHeader "DevMode Enabled"
        if ($Global:OSDCloud.DebugMode -eq $true){
            osdcloud-UpdateModuleFilesManually -DEVMode $true
        }
        else{
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
            osdcloud-addcmtrace
            osdcloud-addmouseoobe
            osdcloud-UpdateModuleFilesManually -DEVMode $true
            #osdcloud-WinpeUpdateDefender
        }

    }
    #endregion
    #=================================================
    #region Finish SetupComplete Files.
    #This appends the two lines at the end of SetupComplete Script to Stop Transcription and to Restart Computer
    if ($Global:OSDCloud.DevMode -eq $true){
        osdcloud-SetupCompleteCreateFinish
    }
    #endregion
    #=================================================
    #region Deploy-OSDCloud Complete
    $Global:OSDCloud.TimeEnd = Get-Date
    $Global:OSDCloud.TimeSpan = New-TimeSpan -Start $Global:OSDCloud.TimeStart -End $Global:OSDCloud.TimeEnd
    
    $Global:OSDCloud | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\OSDCloud.json' -Encoding ascii -Width 2000 -Force
    Write-SectionHeader "OSDCloud Finished"
    Write-DarkGrayHost "Completed in $($Global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #endregion
    #=================================================
    if ($Global:OSDCloud.Screenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-DarkGrayHost "Screenshots: $($Global:OSDCloud.Screenshot)"
    }
    #=================================================
    if ($Global:OSDCloud.Restart) {
        Write-Warning "WinPE is restarting in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Restart-Computer
        }
    }
    #=================================================
    if ($Global:OSDCloud.Shutdown) {
        Write-Warning "WinPE will shutdown in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.IsWinPE -eq $true) {
            Stop-Computer
        }
    }
    #=================================================
    #	Stop-Transcript
    #=================================================
    if ($OSDCloud.Test -eq $true) {
        Stop-Transcript
    }
    #=================================================
}
