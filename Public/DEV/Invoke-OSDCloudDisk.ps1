function Invoke-OSDCloudDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Create Hashtable
    #=================================================
    $Global:OSDCloud = $null
    $Global:OSDCloud = [ordered]@{
        ApplyManufacturerDrivers = $true
        ApplyCatalogDrivers = $true
        ApplyCatalogFirmware = $true
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
        OSVersion = 'Windows 10'
        Product = Get-MyComputerProduct
        Restart = [bool]$false
        Screenshot = $null
        Shutdown = [bool]$false
        SkipAutopilot = [bool]$false
        SkipAutopilotOOBE = [bool]$false
        SkipODT = [bool]$false
        SkipOOBEDeploy = [bool]$false
        RecoveryPartition = [bool]$true
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
    #	Update Defaults
    #=================================================

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
    #=================================================
    #	Check Fixed Disk
    #=================================================
    #Get the Fixed Disks
    $Global:OSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

    if (! ($Global:OSDCloud.GetDiskFixed)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
        Write-Warning "Unable to locate a Fixed Disk. You may need to add additional HDC Drivers to WinPE"
        Start-Sleep -Seconds 30
        Break
    }
    #=================================================
    #	OS Check
    #=================================================
<#     if ((!($Global:OSDCloud.ImageFileItem)) -and (!($Global:OSDCloud.ImageFileTarget)) -and (!($Global:OSDCloud.ImageFileUrl))) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
        Write-Warning "An Operating System was not specified by any Variables"
        Write-Warning "Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Warning "Try using Start-OSDCloud or Start-OSDCloudGUI"
        Start-Sleep -Seconds 30
        Break
    } #>
    #=================================================
    #   Require WinPE
    #   OSDCloud won't continue past this point unless you are in WinPE
    #   The reason for the late failure is so you can test the Menu
    #=================================================
    if ((Get-OSDGather -Property IsWinPE) -eq $false) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test WinPE"
        Write-Warning "OSDCloud can only be run from WinPE"
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
    #   Set the Power Plan to High Performance
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Enable High Performance"
    Write-Host -ForegroundColor DarkGray "https://docs.microsoft.com/en-us/windows/win32/power/power-policy-settings"
    Write-Host -ForegroundColor DarkGray "High Performance Power Plan is enabled to speed up OSDCloud performance"
    if ($Global:OSDCloud.Test -ne $true) {
        #Get-OSDPower -Property High
        Invoke-Exe powercfg.exe -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    #=================================================
    #   Start Transcript
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
    Write-Host -ForegroundColor DarkGray "https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript"
    Write-Host -ForegroundColor DarkGray "Saving PowerShell Transcript to C:\OSDCloud\Logs"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    
    $Global:OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $Global:OSDCloud.Transcript) -ErrorAction Ignore
    #=================================================
    #	Find Image File
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Find OSDCloud Image"
    $Global:OSDCloud.ImageFileTarget = Get-ChildItem -Path 'C:\OSDCloud\OS\*' -Include *.wim,*.esd | Select-Object -First 1
    #=================================================
    #	FAILED
    #=================================================
    if (!($Global:OSDCloud.ImageFileTarget)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
        Write-Warning "The Windows Image did not download properly"
        Start-Sleep -Seconds 30
        Break
    }
    #=================================================
    #	Expand OS
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expand-WindowsImage"
    Write-Host -ForegroundColor DarkGray "https://docs.microsoft.com/en-us/powershell/module/dism/expand-windowsimage"
    if ($Global:OSDCloud.ImageFileTarget) {
        Write-Host -ForegroundColor DarkGray "ImageFileTarget: $($Global:OSDCloud.ImageFileTarget.FullName)"
    }

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
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
                Write-Warning "This ESD does not contain a Home Single Edition Index"
                Write-Warning "Restart OSDCloud and select a different Edition"
                Start-Sleep -Seconds 30
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
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed"
        Write-Warning "Could not find a proper Windows Image for deployment"
        Start-Sleep -Seconds 30
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
    #	ApplyManufacturerDrivers = TRUE
    #=================================================
    $SaveMyDriverPack = $null
    if ($Global:OSDCloud.ApplyManufacturerDrivers -eq $true) {
        if ($Global:OSDCloud.Product -ne 'None') {
            if ($Global:OSDCloud.GetMyDriverPack -or $Global:OSDCloud.DriverPackUrl -or $Global:OSDCloud.DriverPackOffline) {
                Write-Host -ForegroundColor DarkGray "========================================================================="
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
                        
                        $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

                        foreach ($Item in $DriverPacks) {
                            $ExpandFile = $Item.FullName
                            Write-Verbose -Verbose "DriverPack: $ExpandFile"
                            #=================================================
                            #   Cab
                            #=================================================
                            if ($Item.Extension -eq '.cab') {
                                $DestinationPath = Join-Path $Item.Directory $Item.BaseName
                    
                                if (-NOT (Test-Path "$DestinationPath")) {
                                    New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                
                                    Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
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
                                    Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                                    Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                                }
                                Continue
                            }
                            #=================================================
                        }
                    }
                    elseif ($Global:OSDCloud.Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
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
    }
    #=================================================
    #	ApplyCatalogFirmware
    #   This section will download any available
    #   Firmware updates from Microsoft Update Catalog
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft Catalog Firmware Update"

    if ((Get-MyComputerModel) -match 'Virtual') {
        $Global:OSDCloud.ApplyCatalogFirmware = $false
    }

    if ($Global:OSDCloud.ApplyCatalogFirmware -eq $false) {
        Write-Host -ForegroundColor DarkGray "Microsoft Catalog Firmware Update is not enabled for this deployment"
    }
    else {
        if (Test-WebConnectionMsUpCat) {
            Write-Host -ForegroundColor DarkGray "Firmware Updates will be downloaded from Microsoft Update Catalog to C:\Drivers"
            Write-Host -ForegroundColor DarkGray "Some systems do not support a driver Firmware Update"
            Write-Host -ForegroundColor DarkGray "You may have to enable this setting in your BIOS or Firmware Settings"
            Write-Host -ForegroundColor DarkGray "Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'"
    
            Save-SystemFirmwareUpdate -DestinationDirectory 'C:\Drivers\Firmware'
        }
        else {
            #TODO add some notification
        }
    }
    #=================================================
    #	ApplyCatalogDrivers
    #=================================================
    if ((Get-MyComputerModel) -match 'Virtual') {
        #Do Nothing
    }
    elseif ($Global:OSDCloud.ApplyCatalogDrivers -eq $true) {
        if (Test-WebConnectionMsUpCat) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            if ($null -eq $SaveMyDriverPack) {
                Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MsUpCatDriver (All Devices)"
                Write-Host -ForegroundColor DarkGray "Drivers for all devices will be downloaded from Microsoft Update Catalog to C:\Drivers"

                Write-Host -ForegroundColor DarkGray "Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'"
                Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers'
            }
            else {
                Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save-MsUpCatDriver (Network)"
                Write-Host -ForegroundColor DarkGray "Drivers for Network devices will be downloaded from Microsoft Update Catalog to C:\Drivers"

                Write-Host -ForegroundColor DarkGray "Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'"
                Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'
            }
        }
    }
    #=================================================
    #   Add-WindowsDriver.offlineservicing
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Driver with Offline Servicing"
    Write-Host -ForegroundColor DarkGray "https://docs.microsoft.com/en-us/powershell/module/dism/add-windowsdriver"
    Write-Host -ForegroundColor DarkGray "Drivers in C:\Drivers are being added to the offline Windows Image"
    Write-Host -ForegroundColor DarkGray "This process can take up to 20 minutes"

    Write-Host -ForegroundColor DarkGray "Add-WindowsDriver.offlineservicing"
    if ($Global:OSDCloud.Test -ne $true) {
        Add-WindowsDriver.offlineservicing
    }
    #=================================================
    #   Set-OSDCloudUnattendSpecialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set Specialize Unattend.xml"
    Write-Host -ForegroundColor DarkGray "C:\Windows\Panther\Invoke-OSDSpecialize.xml is being applied as an Unattend file"
    Write-Host -ForegroundColor DarkGray "This will enable the extraction and installation of HP and Lenovo Drivers if necessary"
    
    Write-Host -ForegroundColor DarkGray "Set-OSDCloudUnattendSpecialize"
    if ($Global:OSDCloud.Test -ne $true) {
        Set-OSDCloudUnattendSpecialize
    }
    #=================================================
    #   AutopilotConfigurationFile.json
    #=================================================
    if ($Global:OSDCloud.AutopilotJsonObject) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying AutopilotConfigurationFile.json"
        Write-Host -ForegroundColor DarkGray 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json'
        $Global:OSDCloud.AutopilotJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json' -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   OSDeploy.OOBEDeploy.json
    #=================================================
    if ($Global:OSDCloud.OOBEDeployJsonObject) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying OSDeploy.OOBEDeploy.json"
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
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying OSDeploy.AutopilotOOBE.json"
        Write-Host -ForegroundColor DarkGray 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json'

        If (!(Test-Path "C:\ProgramData\OSDeploy")) {
            New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
        }
        $Global:OSDCloud.AutopilotOOBEJsonObject | ConvertTo-Json | Out-File -FilePath 'C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json' -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   Save PowerShell Modules to OSDisk
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving PowerShell Modules and Scripts"
    
    Write-Host -ForegroundColor DarkGray "Save PowerShell Modules to OSDisk"
    if ($Global:OSDCloud.Test -ne $true) {
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
            Save-Module -Name OSD -Path "$PowerShellSavePath\Modules" -Force
            Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force
            Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force
            Save-Module -Name WindowsAutopilotIntune -Path "$PowerShellSavePath\Modules" -Force
            Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellSavePath\Scripts" -Force
        }
        else {
            Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to $PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name OSD -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name PackageManagement -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name PowerShellGet -Destination "$PowerShellSavePath\Modules"
            Copy-PSModuleToFolder -Name WindowsAutopilotIntune -Destination "$PowerShellSavePath\Modules"
        
            $OSDCloudOfflinePath = Find-OSDCloudOfflinePath
        
            foreach ($Item in $OSDCloudOfflinePath) {
                if (Test-Path "$($Item.FullName)\PowerShell\Required") {
                    Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
                    robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /s /ndl /njh /njs
                }
            }
        }
    }
    #=================================================
    #	Deploy-OSDCloud Complete
    #=================================================
    $Global:OSDCloud.TimeEnd = Get-Date
    $Global:OSDCloud.TimeSpan = New-TimeSpan -Start $Global:OSDCloud.TimeStart -End $Global:OSDCloud.TimeEnd
    
    $Global:OSDCloud | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\OSDCloud.json' -Encoding ascii -Width 2000 -Force
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Finished"
    Write-Host -ForegroundColor DarkGray "Completed in $($Global:OSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
    if ($Global:OSDCloud.Screenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-Host -ForegroundColor DarkGray "Screenshots: $($Global:OSDCloud.Screenshot)"
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
    if ($Global:OSDCloud.Shutdown) {
        Write-Warning "WinPE will shutdown in 30 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 30
        if ($Global:OSDCloud.Test -ne $true) {
            Stop-Computer
        }
    }
    #=================================================
}