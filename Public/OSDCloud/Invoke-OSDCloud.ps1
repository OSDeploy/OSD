function Invoke-OSDCloud {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Create Hashtable
    #=======================================================================
    $Global:OSDCloud = $null
    $Global:OSDCloud = [ordered]@{
        AutopilotFile = $null
        AutopilotFiles = $null
        AutopilotJsonName = $null
        AutopilotJsonString = $null
        AutopilotJsonUrl = $null
        AutopilotObject = $null
        BuildName = 'OSDCloud'
        DriverPackUrl = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        ImageFileOffline = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileTarget = $null
        ImageFileUrl = $null
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = Get-MyComputerManufacturer -Brief
        ODTConfigFile = 'C:\OSDCloud\ODT\Config.xml'
        ODTFile = $null
        ODTFiles = $null
        ODTSetupFile = $null
        ODTSource = $null
        ODTTarget = 'C:\OSDCloud\ODT'
        ODTTargetData = 'C:\OSDCloud\ODT\Office'
        OSBuild = $OSBuild
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSLicense = $null
        OSImageIndex = 1
        Product = Get-MyComputerProduct
        ProvPackages = $null
        Screenshot = $null
        SkipAutopilot = [bool]$false
        SkipODT = [bool]$false
        SkipProvPackage = [bool]$false
        Test = [bool]$false
        TimeEnd = $null
        TimeSpan = $null
        TimeStart = Get-Date
        Transcript = $null
        USBPartitions = $null
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        VersionMin = [Version]'21.4.23.1'
        ZTI = [bool]$false
    }
    #=======================================================================
    #	Merge Hashtables
    #=======================================================================
    if ($StartOSDCloud) {
        foreach ($Key in $StartOSDCloud.Keys) {
            $OSDCloud.$Key = $StartOSDCloud.$Key
        }
    }
    if ($MyOSDCloud) {
        foreach ($Key in $MyOSDCloud.Keys) {
            $OSDCloud.$Key = $MyOSDCloud.$Key
        }
    }
    #=======================================================================
    #   VERSIONING
    #   Scripts/Test-OSDModule.ps1
    #   OSD Module Minimum Version
    #   Since the OSD Module is doing much of the heavy lifting, it is important to ensure that old
    #   OSD Module versions are not used long term as the OSDCloud script can change
    #   This example allows you to control the Minimum Version allowed.  A Maximum Version can also be
    #   controlled in a similar method
    #   In WinPE, the latest version will be installed automatically
    #   In Windows, this script is stopped and you will need to update manually
    #=======================================================================
    if ($OSDCloud.Version -lt $OSDCloud.VersionMin) {
        Write-Warning "OSDCloud requires OSD $($OSDCloud.VersionMin) or newer"

        if ($env:SystemDrive -eq 'X:') {
            Write-Warning "Updating OSD PowerShell Module, you will need to restart OSDCloud"
            Install-Module OSD -Force
            Import-Module OSD -Force
            Break
        } else {
            Write-Warning "Run the following PowerShell command to update the OSD PowerShell Module"
            Write-Warning "Install-Module OSD -Force -Verbose"
            Break
        }
    }
    $OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($OSDCloud.Version -lt $OSDCloud.VersionMin) {
        Write-Warning "OSDCloud requires OSD $($OSDCloud.VersionMin) or newer"
        Break
    }
    #=======================================================================
    #   Start
    #   Important to display the location so you know which script is executing
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($OSDCloud.Function)"
    #=======================================================================
    #	OS Check
    #=======================================================================
    if ((!($OSDCloud.ImageFileOffline)) -and (!($OSDCloud.ImageFileTarget)) -and (!($OSDCloud.ImageFileUrl))) {
        Write-Warning "There was no OS specified by any Variables"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Try using Start-OSDCloud or OSDCloudGUI"
        Start-Sleep -Seconds 10
        Break
    }
    #=======================================================================
    #	Autopilot Profiles are procesed in this order
    #   1. $OSDCloud.AutopilotJsonUrl
    #   2. $OSDCloud.AutopilotJsonString
    #   3. $OSDCloud.AutopilotJsonName
    #   4. Select from Table
    #   Results: $OSDCloud.AutopilotObject
    #=======================================================================
    if ($OSDCloud.SkipAutopilot -ne $true) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot Configuration"

        #Autopilot Json URL
        if ($OSDCloud.AutopilotJsonUrl) {
            Write-Host -ForegroundColor DarkGray "Importing Autopilot Configuration $($OSDCloud.AutopilotJsonUrl)"
            if (Test-WebConnection -Uri $OSDCloud.AutopilotJsonUrl) {
                $OSDCloud.AutopilotObject = (Invoke-WebRequest -Uri $OSDCloud.AutopilotJsonUrl).Content | ConvertFrom-Json
            }
        }
        #Autopilot ConvertFrom-Json String
        #elseif ($OSDCloud.AutopilotJsonString) {
        #    $OSDCloud.AutopilotObject = $OSDCloud.AutopilotJsonString
        #}
        else {
            #Autopilot Local Name
            if ($OSDCloud.AutopilotJsonName) {
                $OSDCloud.AutopilotFiles = Find-OSDCloudFile -Name $OSDCloud.AutopilotJsonName -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $OSDCloud.AutopilotFile = $OSDCloud.AutopilotFiles | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
                if ($OSDCloud.AutopilotFile) {
                    $OSDCloud.AutopilotObject = Get-Content $OSDCloud.AutopilotFile.FullName | ConvertFrom-Json
                }
            }
            #Find Autopilot Profiles
            else {
                $OSDCloud.AutopilotFiles = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $OSDCloud.AutopilotFiles = $OSDCloud.AutopilotFiles | Where-Object {$_.FullName -notlike "C*"}

                if ($OSDCloud.AutopilotFiles) {
                    if ($OSDCloud.ZTI -eq $true) {
                        $OSDCloud.AutopilotFile = $OSDCloud.AutopilotFiles | Select-Object -First 1
                    }
                    else {
                        $OSDCloud.AutopilotFile = Select-OSDCloudAutopilotFile
                    }

                    if ($OSDCloud.AutopilotFile) {
                        $OSDCloud.AutopilotObject = Get-Content $OSDCloud.AutopilotFile.FullName | ConvertFrom-Json
                    }
                }
            }
        }

        if ($OSDCloud.AutopilotObject) {
            Write-Host -ForegroundColor Cyan "OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
            $OSDCloud.AutopilotObject | Format-List
        }
        else {
            Write-Warning "AutopilotConfigurationFile.json will not be configured for this deployment"
        }
    }
    #=======================================================================
    #	Provisioning Packages
    #=======================================================================
    if ($OSDCloud.SkipProvPackage -ne $true) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Provisioning Packages Configuration"

        if ($OSDCloud.ProvPackages) {
            Write-Host -ForegroundColor DarkGray "Provisioning Packages already defined by variable"
        }
        else {
            if ($OSDCloud.ZTI -eq $true) {
                Write-Host -ForegroundColor DarkGray "Skip Provisioning Packages selection in ZTI"
            }
            else {
                $OSDCloud.ProvPackages = Select-OSDCloudProvPackage
            }
        }

        if ($OSDCloud.ProvPackages) {
            Write-Host -ForegroundColor Cyan "OSDCloud will apply the following Provisioning Packages"
            $OSDCloud.ProvPackages | Select-Object Name,Fullname | Format-Table
        }
        else {
            Write-Warning "Provisioning Packages will not be configured for this deployment"
        }
    }
    #=======================================================================
    #	Office Configuration 
    #=======================================================================
    if ($OSDCloud.SkipODT -ne $true) {
        $OSDCloud.ODTFiles = Find-OSDCloudODTFile
        
        if ($OSDCloud.ODTFiles) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select Office Deployment Tool Configuration"
        
            $OSDCloud.ODTFile = Select-OSDCloudODTFile
            if ($OSDCloud.ODTFile) {
                Write-Host -ForegroundColor Cyan "Office Config: $($OSDCloud.ODTFile.FullName)"
            } 
            else {
                Write-Warning "OSDCloud Office Config will not be configured for this deployment"
            }
        }
    }
    #=======================================================================
    #   Require WinPE
    #   OSDCloud won't continue past this point unless you are in WinPE
    #   The reason for the late failure is so you can test the Menu
    #=======================================================================
    if ((Get-OSDGather -Property IsWinPE) -eq $false) {
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Write-Warning "$($OSDCloud.BuildName) can only be run from WinPE"
        $OSDCloud.Test = $true
        Write-Warning "Test: $($OSDCloud.Test)"
        #Write-Warning "OSDCloud Failed!"
        Start-Sleep -Seconds 5
        #Break
    }
    else {
        $OSDCloud.Test = $false
    }
    #=======================================================================
    #   USB Drives Offline
    #   This is to ensure nothing is using drive letters we need C R S
    #=======================================================================
    $OSDCloud.USBPartitions = Get-Partition.usb

    foreach ($USBPartition in $OSDCloud.USBPartitions) {
        Write-Warning "Removing PartitionAccessPath USB Disk $($USBPartition.DiskNumber) Partition $($USBPartition.PartitionNumber) Drive Letter $($USBPartition.DriveLetter)"
        Remove-PartitionAccessPath -DiskNumber $USBPartition.DiskNumber -PartitionNumber $USBPartition.PartitionNumber -AccessPath "$($USBPartition.DriveLetter):" -Verbose
        Start-Sleep -Seconds 5
    }
    #=======================================================================
    #   Clear-Disk.fixed
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $OSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    if (($OSDCloud.ZTI -eq $true) -and (($OSDCloud.GetDiskFixed | Measure-Object).Count -lt 2)) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults -Confirm:$false"
        if ($OSDCloud.Test -ne $true) {
            Clear-Disk.fixed -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults"
        if ($OSDCloud.Test -ne $true) {
            Clear-Disk.fixed -Force -NoResults -ErrorAction Stop
        }
    }
    #=======================================================================
    #   New-OSDisk
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if (Test-IsVM) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop"
        if ($OSDCloud.Test -ne $true) {
            New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop
        }
        Write-Host "=========================================================================" -ForegroundColor Cyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
        Write-Host "=========================================================================" -ForegroundColor Cyan
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -Force -ErrorAction Stop"
        if ($OSDCloud.Test -ne $true) {
            New-OSDisk -Force -ErrorAction Stop
        }
        Write-Host "=========================================================================" -ForegroundColor Cyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
        Write-Host "=========================================================================" -ForegroundColor Cyan
    }
    Start-Sleep -Seconds 5
    if (-NOT (Get-PSDrive -Name 'C')) {
        Write-Warning "Disk does not seem to be ready.  Can't continue"
        Break
    }
    #=======================================================================
    #   USB Drives Online
    #=======================================================================
    foreach ($USBPartition in $OSDCloud.USBPartitions) {
        Write-Warning "Add PartitionAccessPath USB Disk $($USBPartition.DiskNumber) Partition $($USBPartition.PartitionNumber) -AssignDriveLetter"
        Add-PartitionAccessPath -DiskNumber $USBPartition.DiskNumber -PartitionNumber $USBPartition.PartitionNumber -AssignDriveLetter -Verbose
        Start-Sleep -Seconds 5
    }
    #=======================================================================
    #   Set the Power Plan to High Performance
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-OSDPower -Property High"
    Write-Host -ForegroundColor DarkGray "Enable High Performance Power Plan"
    if ($OSDCloud.Test -ne $true) {
        Get-OSDPower -Property High
    }
    #=======================================================================
    #   Screenshot
    #=======================================================================
    if ($OSDCloud.Screenshot) {
        Stop-ScreenPNGProcess
        robocopy "$($OSDCloud.Screenshot)" C:\OSDCloud\ScreenPNG *.* /e /ndl /nfl /njh /njs
        Start-ScreenPNGProcess -Directory 'C:\OSDCloud\ScreenPNG'
        $OSDCloud.Screenshot = 'C:\OSDCloud\ScreenPNG'
    }
    #=======================================================================
    #   Start Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $OSDCloud.Transcript) -ErrorAction Ignore
    #=======================================================================
    #	Image File Offline
    #=======================================================================
    if ($OSDCloud.ImageFileOffline) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy OSDCloud ImageFile Offline"
        
        if (!($OSDCloud.ImageFileName)) {
            $OSDCloud.ImageFileName = Split-Path -Path $OSDCloud.ImageFileOffline.FullName -Leaf
        }

        $OSDCloud.ImageFileSource = Find-OSDCloudFile -Name $OSDCloud.ImageFileName -Path (Split-Path -Path (Split-Path -Path $OSDCloud.ImageFileOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
        
        if ($OSDCloud.ImageFileSource) {
            Write-Host -ForegroundColor DarkGray "ImageFileSource: $($OSDCloud.ImageFileSource.FullName)"
            if (!(Test-Path 'C:\OSDCloud\OS')) {
                New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            Copy-Item -Path $OSDCloud.ImageFileSource.FullName -Destination 'C:\OSDCloud\OS' -Force
            if (Test-Path "C:\OSDCloud\OS\$($OSDCloud.ImageFileSource.Name)") {
                $OSDCloud.ImageFileTarget = Get-Item -Path "C:\OSDCloud\OS\$($OSDCloud.ImageFileSource.Name)"
            }
        }
        if ($OSDCloud.ImageFileTarget) {
            Write-Host -ForegroundColor DarkGray "ImageFileTarget.FullName: $($OSDCloud.ImageFileTarget.FullName)"
            $OSDCloud.ImageFileUrl = $null
        }
        else {
            Write-Warning "Something went wrong trying to get the Windows Image"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=======================================================================
    #	Download Image File
    #=======================================================================
    if (!($OSDCloud.ImageFileTarget) -and (!($OSDCloud.ImageFileUrl))) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get Windows 10 Feature Update"
        Write-Warning "Invoke-OSDCloud was not set properly with an OS to Download"
        Write-Warning "You should be using Start-OSDCloud"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Windows 10 Enterprise is being downloaded and installed out of convenience only"

        if (!($OSDCloud.GetFeatureUpdate)) {
            $OSDCloud.GetFeatureUpdate = Get-FeatureUpdate
        }
        if ($OSDCloud.GetFeatureUpdate) {
            $OSDCloud.GetFeatureUpdate = $OSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
            $OSDCloud.ImageFileName = $OSDCloud.GetFeatureUpdate.FileName
            $OSDCloud.ImageFileUrl = $OSDCloud.GetFeatureUpdate.FileUri
            $OSDCloud.OSImageIndex = 6
        }
        else {
            Write-Warning "Unable to locate a Windows 10 Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=======================================================================
    #	Download Image File
    #=======================================================================
    if (!($OSDCloud.ImageFileTarget) -and ($OSDCloud.ImageFileUrl)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Download OSDCloud ImageFile"
        Write-Host -ForegroundColor DarkGray "$($OSDCloud.ImageFileUrl)"
        
        if (Test-WebConnection -Uri $OSDCloud.ImageFileUrl) {
            if ($OSDCloud.ImageFileName) {
                $OSDCloud.ImageFileTarget = Save-WebFile -SourceUrl $OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -DestinationName $OSDCloud.ImageFileName -ErrorAction Stop
            }
            else {
                $OSDCloud.ImageFileTarget = Save-WebFile -SourceUrl $OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -ErrorAction Stop
            }

            if (!(Test-Path $OSDCloud.ImageFileTarget.FullName)) {
                $OSDCloud.ImageFileTarget = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd | Select-Object -First 1
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Windows ImageFile"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        if ($OSDCloud.ImageFileTarget) {
            Write-Host -ForegroundColor DarkGray "ImageFileTarget: $($OSDCloud.ImageFileTarget.FullName)"
        }
    }
    #=======================================================================
    #	FAILED
    #=======================================================================
    if (!($OSDCloud.ImageFileTarget)) {
        Write-Warning "Something went wrong trying to get the Windows ImageFile"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Expand OS
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expand-WindowsImage"

    if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
        New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $OSDCloud.ImageFileTarget.FullName) {

        if (!($OSDCloud.OSImageIndex)) {
            Write-Warning "No ImageIndex is specified, setting ImageIndex = 1"
            $OSDCloud.OSImageIndex = 1
        }
        
        Write-Host -ForegroundColor DarkGray "Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $($OSDCloud.ImageFileTarget.FullName) -Index $($OSDCloud.OSImageIndex) -ScratchDirectory 'C:\OSDCloud\Temp'"
        if ($OSDCloud.Test -ne $true) {
            Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $OSDCloud.ImageFileTarget.FullName -Index $OSDCloud.OSImageIndex -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop

            $SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
            if (-NOT (Get-PSDrive -Name S)) {
                $SystemDrive | Set-Partition -NewDriveLetter 'S'
            }
            bcdboot C:\Windows /s S: /f ALL
            Start-Sleep -Seconds 10
            $SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
        }
    }
    else {
        Write-Warning "Something went wrong trying to get the OS ImageFile"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Required Directories
    #=======================================================================
    if (-NOT (Test-Path 'C:\Drivers')) {
        New-Item -Path 'C:\Drivers' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Panther')) {
        New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Provisioning\Autopilot')) {
        New-Item -Path 'C:\Windows\Provisioning\Autopilot' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
        New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=======================================================================
    #	Get-MyDriverPack
    #=======================================================================
    if ($OSDCloud.Product -ne 'None') {
        if ($OSDCloud.GetMyDriverPack -or $OSDCloud.DriverPackUrl -or $OSDCloud.DriverPackOffline) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDriverPack"
            
            if ($OSDCloud.GetMyDriverPack) {
                Write-Host -ForegroundColor DarkGray "Name: $($OSDCloud.GetMyDriverPack.Name)"
                Write-Host -ForegroundColor DarkGray "Product: $($OSDCloud.GetMyDriverPack.Product)"
                Write-Host -ForegroundColor DarkGray "FileName: $($OSDCloud.GetMyDriverPack.FileName)"
                Write-Host -ForegroundColor DarkGray "DriverPackUrl: $($OSDCloud.GetMyDriverPack.DriverPackUrl)"

                if ($OSDCloud.DriverPackOffline) {
                    $OSDCloud.DriverPackSource = Find-OSDCloudFile -Name (Split-Path -Path $OSDCloud.DriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $OSDCloud.DriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
                }

                if ($OSDCloud.DriverPackSource) {
                    Write-Host -ForegroundColor DarkGray "DriverPackSource.FullName: $($OSDCloud.DriverPackSource.FullName)"
                    Copy-Item -Path $OSDCloud.DriverPackSource.FullName -Destination 'C:\Drivers' -Force
                }

                if ($OSDCloud.Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $OSDCloud.Manufacturer -Product $OSDCloud.Product
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $OSDCloud.Product
                }
            }
            elseif ($OSDCloud.DriverPackUrl) {
                $SaveMyDriverPack = Save-WebFile -SourceUrl $OSDCloud.DriverPackUrl -DestinationDirectory 'C:\Drivers'
            }
            else {
                if ($OSDCloud.Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $OSDCloud.Manufacturer -Product $OSDCloud.Product
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $OSDCloud.Product
                }
            }
        }
    }
    #=======================================================================
    #	Dell BIOS Update
    #=======================================================================
    <# if ($OSDCloud.Manufacturer -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDellBios"
        Write-Warning "This step is currently under development"

        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            Write-Host -ForegroundColor DarkGray "ReleaseDate: $($GetMyDellBios.ReleaseDate)"
            Write-Host -ForegroundColor DarkGray "Name: $($GetMyDellBios.Name)"
            Write-Host -ForegroundColor DarkGray "DellVersion: $($GetMyDellBios.DellVersion)"
            Write-Host -ForegroundColor DarkGray "Url: $($GetMyDellBios.Url)"
            Write-Host -ForegroundColor DarkGray "Criticality: $($GetMyDellBios.Criticality)"
            Write-Host -ForegroundColor DarkGray "FileName: $($GetMyDellBios.FileName)"
            Write-Host -ForegroundColor DarkGray "SizeMB: $($GetMyDellBios.SizeMB)"
            Write-Host -ForegroundColor DarkGray "PackageID: $($GetMyDellBios.PackageID)"
            Write-Host -ForegroundColor DarkGray "SupportedModel: $($GetMyDellBios.SupportedModel)"
            Write-Host -ForegroundColor DarkGray "SupportedSystemID: $($GetMyDellBios.SupportedSystemID)"
            Write-Host -ForegroundColor DarkGray "Flash64W: $($GetMyDellBios.Flash64W)"

            $OSDCloudOfflineBios = Find-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1
            if ($OSDCloudOfflineBios) {
                Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineBios.FullName)"
            }
            else {
                Save-MyDellBios -DownloadPath 'C:\OSDCloud\BIOS'
            }

            $OSDCloudOfflineFlash64W = Find-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
            if ($OSDCloudOfflineFlash64W) {
                Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineFlash64W.FullName)"
            }
            else {
                Save-MyDellBiosFlash64W -DownloadPath 'C:\OSDCloud\BIOS'
            }
        }
        else {
            Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
        }
    } #>
    #=======================================================================
    #   Update-MyDellBios
    #   This step is not fully tested, so commenting out
    #=======================================================================
    <# if ($OSDCloud.Manufacturer -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray    "================================================================="
        Write-Host -ForegroundColor Green       "Update-MyDellBios"
        Update-MyDellBIOS -DownloadPath 'C:\OSDCloud\BIOS'
    } #>
    #=======================================================================
    #   Add-WindowsDriver.offlineservicing
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add-WindowsDriver.offlineservicing"
    Write-Host -ForegroundColor DarkGray "Apply Drivers with Use-WindowsUnattend"
    if ($OSDCloud.Test -ne $true) {
        Add-WindowsDriver.offlineservicing
    }
    #=======================================================================
    #   Set-OSDCloudUnattendSpecialize
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-OSDCloudUnattendSpecialize"
    Write-Host -ForegroundColor DarkGray "Enables Invoke-OSDSpecialize"
    if ($OSDCloud.Test -ne $true) {
        Set-OSDCloudUnattendSpecialize
    }
    #=======================================================================
    #   AutopilotConfigurationFile.json
    #=======================================================================
    if ($OSDCloud.AutopilotObject) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotConfigurationFile.json"
        Write-Verbose -Verbose "Setting C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json"
        $OSDCloud.AutopilotObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ASCII
    }
    #=======================================================================
    #   Stage Office Config
    #=======================================================================
    if ($OSDCloud.ODTFile) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stage Office Config"

        if (!(Test-Path $OSDCloud.ODTTarget)) {
            New-Item -Path $OSDCloud.ODTTarget -ItemType Directory -Force | Out-Null
        }

        if (Test-Path $OSDCloud.ODTFile.FullName) {
            Copy-Item -Path $OSDCloud.ODTFile.FullName -Destination $OSDCloud.ODTConfigFile -Force
        }

        $OSDCloud.ODTSetupFile = Join-Path $OSDCloud.ODTFile.Directory 'setup.exe'
        Write-Verbose -Verbose "ODTSetupFile: $($OSDCloud.ODTSetupFile)"
        if (Test-Path $OSDCloud.ODTSetupFile) {
            Copy-Item -Path $OSDCloud.ODTSetupFile -Destination $OSDCloud.ODTTarget -Force
        }

        $OSDCloud.ODTSource = Join-Path $OSDCloud.ODTFile.Directory 'Office'
        Write-Verbose -Verbose "ODTSource: $($OSDCloud.ODTSource)"
        if (Test-Path $OSDCloud.ODTSource) {
            robocopy "$($OSDCloud.ODTSource)" "$($OSDCloud.ODTTargetData)" *.* /e /ndl /nfl /z /b
        }
    }
    #=======================================================================
    #   Save-OSDCloudOfflineModules
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-OSDCloudOfflineModules"
    Write-Host -ForegroundColor DarkGray "PowerShell Modules and Scripts"
    if ($OSDCloud.Test -ne $true) {
        Save-OSDCloudOfflineModules
    }
    #=======================================================================
    #	Deploy-OSDCloud Complete
    #=======================================================================
    $OSDCloud.TimeEnd = Get-Date
    $OSDCloud.TimeSpan = New-TimeSpan -Start $OSDCloud.TimeStart -End $OSDCloud.TimeEnd
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    #=======================================================================
    if ($OSDCloud.Screenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-Host -ForegroundColor Cyan "Screenshots: $($OSDCloud.Screenshot)"
    }
    #=======================================================================
    <# Write-Warning "WinPE is restarting in 30 seconds"
    Write-Warning "Press CTRL + C to cancel"
    Start-Sleep 30
    wpeutil reboot #>
    #=======================================================================
}