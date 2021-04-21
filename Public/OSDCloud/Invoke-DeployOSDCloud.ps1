function Invoke-DeployOSDCloud {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Create Hashtable
    #=======================================================================
    $Global:OSDCloud = $null
    $Global:OSDCloud = @{
        StartTime = Get-Date
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        VersionMinimum = [Version]'21.4.19.3'
    }
    #=======================================================================
    #	Import Hashtable
    #=======================================================================
    if ($MyOSDCloud) {
        $Global:OSDCloud = $OSDCloud + $MyOSDCloud
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
    #[Version]$Global:OSDCloud.VersionMinimum = '21.4.19.3'
    #[Version]$Global:OSDCloud.Version = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($OSDCloud.Version -lt $OSDCloud.VersionMinimum) {
        Write-Warning "OSDCloud requires OSD $($OSDCloud.VersionMinimum) or newer"

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
    #Check Version Again
    $Global:OSDCloud.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    if ($OSDCloud.Version -lt $OSDCloud.VersionMinimum) {
        Write-Warning "OSDCloud requires OSD $($OSDCloud.VersionMinimum) or newer"
        Break
    }
    Break
    #=======================================================================
    #   VARIABLES
    #   These are set automatically by the OSD Module 21.3.11+ when executing Start-OSDCloud
    #   As a backup, $Global:OSDCloudVariables is created with Get-Variable
    #=======================================================================
    $Global:OSDCloudVariables = Get-Variable
    $BuildName = 'OSDCloud'
    #=======================================================================
    #   Start
    #   Important to display the location so you know which script is executing
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
    #=======================================================================
    #	Hardware
    #=======================================================================
    if (!($OSDCloudManufacturer)) {
        $OSDCloudManufacturer = (Get-MyComputerManufacturer -Brief)
    }

    if (!($OSDCloudProduct)) {
        $OSDCloudProduct = (Get-MyComputerProduct)
    }
    #=======================================================================
    #	Autopilot Profiles
    #   1. $OSDCloudAutopilotJsonUrl
    #   2. $OSDCloudAutopilotJsonString
    #   3. $OSDCloudAutopilotJsonName
    #   4. Select from Table

    #   Results: $OSDCloudAutopilotOutString
    #=======================================================================
    if (!($OSDCloudSkipAutopilot -eq $true)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot Configuration"

        #Autopilot Json URL
        if ($OSDCloudAutopilotJsonUrl) {
            Write-Host -ForegroundColor DarkGray "Importing Autopilot Configuration $OSDCloudAutopilotJsonUrl"
            if (Test-WebConnection -Uri $OSDCloudAutopilotJsonUrl) {
                $Global:OSDCloudAutopilotOutString = (Invoke-WebRequest -Uri $OSDCloudAutopilotJsonUrl).Content | ConvertFrom-Json
            }
        }
        #Autopilot ConvertFrom-Json String
        #elseif ($OSDCloudAutopilotJsonString) {
        #    $OSDCloudAutopilotOutString = $OSDCloudAutopilotJsonString
        #}
        else {
            #Autopilot Local Name
            if ($OSDCloudAutopilotJsonName) {
                $FindOSDCloudFile = Find-OSDCloudFile -Name $OSDCloudAutopilotJsonName -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $FindOSDCloudFile = $FindOSDCloudFile | Where-Object {$_.FullName -notlike "C*"} | Select-Object -First 1
                if ($FindOSDCloudFile) {
                    $Global:OSDCloudAutopilotOutString = Get-Content $FindOSDCloudFile.FullName | ConvertFrom-Json
                }
            }
            #Find Autopilot Profiles
            else {
                $FindOSDCloudFile = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
                $FindOSDCloudFile = $FindOSDCloudFile | Where-Object {$_.FullName -notlike "C*"}

                if ($Global:OSDCloudZTI -eq $true) {
                    $FindOSDCloudFile = $FindOSDCloudFile | Select-Object -First 1
                    if ($FindOSDCloudFile) {
                        $Global:OSDCloudAutopilotOutString = Get-Content $FindOSDCloudFile.FullName | ConvertFrom-Json
                    }
                }
                else {
                    $Global:OSDCloudAutopilotOutString = Select-OSDCloudAutopilotFile
                }
            }
        }

        if ($OSDCloudAutopilotOutString) {
            Write-Host -ForegroundColor Cyan "OSDCloud will apply the following Autopilot Configuration as AutopilotConfigurationFile.json"
            $OSDCloudAutopilotOutString | Format-List
        }
        else {
            Write-Warning "AutopilotConfigurationFile.json will not be configured for this deployment"
        }
    }
    #=======================================================================
    #	Office Configuration 
    #=======================================================================
    if ($OSDCloudSkipODT -eq $false) {
        $GetOSDCloudODT = Find-OSDCloudODTFile
        
        if ($GetOSDCloudODT) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select Office Deployment Tool Configuration"
        
            $Global:OSDCloudODTConfig = Select-OSDCloudODTFile
            if ($Global:OSDCloudODTConfig) {
                Write-Host -ForegroundColor Cyan "Office Config: $($Global:OSDCloudODTConfig.FullName)"
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
        Write-Warning "$BuildName can only be run from WinPE"
        $Global:OSDCloudTest = $true
        Write-Warning "OSDCloudTest: $OSDCloudTest"
        #Write-Warning "OSDCloud Failed!"
        #Start-Sleep -Seconds 5
        #Break
    }
    else {
        $Global:OSDCloudTest = $false
    }
    #=======================================================================
    #   USB Drives Offline
    #   This is to ensure nothing is using drive letters we need C R S
    #=======================================================================
    $GetUSBPartition = Get-Partition.usb

    foreach ($USBPartition in $GetUSBPartition) {
        Write-Warning "Removing PartitionAccessPath USB Disk $($USBPartition.DiskNumber) Partition $($USBPartition.PartitionNumber) Drive Letter $($USBPartition.DriveLetter)"
        Remove-PartitionAccessPath -DiskNumber $USBPartition.DiskNumber -PartitionNumber $USBPartition.PartitionNumber -AccessPath "$($USBPartition.DriveLetter):" -Verbose
        Start-Sleep -Seconds 5
    }
    #=======================================================================
    #   Clear-Disk.fixed
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $GetDisk = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    if (($Global:OSDCloudZTI -eq $true) -and (($GetDisk | Measure-Object).Count -lt 2)) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults -Confirm:$false"
        if ($OSDCloudTest -ne $true) {
            Clear-Disk.fixed -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Clear-Disk.fixed -Force -NoResults"
        if ($OSDCloudTest -ne $true) {
            Clear-Disk.fixed -Force -NoResults -ErrorAction Stop
        }
    }
    #=======================================================================
    #   New-OSDisk
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if (Test-IsVM) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop"
        if ($OSDCloudTest -ne $true) {
            New-OSDisk -NoRecoveryPartition -Force -ErrorAction Stop
        }
        Write-Host "=========================================================================" -ForegroundColor Cyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
        Write-Host "=========================================================================" -ForegroundColor Cyan
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDisk -Force -ErrorAction Stop"
        if ($OSDCloudTest -ne $true) {
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
    foreach ($USBPartition in $GetUSBPartition) {
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
    if ($OSDCloudTest -ne $true) {
        Get-OSDPower -Property High
    }
    #=======================================================================
    #   Screenshot
    #=======================================================================
    if ($OSDCloudScreenshot) {
        Stop-ScreenPNGProcess
        robocopy "$OSDCloudScreenshot" C:\OSDCloud\ScreenPNG *.* /e /ndl /nfl /njh /njs
        Start-ScreenPNGProcess -Directory 'C:\OSDCloud\ScreenPNG'
        $Global:OSDCloudScreenshot = 'C:\OSDCloud\ScreenPNG'
    }
    #=======================================================================
    #   Start Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $TranscriptName = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $TranscriptName) -ErrorAction Ignore
    #=======================================================================
    #	Image File Offline
    #=======================================================================
    if ($OSDCloudImageFileOffline) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy OSDCloud ImageFile Offline"
        
        if (!($OSDCloudImageFileName)) {
            $OSDCloudImageFileName = Split-Path -Path $OSDCloudImageFileOffline.FullName -Leaf
        }

        $Global:OSDCloudSourceImageFile = Find-OSDCloudFile -Name $OSDCloudImageFileName -Path (Split-Path -Path (Split-Path -Path $OSDCloudImageFileOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
        
        if ($OSDCloudSourceImageFile) {
            Write-Host -ForegroundColor DarkGray "OSDCloudSourceImageFile: $($OSDCloudSourceImageFile.FullName)"
            if (!(Test-Path 'C:\OSDCloud\OS')) {
                New-Item -Path 'C:\OSDCloud\OS' -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            Copy-Item -Path $OSDCloudSourceImageFile.FullName -Destination 'C:\OSDCloud\OS' -Force
            if (Test-Path "C:\OSDCloud\OS\$($OSDCloudSourceImageFile.Name)") {
                $Global:OSDCloudTargetImageFile = Get-Item -Path "C:\OSDCloud\OS\$($OSDCloudSourceImageFile.Name)"
            }
        }
        if ($OSDCloudTargetImageFile) {
            Write-Host -ForegroundColor DarkGray "OSDCloudTargetImageFile: $($OSDCloudTargetImageFile.FullName)"
            $Global:OSDCloudImageFileUri = $null
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
    if (!($OSDCloudTargetImageFile) -and ($OSDCloudImageFileUri)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Download OSDCloud ImageFile"
        Write-Host -ForegroundColor DarkGray "$($OSDCloudImageFileUri)"
        
        if (Test-WebConnection -Uri $OSDCloudImageFileUri) {
            if ($OSDCloudImageFileName) {
                $Global:OSDCloudSourceImageFile = Save-WebFile -SourceUrl $OSDCloudImageFileUri -DestinationDirectory 'C:\OSDCloud\OS' -DestinationName $OSDCloudImageFileName -ErrorAction Stop
            }
            else {
                $Global:OSDCloudSourceImageFile = Save-WebFile -SourceUrl $OSDCloudImageFileUri -DestinationDirectory 'C:\OSDCloud\OS' -ErrorAction Stop
            }

            if (Test-Path $OSDCloudSourceImageFile.FullName) {
                $Global:OSDCloudTargetImageFile = Get-Item -Path "C:\OSDCloud\OS\$($OSDCloudSourceImageFile.Name)"
            }
            else {
                $Global:OSDCloudTargetImageFile = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd | Select-Object -First 1
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Windows ImageFile"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        if ($OSDCloudTargetImageFile) {
            Write-Host -ForegroundColor DarkGray "OSDCloudTargetImageFile: $($OSDCloudTargetImageFile.FullName)"
        }
    }
    if (!($OSDCloudTargetImageFile)) {
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

    if (Test-Path $OSDCloudTargetImageFile.FullName) {

        if (!($Global:OSDCloudOSImageIndex)) {
            Write-Warning "No ImageIndex is specified, setting ImageIndex = 1"
            $Global:OSDCloudOSImageIndex = 1
        }
        
        Write-Host -ForegroundColor DarkGray "Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $($OSDCloudTargetImageFile.FullName) -Index $OSDCloudOSImageIndex -ScratchDirectory 'C:\OSDCloud\Temp'"
        if ($OSDCloudTest -ne $true) {
            Expand-WindowsImage -ApplyPath 'C:\' -ImagePath $OSDCloudTargetImageFile.FullName -Index $OSDCloudOSImageIndex -ScratchDirectory 'C:\OSDCloud\Temp' -ErrorAction Stop

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
        New-Item -Path 'C:\Drivers'-ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Panther')) {
        New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Provisioning\Autopilot')) {
        New-Item -Path 'C:\Windows\Provisioning\Autopilot'-ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
        New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=======================================================================
    #	Get-MyDriverPack
    #=======================================================================
    if ($OSDCloudProduct -ne 'None') {
        if ($OSDCloudDriverPack -or $OSDCloudDriverPackUrl -or $OSDCloudDriverPackOffline) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MyDriverPack"
            
            if ($OSDCloudDriverPack) {
                Write-Host -ForegroundColor DarkGray "Name: $($OSDCloudDriverPack.Name)"
                Write-Host -ForegroundColor DarkGray "Product: $($OSDCloudDriverPack.Product)"
                Write-Host -ForegroundColor DarkGray "FileName: $($OSDCloudDriverPack.FileName)"
                Write-Host -ForegroundColor DarkGray "DriverPackUrl: $($OSDCloudDriverPack.DriverPackUrl)"

                if ($OSDCloudDriverPackOffline) {
                    $Global:OSDCloudSourceDriverPack = Find-OSDCloudFile -Name (Split-Path -Path $OSDCloudDriverPackOffline -Leaf) -Path (Split-Path -Path (Split-Path -Path $OSDCloudDriverPackOffline.FullName -Parent) -NoQualifier) | Select-Object -First 1
                }

                if ($OSDCloudSourceDriverPack) {
                    Write-Host -ForegroundColor DarkGray "OSDCloudSourceDriverPack: $($OSDCloudSourceDriverPack.FullName)"
                    Copy-Item -Path $OSDCloudSourceDriverPack.FullName -Destination 'C:\Drivers' -Force
                }

                if ($OSDCloudManufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $OSDCloudManufacturer -Product $OSDCloudProduct
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $OSDCloudProduct
                }
            }
            elseif ($OSDCloudDriverPackUrl) {
                $SaveMyDriverPack = Save-WebFile -SourceUrl $OSDCloudDriverPackUrl -DestinationDirectory 'C:\Drivers'
            }
            else {
                if ($OSDCloudManufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Manufacturer $OSDCloudManufacturer -Product $OSDCloudProduct
                }
                else {
                    $SaveMyDriverPack = Save-MyDriverPack -DownloadPath 'C:\Drivers' -Expand -Product $OSDCloudProduct
                }
            }
        }
    }
    #=======================================================================
    #	Dell BIOS Update
    #=======================================================================
    <# if ($Global:OSDCloudManufacturer -eq 'Dell') {
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
    <# if ($Global:OSDCloudManufacturer -eq 'Dell') {
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
    if ($OSDCloudTest -ne $true) {
        Add-WindowsDriver.offlineservicing
    }
    #=======================================================================
    #   Set-OSDCloudUnattendSpecialize
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-OSDCloudUnattendSpecialize"
    Write-Host -ForegroundColor DarkGray "Enables Invoke-OSDSpecialize"
    if ($OSDCloudTest -ne $true) {
        Set-OSDCloudUnattendSpecialize
    }
    #=======================================================================
    #   AutopilotConfigurationFile.json
    #=======================================================================
    if ($OSDCloudAutopilotOutString) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotConfigurationFile.json"

        $PathAutopilot = 'C:\Windows\Provisioning\Autopilot'

        $AutopilotConfigurationFile = Join-Path $PathAutopilot 'AutopilotConfigurationFile.json'

        Write-Verbose -Verbose "Setting $AutopilotConfigurationFile"
        $OSDCloudAutopilotOutString | ConvertTo-Json | Out-File -FilePath $AutopilotConfigurationFile -Encoding ASCII
    }
    #=======================================================================
    #   Stage Office Config
    #=======================================================================
    if ($OSDCloudODTConfig) {
        Write-Host -ForegroundColor DarkGray "================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stage Office Config"

        if (!(Test-Path "C:\OSDCloud\ODT")) {
            New-Item -Path "C:\OSDCloud\ODT" -ItemType Directory -Force | Out-Null
        }

        if (Test-Path $Global:OSDCloudODTConfig.FullName) {
            Copy-Item -Path $Global:OSDCloudODTConfig.FullName -Destination "C:\OSDCloud\ODT\Config.xml" -Force
        }

        $OfficeSetup = Join-Path $Global:OSDCloudODTConfig.Directory 'setup.exe'
        Write-Verbose -Verbose "OfficeSetup: $OfficeSetup"
        if (Test-Path $OfficeSetup) {
            Copy-Item -Path $OfficeSetup -Destination "C:\OSDCloud\ODT" -Force
        }


        $OfficeData = Join-Path $Global:OSDCloudODTConfig.Directory 'Office'
        Write-Verbose -Verbose "OfficeData: $OfficeData"
        if (Test-Path $OfficeData) {
            robocopy "$OfficeData" "C:\OSDCloud\ODT\Office" *.* /e /ndl /nfl /z /b
        }
    }
    #=======================================================================
    #   Save-OSDCloudOfflineModules
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-OSDCloudOfflineModules"
    Write-Host -ForegroundColor DarkGray "PowerShell Modules and Scripts"
    if ($OSDCloudTest -ne $true) {
        Save-OSDCloudOfflineModules
    }
    #=======================================================================
    #	Deploy-OSDCloud Complete
    #=======================================================================
    $Global:OSDCloudEndTime = Get-Date
    $Global:OSDCloudTimeSpan = New-TimeSpan -Start $OSDCloudStartTime -End $OSDCloudEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    #=======================================================================
    if ($OSDCloudScreenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-Host -ForegroundColor Cyan "Screenshots: $OSDCloudScreenshot"
    }
    #=======================================================================
    <# Write-Warning "WinPE is restarting in 30 seconds"
    Write-Warning "Press CTRL + C to cancel"
    Start-Sleep 30
    wpeutil reboot #>
    #=======================================================================
}