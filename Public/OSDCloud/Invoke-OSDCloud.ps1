function Invoke-OSDCloud {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Create Hashtable
    #=================================================
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
        BuildName = 'OSDCloud'
        DriverPackUrl = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileTarget = $null
        ImageFileUrl = $null
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = Get-MyComputerManufacturer -Brief
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
        Product = Get-MyComputerProduct
        Restart = $null
        Screenshot = $null
        SkipAutopilot = [bool]$false
        SkipAutopilotOOBE = [bool]$false
        SkipODT = [bool]$false
        SkipOOBEDeploy = [bool]$false
        Test = [bool]$false
        TimeEnd = $null
        TimeSpan = $null
        TimeStart = Get-Date
        Transcript = $null
        USBPartitions = $null
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        VersionMin = [Version]'21.8.3.2'
        ZTI = [bool]$false
    }
    #=================================================
    #	Merge Hashtables
    #=================================================
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
    #$Global:OSDCloud | Out-Host
    #=================================================
    #   VERSIONING
    #   Scripts/Test-OSDModule.ps1
    #   OSD Module Minimum Version
    #   Since the OSD Module is doing much of the heavy lifting, it is important to ensure that old
    #   OSD Module versions are not used long term as the OSDCloud script can change
    #   This example allows you to control the Minimum Version allowed.  A Maximum Version can also be
    #   controlled in a similar method
    #   In WinPE, the latest version will be installed automatically
    #   In Windows, this script is stopped and you will need to update manually
    #=================================================
    if ($Global:OSDCloud.Version -lt $Global:OSDCloud.VersionMin) {
        Write-Warning "OSDCloud requires OSD $($Global:OSDCloud.VersionMin) or newer"

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
    $Global:OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($Global:OSDCloud.Version -lt $Global:OSDCloud.VersionMin) {
        Write-Warning "OSDCloud requires OSD $($Global:OSDCloud.VersionMin) or newer"
        Break
    }
    #=================================================
    #   Start
    #   Important to display the location so you know which script is executing
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Global:OSDCloud.Function)"
    #=================================================
    #	OS Check
    #=================================================
    if ((!($Global:OSDCloud.ImageFileItem)) -and (!($Global:OSDCloud.ImageFileTarget)) -and (!($Global:OSDCloud.ImageFileUrl))) {
        Write-Warning "There was no OS specified by any Variables"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Try using Start-OSDCloud or Start-OSDCloudGUI"
        Start-Sleep -Seconds 10
        Break
    }
    #=================================================
    #	Autopilot Profiles are procesed in this order
    #=================================================
    if ($Global:OSDCloud.SkipAutopilot -ne $true) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot Configuration"

        if ($Global:OSDCloud.AutopilotJsonObject) {
            Write-Host -ForegroundColor DarkGray 'Importing AutopilotJsonObject'
        }
        elseif ($Global:OSDCloud.AutopilotJsonUrl) {
            Write-Host -ForegroundColor DarkGray "Importing Autopilot Configuration $($Global:OSDCloud.AutopilotJsonUrl)"
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
            Write-Host -ForegroundColor Cyan "OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
            $($Global:OSDCloud.AutopilotJsonObject) | Out-Host | Format-List
        }
        else {
            Write-Warning "AutopilotConfigurationFile.json will not be configured for this deployment"
        }
    }
    #=================================================
    #	Office Configuration 
    #=================================================
    if ($Global:OSDCloud.SkipODT -ne $true) {
        $Global:OSDCloud.ODTFiles = Find-OSDCloudODTFile
        
        if ($Global:OSDCloud.ODTFiles) {
            Write-Host -ForegroundColor DarkGray "================================================"
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select Office Deployment Tool Configuration"
        
            $Global:OSDCloud.ODTFile = Select-OSDCloudODTFile
            if ($Global:OSDCloud.ODTFile) {
                Write-Host -ForegroundColor Cyan "Office Config: $($Global:OSDCloud.ODTFile.FullName)"
            } 
            else {
                Write-Warning "OSDCloud Office Config will not be configured for this deployment"
            }
        }
    }
    #=================================================
    #   Require WinPE
    #   OSDCloud won't continue past this point unless you are in WinPE
    #   The reason for the late failure is so you can test the Menu
    #=================================================
    if ((Get-OSDGather -Property IsWinPE) -eq $false) {
        Write-Host -ForegroundColor DarkGray    "================================================"
        Write-Warning "$($Global:OSDCloud.BuildName) can only be run from WinPE"
        $Global:OSDCloud.Test = $true
        Write-Warning "Test: $($Global:OSDCloud.Test)"
        #Write-Warning "OSDCloud Failed!"
        Start-Sleep -Seconds 5
        #Break
    }
    else {
        $Global:OSDCloud.Test = $false
    }
    #=================================================
    #   USB Drives Offline
    #   This is to ensure nothing is using drive letters we need C R S
    #=================================================
    $Global:OSDCloud.USBPartitions = Get-Partition.usb

    foreach ($USBPartition in $Global:OSDCloud.USBPartitions) {
        Write-Warning "Removing PartitionAccessPath USB Disk $($USBPartition.DiskNumber) Partition $($USBPartition.PartitionNumber) Drive Letter $($USBPartition.DriveLetter)"
        Remove-PartitionAccessPath -DiskNumber $USBPartition.DiskNumber -PartitionNumber $USBPartition.PartitionNumber -AccessPath "$($USBPartition.DriveLetter):" -Verbose
        Start-Sleep -Seconds 5
    }
    #=================================================
    #   Clear-Disk.fixed
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    $Global:OSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    if (($Global:OSDCloud.ZTI -eq $true) -and (($Global:OSDCloud.GetDiskFixed | Measure-Object).Count -lt 2)) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults -Confirm:$false"
        if ($Global:OSDCloud.Test -ne $true) {
            Clear-Disk.fixed -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults"
        if ($Global:OSDCloud.Test -ne $true) {
            Clear-Disk.fixed -Force -NoResults -ErrorAction Stop
        }
    }
    #=================================================
    #   New-OSDisk
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    if (Test-IsVM) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop"
        if ($Global:OSDCloud.Test -ne $true) {
            New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop
        }
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -Force -ErrorAction Stop"
        if ($Global:OSDCloud.Test -ne $true) {
            New-OSDisk -Force -ErrorAction Stop
        }
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
    }
    Start-Sleep -Seconds 5
    if (-NOT (Get-PSDrive -Name 'C')) {
        Write-Warning "Disk does not seem to be ready.  Can't continue"
        Break
    }
    #=================================================
    #   USB Drives Online
    #=================================================
    foreach ($USBPartition in $Global:OSDCloud.USBPartitions) {
        Write-Warning "Add PartitionAccessPath USB Disk $($USBPartition.DiskNumber) Partition $($USBPartition.PartitionNumber) -AssignDriveLetter"
        Add-PartitionAccessPath -DiskNumber $USBPartition.DiskNumber -PartitionNumber $USBPartition.PartitionNumber -AssignDriveLetter -Verbose
        Start-Sleep -Seconds 5
    }
    #=================================================
    #   Set the Power Plan to High Performance
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get-OSDPower -Property High"
    Write-Host -ForegroundColor DarkGray "Enable High Performance Power Plan"
    if ($Global:OSDCloud.Test -ne $true) {
        Get-OSDPower -Property High
    }
    #=================================================
    #   Screenshot
    #=================================================
    if ($Global:OSDCloud.Screenshot) {
        Stop-ScreenPNGProcess
        Invoke-Exe robocopy "$($Global:OSDCloud.Screenshot)" C:\OSDCloud\ScreenPNG *.* /s /ndl /nfl /njh /njs
        Start-ScreenPNGProcess -Directory 'C:\OSDCloud\ScreenPNG'
        $Global:OSDCloud.Screenshot = 'C:\OSDCloud\ScreenPNG'
    }
    #=================================================
    #   Start Transcript
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $Global:OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $Global:OSDCloud.Transcript) -ErrorAction Ignore
    #=================================================
    #	Image File Offline
    #=================================================
    if ($Global:OSDCloud.ImageFileItem) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy OSDCloud ImageFile Offline"

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
            Write-Host -ForegroundColor DarkGray "ImageFileSource: $($Global:OSDCloud.ImageFileSource.FullName)"
            if (!(Test-Path 'C:\OSDCloud\OS')) {
                New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            Copy-Item -Path $Global:OSDCloud.ImageFileSource.FullName -Destination 'C:\OSDCloud\OS' -Force
            if (Test-Path "C:\OSDCloud\OS\$($Global:OSDCloud.ImageFileSource.Name)") {
                $Global:OSDCloud.ImageFileTarget = Get-Item -Path "C:\OSDCloud\OS\$($Global:OSDCloud.ImageFileSource.Name)"
            }
        }
        if ($Global:OSDCloud.ImageFileTarget) {
            Write-Host -ForegroundColor DarkGray "ImageFileTarget.FullName: $($Global:OSDCloud.ImageFileTarget.FullName)"
            $Global:OSDCloud.ImageFileUrl = $null
        }
        else {
            Write-Warning "Something went wrong trying to get the Windows Image"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #	Download Image File
    #=================================================
    if (!($Global:OSDCloud.ImageFileTarget) -and (!($Global:OSDCloud.ImageFileUrl))) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Get Windows 10 Feature Update"
        Write-Warning "Invoke-OSDCloud was not set properly with an OS to Download"
        Write-Warning "You should be using Start-OSDCloud"
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
            Write-Warning "Unable to locate a Windows 10 Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #	Download Image File
    #=================================================
    if (!($Global:OSDCloud.ImageFileTarget) -and ($Global:OSDCloud.ImageFileUrl)) {
        Write-Host -ForegroundColor DarkGray "================================================"
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Download OSDCloud ImageFile"
        Write-Host -ForegroundColor DarkGray "$($Global:OSDCloud.ImageFileUrl)"
        
        if (Test-WebConnection -Uri $Global:OSDCloud.ImageFileUrl) {
            if ($Global:OSDCloud.ImageFileName) {
                $Global:OSDCloud.ImageFileTarget = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -DestinationName $Global:OSDCloud.ImageFileName -ErrorAction Stop
            }
            else {
                $Global:OSDCloud.ImageFileTarget = Save-WebFile -SourceUrl $Global:OSDCloud.ImageFileUrl -DestinationDirectory 'C:\OSDCloud\OS' -ErrorAction Stop
            }

            if (!(Test-Path $Global:OSDCloud.ImageFileTarget.FullName)) {
                $Global:OSDCloud.ImageFileTarget = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd | Select-Object -First 1
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Windows ImageFile"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        if ($Global:OSDCloud.ImageFileTarget) {
            Write-Host -ForegroundColor DarkGray "ImageFileTarget: $($Global:OSDCloud.ImageFileTarget.FullName)"
        }
    }
    #=================================================
    #	FAILED
    #=================================================
    if (!($Global:OSDCloud.ImageFileTarget)) {
        Write-Warning "Something went wrong trying to get the Windows ImageFile"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=================================================
    #	Expand OS
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expand-WindowsImage"

    if (-NOT (Test-Path 'C:\OSDCloud\Temp')) {
        New-Item 'C:\OSDCloud\Temp' -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $Global:OSDCloud.ImageFileTarget.FullName) {

        $ImageCount = (Get-WindowsImage -ImagePath $Global:OSDCloud.ImageFileTarget.FullName).Count

        if (!($Global:OSDCloud.OSImageIndex)) {
            if ($ImageCount -eq 1) {
                Write-Warning "No ImageIndex is specified, setting ImageIndex = 1"
                $Global:OSDCloud.OSImageIndex = 1
            }
            else {
                Write-Warning "No ImageIndex is specified, setting ImageIndex = 4"
                $Global:OSDCloud.OSImageIndex = 4
            }
        }

        if (($OSLicense -eq 'Retail') -and ($ImageCount -eq 9)) {
            if ($OSEdition -eq 'Home Single Language') {
                Write-Warning "This ESD does not contain a Home Single Edition Index"
                Write-Warning "Restart OSDCloud and select a different Edition"
                Break
            }
            if ($OSEdition -notmatch 'Home') {
                Write-Warning "This ESD does not contain a Home Single Edition Index"
                Write-Warning "Adjusting selected Image Index by -1"
                $Global:OSDCloud.OSImageIndex = ($Global:OSDCloud.OSImageIndex - 1)
            }
        }

        Write-Host -ForegroundColor DarkGray "Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $($Global:OSDCloud.ImageFileTarget.FullName) -Index $($Global:OSDCloud.OSImageIndex) -ScratchDirectory 'C:\OSDCloud\Temp'"
        if ($Global:OSDCloud.Test -ne $true) {
            Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $Global:OSDCloud.ImageFileTarget.FullName -Index $Global:OSDCloud.OSImageIndex -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop

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
    #=================================================
    #	Required Directories
    #=================================================
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
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    $SaveMyDriverPack = $null
    if ($Global:OSDCloud.Product -ne 'None') {
        if ($Global:OSDCloud.GetMyDriverPack -or $Global:OSDCloud.DriverPackUrl -or $Global:OSDCloud.DriverPackOffline) {
            Write-Host -ForegroundColor DarkGray "================================================"
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDriverPack"
            
            if ($Global:OSDCloud.GetMyDriverPack) {
                Write-Host -ForegroundColor DarkGray "Name: $($Global:OSDCloud.GetMyDriverPack.Name)"
                Write-Host -ForegroundColor DarkGray "Product: $($Global:OSDCloud.GetMyDriverPack.Product)"
                Write-Host -ForegroundColor DarkGray "FileName: $($Global:OSDCloud.GetMyDriverPack.FileName)"
                Write-Host -ForegroundColor DarkGray "DriverPackUrl: $($Global:OSDCloud.GetMyDriverPack.DriverPackUrl)"

                if ($Global:OSDCloud.DriverPackOffline) {
                    $Global:OSDCloud.DriverPackSource = Find-OSDCloudFile -Name (Split-Path -Path $Global:OSDCloud.DriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $Global:OSDCloud.DriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
                }

                if ($Global:OSDCloud.DriverPackSource) {
                    Write-Host -ForegroundColor DarkGray "DriverPackSource.FullName: $($Global:OSDCloud.DriverPackSource.FullName)"
                    Copy-Item -Path $Global:OSDCloud.DriverPackSource.FullName -Destination 'C:\Drivers' -Force
                }

                if ($Global:OSDCloud.Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $Global:OSDCloud.Manufacturer -Product $Global:OSDCloud.Product
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $Global:OSDCloud.Product
                }
            }
            elseif ($Global:OSDCloud.DriverPackUrl) {
                $SaveMyDriverPack = Save-WebFile -SourceUrl $Global:OSDCloud.DriverPackUrl -DestinationDirectory 'C:\Drivers'
            }
            else {
                if ($Global:OSDCloud.Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $Global:OSDCloud.Manufacturer -Product $Global:OSDCloud.Product
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $Global:OSDCloud.Product
                }
            }
        }
    }
    #=================================================
    #	Save-SystemFirmwareUpdate
    #=================================================
    if ((Get-MyComputerModel) -match 'Virtual') {
        #Do Nothing
    }
    else {
        if (Test-WebConnectionMsUpCat) {
            Write-Host -ForegroundColor DarkGray "================================================"
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-SystemFirmwareUpdate"
            Write-Host -ForegroundColor DarkGray "Firmware Updates will be downloaded from Microsoft Update Catalog to C:\Drivers"
            Write-Host -ForegroundColor DarkGray "If the downloaded Firmware Update is newer than the existing Firmware, it will be installed"
            Write-Host -ForegroundColor DarkGray "This doesn't always work 100% in testing on some systems"
            Write-Host -ForegroundColor Gray "Command: Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'"
    
            Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'
        }
    }
    #=================================================
    #	Save-MsUpCatDriver Net
    #=================================================
    if (Test-WebConnectionMsUpCat) {
        Write-Host -ForegroundColor DarkGray "================================================"
        if ($null -eq $SaveMyDriverPack) {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MsUpCatDriver (All Devices)"
            Write-Host -ForegroundColor DarkGray "Drivers for all devices will be downloaded from Microsoft Update Catalog to C:\Drivers"
            Write-Host -ForegroundColor Gray "Command: Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'"

            Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'
        }
        else {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MsUpCatDriver (Network)"
            Write-Host -ForegroundColor DarkGray "Drivers for Network devices will be downloaded from Microsoft Update Catalog to C:\Drivers"
            Write-Host -ForegroundColor Gray "Command: Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'"
            Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'
        }
    }
    #=================================================
    #   Add-WindowsDriver.offlineservicing
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add-WindowsDriver.offlineservicing"
    Write-Host -ForegroundColor DarkGray "Drivers in C:\Drivers are being added to the offline Windows Image"
    Write-Host -ForegroundColor DarkGray "This process can take up to 20 minutes"
    Write-Host -ForegroundColor Gray "Command: Add-WindowsDriver.offlineservicing"
    if ($Global:OSDCloud.Test -ne $true) {
        Add-WindowsDriver.offlineservicing
    }
    #=================================================
    #   Set-OSDCloudUnattendSpecialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-OSDCloudUnattendSpecialize"
    Write-Host -ForegroundColor DarkGray "C:\Windows\Panther\Invoke-OSDSpecialize.xml is being applied as an Unattend file"
    Write-Host -ForegroundColor DarkGray "This will enable the extraction and installation of HP and Lenovo Drivers if necessary"
    Write-Host -ForegroundColor Gray "Command: Set-OSDCloudUnattendSpecialize"
    if ($Global:OSDCloud.Test -ne $true) {
        Set-OSDCloudUnattendSpecialize
    }
    #=================================================
    #   AutopilotConfigurationFile.json
    #=================================================
    if ($Global:OSDCloud.AutopilotJsonObject) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotConfigurationFile.json"
        Write-Host -ForegroundColor DarkGray 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        $Global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   OSDeploy.OOBEDeploy.json
    #=================================================
    if ($Global:OSDCloud.OOBEDeployJsonObject) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDeploy.OOBEDeploy.json"
        Write-Host -ForegroundColor DarkGray 'C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json'

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
    #=================================================
    #   OSDeploy.AutopilotOOBE.json
    #=================================================
    if ($Global:OSDCloud.AutopilotOOBEJsonObject) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDeploy.AutopilotOOBE.json"
        Write-Host -ForegroundColor DarkGray 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   Stage Office Config
    #=================================================
    if ($Global:OSDCloud.ODTFile) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stage Office Config"

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
    #=================================================
    #   Save-OSDCloudOfflineModules
    #=================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-OSDCloudOfflineModules"
    Write-Host -ForegroundColor DarkGray "PowerShell Modules and Scripts"
    if ($Global:OSDCloud.Test -ne $true) {
        Save-OSDCloudOfflineModules
    }
    #=================================================
    #	Deploy-OSDCloud Complete
    #=================================================
    $Global:OSDCloud.TimeEnd = Get-Date
    $Global:OSDCloud.TimeSpan = New-TimeSpan -Start $Global:OSDCloud.TimeStart -End $Global:OSDCloud.TimeEnd
    
    $Global:OSDCloud | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\OSDCloud.json' -Encoding ascii -Width 2000 -Force
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    Write-Host -ForegroundColor DarkGray    "================================================"
    #=================================================
    if ($Global:OSDCloud.Screenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-Host -ForegroundColor Cyan "Screenshots: $($Global:OSDCloud.Screenshot)"
    }
    #=================================================
    if ($Global:OSDCloud.Restart) {
        Write-Warning "WinPE is restarting in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.Test -ne $true) {
            Restart-Computer
        }
    }
    #=================================================
}