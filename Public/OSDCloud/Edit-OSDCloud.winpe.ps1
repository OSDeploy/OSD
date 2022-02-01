<#
.SYNOPSIS
Edits the boot.wim in an OSDCloud.workspace

.Description
Edits the boot.wim in an OSDCloud.workspace

.PARAMETER WorkspacePath
Directory for the OSDCloud.workspace which contains Media directory
This is optional as the OSDCloud.workspace is returned by Get-OSDCloud.workspace automatically

.PARAMETER DriverPath
Path to additional Drivers you want to install

.PARAMETER CloudDriver
Download and install in WinPE drivers from Dell,HP,Nutanix,VMware,WiFi

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function Edit-OSDCloud.winpe {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [ValidateSet('*','Dell','HP','Intel','LenovoDock','Nutanix','USB','VMware','WiFi')]
        [string[]]$CloudDriver,
        [string[]]$DriverHWID,
        [string[]]$DriverPath,

        [string[]]$PSModuleCopy,
        [Alias('Modules')]
        [string[]]$PSModuleInstall,

        [string]$Startnet,
        [string]$StartOSDCloud,
        [switch]$StartOSDCloudGUI,
        [string]$StartOSDPad,
        [string]$StartPSCommand,
        [Alias('WebPSScript')]
        [string]$StartWebScript,
        [string]$Wallpaper,
        [string]$WorkspacePath
    )
    #=================================================
    #	Start the Clock
    #=================================================
    $WinpeStartTime = Get-Date
    #=================================================
    #	Cloud Drivers
    #=================================================
    if ($CloudDriver -contains '*') {
        $CloudDriver = @('Dell','HP','Intel','LenovoDock','Nutanix','USB','VMware','WiFi')
    }

    $DellCloudDriverText            = 'Dell A25 WinPE Driver Pack'
    $DellCloudDriverUrl             = 'http://downloads.dell.com/FOLDER07703466M/1/WinPE10.0-Drivers-A25-F0XPX.CAB'
    
    $HpCloudDriverText              = 'HP 2.0 WinPE Driver Pack'
    $HpCloudDriverUrl               = 'https://ftp.hp.com/pub/softpaq/sp112501-113000/sp112810.exe'

    $IntelEthernetCloudDriverText   = 'Intel Ethernet 26.8 WinPE Driver Pack'
    $IntelEthernetCloudDriverUrl    = 'https://downloadmirror.intel.com/710138/Wired_driver_26.8_x64.zip'
    
    $IntelWiFiCloudDriverText       = 'Intel Wireless 22.80.1 WinPE Driver Pack'
    $IntelWiFiCloudDriverUrl        = 'https://downloadmirror.intel.com/655277/WiFi-22.80.1-Driver64-Win10-Win11.zip'
    
    $LenovoDockCloudDriverText      = 'Lenovo Dock 22.1.31 WinPE Driver Pack'
    $LenovoDockCloudDriverUrl       = @(
                                        'https://download.lenovo.com/pccbbs/mobiles/rtk-winpe-w10.zip'
                                        'https://download.lenovo.com/km/media/attachment/USBCG2.zip'
                                        )

    $NutanixCloudDriverText         = 'Nutanix WinPE Driver Pack'
    $NutanixCloudDriverUrl          = 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab'
    $NutanixCloudDriverHwids         = @(
                                        'VEN_1AF4&DEV_1000 and VEN_1AF4&DEV_1041' #Red Hat Nutanix VirtIO Ethernet Adapter
                                        'VEN_1AF4&DEV_1002' #Red Hat Nutanix VirtIO Balloon
                                        'VEN_1AF4&DEV_1004 and VEN_1AF4&DEV_1048' #Red Hat Nutanix VirtIO SCSI pass-through controller
                                        )
    
    $UsbDongleHwidsText             = 'OSDCloud USB Dongle 22.1.31 Driver Pack'
    $UsbDongleHwids                 = @(
                                        'VID_045E&PID_0927 VID_045E&PID_0927 VID_045E&PID_09A0 Surface Ethernet'
                                        'VID_0B95&PID_7720 VID_0B95&PID_7E2B Asix AX88772 USB2.0 to Fast Ethernet'
                                        'VID_0B95&PID_1790 ASIX AX88179 USB 3.0 to Gigabit Ethernet'
                                        'VID_0BDA&PID_8153 Realtek USB GbE and Dell DA 300'
                                        'VID_17EF&PID_720C Lenovo USB-C Ethernet'
                                        )
    
    $VmwareCloudDriverText          = 'VMware WinPE Driver Pack'
    $VmwareCloudDriverUrl           = 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab'
    $VmwareCloudDriverHwids         = @(
                                        'VEN_15AD&DEV_0740' #VMware Virtual Machine Communication Interface
                                        'VEN_15AD&DEV_07B0' #VMware VMXNET3 Ethernet Controller
                                        'VEN_15AD&DEV_07C0' #VMware PVSCSI Controller
                                        )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	Get-OSDCloud.template
    #=================================================
    if (-NOT (Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Write-Host "Setting Workspace Path"
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace
    #=================================================
    #	Setup Workspace
    #=================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "New-OSDCloud.iso -WorkspacePath C:\OSDCloud"
        Write-Warning "New-OSDCloud.workspace -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
    #=================================================
    #	Remove Old Autopilot Content
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $env:ProgramData\OSDCloud\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $env:ProgramData\OSDCloud\Autopilot is manually removed"
        Break
    }
    if (Test-Path "$WorkspacePath\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $WorkspacePath\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $WorkspacePath\Autopilot is manually removed"
        Break
    }
    #=================================================
    #   Mount-MyWindowsImage
    #=================================================
    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath "$WorkspacePath\Media\Sources\boot.wim"
    $MountPath = $MountMyWindowsImage.Path
    #=================================================
    #   Robocopy Config
    #=================================================
    if (Test-Path "$WorkspacePath\Config") {
        robocopy "$WorkspacePath\Config" "$MountPath\OSDCloud\Config" *.* /mir /ndl /njh /njs /b /np
    }
    #=================================================
    #   Robocopy ODT Config
    #=================================================
    if (Test-Path "$WorkspacePath\ODT") {
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" *.xml /mir /ndl /njh /njs /b /np
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" setup.exe /mir /ndl /njh /njs /b /np
    }
    #=================================================
    #   DriverPath
    #=================================================
    foreach ($Driver in $DriverPath) {
        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned -Verbose
    }
    #=================================================
    #   DriverHWID
    #=================================================
    if ($DriverHWID) {
        $HardwareIDDriverPath = Join-Path $env:TEMP (Get-Random)
        foreach ($Item in $DriverHWID) {
            Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $HardwareIDDriverPath
        }
        try {
            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $HardwareIDDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        catch {
            Write-Warning "Unable to find a driver for $Item"
        }
    }
    #=================================================
    #   CloudDriver
    #=================================================
    foreach ($Driver in $CloudDriver) {
        if ($Driver -eq 'Dell'){
            Write-Host -ForegroundColor Yellow $DellCloudDriverText
            if (Test-WebConnection -Uri $DellCloudDriverUrl) {
                $SaveWebFile = Save-WebFile -SourceUrl $DellCloudDriverUrl
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath\winpe\x64" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
            }
            else {
                Write-Warning "Unable to connect to $DellCloudDriverUrl"
            }
        }
        if ($Driver -eq 'HP') {
            Write-Host -ForegroundColor Yellow $HpCloudDriverText
            if (Test-WebConnection -Uri $HpCloudDriverUrl)   {
              $SaveWebFile = Save-WebFile -SourceUrl $HpCloudDriverUrl
                    if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    Start-Process -FilePath $DriverCab -ArgumentList "/s /e /f `"$ExpandPath`"" -Wait
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
            }
            else {  
                Write-Warning "Unable to connect to $HpCloudDriverUrl"  
            }
        }
        if ($Driver -eq 'LenovoDock') {
            Write-Host -ForegroundColor Yellow $LenovoDockCloudDriverText
            foreach ($ZipFile in $LenovoDockCloudDriverUrl) {
                if (Test-WebConnection -Uri $ZipFile) {
                    $SaveWebFile = Save-WebFile -SourceUrl $ZipFile
                    if (Test-Path $SaveWebFile.FullName) {
                        $DriverCab = Get-Item -Path $SaveWebFile.FullName
                        $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                        Expand-Archive -Path $DriverCab -DestinationPath $ExpandPath -Force
                        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                    }
                }
                else {
                    Write-Warning "Unable to connect to $IntelWiFiCloudDriverUrl"
                }
            }
        }
        if ($Driver -eq 'Intel') {
            Write-Host -ForegroundColor Yellow $IntelEthernetCloudDriverText
            if (Test-WebConnection -Uri $IntelEthernetCloudDriverUrl)   {
                $SaveWebFile = Save-WebFile -SourceUrl $IntelEthernetCloudDriverUrl
                   if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    Expand-Archive -Path $DriverCab -DestinationPath $ExpandPath -Force
                    $IntelExe = Get-ChildItem -Path $ExpandPath 'Wired_driver_26.8_x64.exe'
                    $IntelExe | Rename-Item -newname { $_.name -replace '.exe','.zip' } -Force -ErrorAction Ignore
                    $IntelZip = Get-ChildItem -Path $ExpandPath 'Wired_driver_26.8_x64.zip' -Recurse
                    $ExpandPath = Join-Path $IntelZip.Directory $IntelZip.BaseName
                    Expand-Archive -Path $IntelZip.FullName -DestinationPath $ExpandPath -Force
                    $NDIS65 = Get-ChildItem -Path $ExpandPath -Directory -Recurse | Where-Object {$_.Name -match 'NDIS65'}
                    foreach ($Item in $NDIS65) {
                        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $Item.FullName -Recurse -ForceUnsigned -Verbose | Out-Null
                    }
                }
            }
            else {
                Write-Warning "Unable to connect to $IntelWiFiCloudDriverUrl"
            }
        }
        if ($Driver -eq 'WiFi') {
            Write-Host -ForegroundColor Yellow $IntelWiFiCloudDriverText
            if (Test-WebConnection -Uri $IntelWiFiCloudDriverUrl) {
                #$WiFiDownloads = (Invoke-WebRequest -Uri $IntelWiFiCloudDriverUrl -UseBasicParsing).Links
                #$WiFiDownloads = $WiFiDownloads | Where-Object {$_.download -match 'Driver64_Win10.zip'} | Sort-Object Download -Unique | Select-Object Download, Title -First 1
                #$SaveWebFile = Save-WebFile -SourceUrl $WiFiDownloads.download
                $SaveWebFile = Save-WebFile -SourceUrl $IntelWiFiCloudDriverUrl
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    Expand-Archive -Path $DriverCab -DestinationPath $ExpandPath -Force
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
            }
            else {
                Write-Warning "Unable to connect to $IntelWiFiCloudDriverUrl"
            }
        }
        if ($Driver -eq 'Nutanix') {
            Write-Host -ForegroundColor Yellow $NutanixCloudDriverText
            $HardwareIDDriverPath = Join-Path $env:TEMP (Get-Random)
            Save-MsUpCatDriver -HardwareID $NutanixCloudDriverHwids -DestinationDirectory $HardwareIDDriverPath
            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $HardwareIDDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        if ($Driver -eq 'NutanixOLD') {
            Write-Host -ForegroundColor Yellow $NutanixCloudDriverText
            if (Test-WebConnection -Uri $NutanixCloudDriverUrl) {
                    $SaveWebFile = Save-WebFile -SourceUrl $NutanixCloudDriverUrl
                 if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
            }
            else {
                Write-Warning "Unable to connect to $NutanixCloudDriverUrl"
            }
        }
        if ($Driver -eq 'USB') {
            Write-Host -ForegroundColor Yellow $UsbDongleHwidsText
            $HardwareIDDriverPath = Join-Path $env:TEMP (Get-Random)
            Save-MsUpCatDriver -HardwareID $UsbDongleHwids -DestinationDirectory $HardwareIDDriverPath
            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $HardwareIDDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        if ($Driver -eq 'VMware') {
            Write-Host -ForegroundColor Yellow $VmwareCloudDriverText
            $HardwareIDDriverPath = Join-Path $env:TEMP (Get-Random)
            Save-MsUpCatDriver -HardwareID $VmwareCloudDriverHwids -DestinationDirectory $HardwareIDDriverPath
            Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver $HardwareIDDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        if ($Driver -eq 'VMwareOLD') {
            Write-Host -ForegroundColor Yellow $VmwareCloudDriverText
            if (Test-WebConnection -Uri $VmwareCloudDriverUrl) {
                $SaveWebFile = Save-WebFile -SourceUrl $VmwareCloudDriverUrl
                if (Test-Path   $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned -Verbose | Out-Null
                }
            }
            else {
                Write-Warning "Unable to connect to $VmwareCloudDriverUrl"
            }
        }
        $null = Save-WindowsImage -Path $MountPath
    }
    #=================================================
    #   Drop initial Startnet.cmd
    #=================================================
    $OSDVersion = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    Write-Host -ForegroundColor DarkGray "Startnet.cmd: wpeinit"
$StartnetCMD = @"
@ECHO OFF
ECHO OSD $OSDVersion
ECHO Initialize WinPE
wpeinit
cd\
ECHO Initialize Hardware
start /wait PowerShell -Nol -W Mi -C Start-Sleep -Seconds 10
"@
    $StartnetCMD | Out-File -FilePath "$MountPath\Windows\System32\Startnet.cmd" -Encoding ascii -Width 2000 -Force
    #=================================================
    #   Wireless
    #=================================================
    if (Test-Path "$MountPath\Windows\WirelessConnect.exe") {
        Write-Host -ForegroundColor DarkGray 'Startnet.cmd: start PowerShell -NoL -C Start-WinREWiFi'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Initialize Wireless Network' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start /wait PowerShell -NoL -C Start-WinREWiFi' -Force
    }
    #=================================================
    #   Network Delay, Start Update, PowerShell Minimized
    #=================================================
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Initialize Network Connection (Minimized)' -Force
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start /wait PowerShell -Nol -W Mi -C Start-Sleep -Seconds 10' -Force
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Updating OSD PowerShell Module (Minimized)' -Force
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start /wait PowerShell -NoL -W Mi -C "& {if (Test-WebConnection) {Install-Module OSD -Force -Verbose}}"'
    #Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Installing Azure Modules for Accounts, KeyVault, and Storage (Minimized)' -Force
    #Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start /wait PowerShell -NoL -W Mi -C "& {if (Test-WebConnection) {Install-Module Az.KeyVault,Az.Storage -Force -Verbose}}"'
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Initialize PowerShell (Minimized)' -Force
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start PowerShell -Nol -W Mi' -Force
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    #=================================================
    #   StartPSCommand Wait
    #=================================================
    if ($StartPSCommand) {
        Write-Warning "The StartPSCommand parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"

        Write-Host -ForegroundColor DarkGray "Startnet.cmd: start /wait PowerShell -NoL -C `"$StartPSCommand`""
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C `"$StartPSCommand`"" -Force
    }
    #=================================================
    #   StartWebScript /wait
    #=================================================
    if ($StartWebScript) {
        Write-Warning "The StartWebScript parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"

        Write-Host -ForegroundColor DarkGray "Startnet.cmd: start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartWebScript'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'Invoke-WebPSScript' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartWebScript'" -Force
    }
    #=================================================
    #   StartOSDCloud /wait
    #=================================================
    if ($StartOSDCloud) {
        Write-Warning "The StartOSDCloud parameter is adding Start-OSDCloud to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "Startnet.cmd: start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloud' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #=================================================
    #   StartOSDCloudGUI /wait
    #=================================================
    if ($StartOSDCloudGUI) {
        Write-Warning "The StartOSDCloudGUI parameter is adding Start-OSDCloudGUI to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray 'Startnet.cmd: start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloudGUI' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #=================================================
    #   StartOSDPad /wait
    #=================================================
    if ($StartOSDPad) {
        Write-Warning "The StartOSDPad parameter is adding OSDPad to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "Startnet.cmd: start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO OSDPad' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
    }

    if ($Startnet) {
        Write-Warning "The Startnet string is added to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloud.winpe or it will revert back to defaults"

        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value $Startnet -Force
    }
    if ($StartOSDCloud -or $StartOSDCloudGUI -or $StartWebScript -or $StartOSDPad -or $Startnet){
        #Do Nothing
    }
    else {
        Write-Host -ForegroundColor DarkGray "Startnet.cmd: start PowerShell -NoL"

        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start PowerShell' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start PowerShell -NoL' -Force
    }
    #=================================================
    #   Wallpaper
    #=================================================
    if ($Wallpaper) {
        Write-Host -ForegroundColor DarkGray "Wallpaper: $Wallpaper"
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winpe.jpg" -Force | Out-Null
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winre.jpg" -Force | Out-Null
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /b /np /r:0 /w:0
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /b /np /r:0 /w:0
    }
    #=================================================
    #   Update OSD Module
    #=================================================
    Write-Host -ForegroundColor DarkGray "Saving OSD Module to $MountPath\Program Files\WindowsPowerShell\Modules"
    Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    if ($AddAzure.IsPresent) {
        Write-Host -ForegroundColor DarkGray "Saving Azure Modules to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name Az.Accounts -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name Az.Storage -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Write-Host -ForegroundColor DarkGray "Saving AzCopy to $MountPath\Windows"
        $AzCopy = Save-WebFile -SourceUrl (Invoke-WebRequest -UseBasicParsing 'https://aka.ms/downloadazcopy-v10-windows' -MaximumRedirection 0 -ErrorAction SilentlyContinue).headers.location
        if ($AzCopy) {
            Expand-Archive -Path $AzCopy.FullName -DestinationPath $env:windir\Temp\AzCopy -Force
            Get-ChildItem -Path $env:windir\Temp\AzCopy -Recurse -Include azcopy.exe | foreach {Copy-Item $_.FullName -Destination "$MountPath\Windows\azcopy.exe" -Force -ErrorAction SilentlyContinue}
        }
    }
    if ($AddAws.IsPresent) {
        Write-Host -ForegroundColor DarkGray "Saving AWS Modules to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name AWS.Tools.Common "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name AWS.Tools.S3 -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #=================================================
    #   PSModuleInstall
    #=================================================
    foreach ($Module in $PSModuleInstall) {
        if ($Module -eq 'DellBiosProvider') {
            if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                Write-Host -ForegroundColor DarkGray "Copying $env:SystemRoot\System32\msvcp140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\msvcp140.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\vcruntime140.dll") {
                Write-Host -ForegroundColor DarkGray "Copying $env:SystemRoot\System32\vcruntime140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                Write-Host -ForegroundColor DarkGray "Copying $env:SystemRoot\System32\vcruntime140_1.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140_1.dll" -Destination "$MountPath\System32" -Force | Out-Null
            }
        }
        Write-Host -ForegroundColor DarkGray "Saving $Module to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #=================================================
    #   PSModuleCopy
    #=================================================
    foreach ($Module in $PSModuleCopy) {
        Write-Host -ForegroundColor DarkGray "Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath"
        Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath
    }
    #=================================================
    #   Save WIM
    #=================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=================================================
    #	Complete
    #=================================================
    $WinpeEndTime = Get-Date
    $WinpeTimeSpan = New-TimeSpan -Start $WinpeStartTime -End $WinpeEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WinpeTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
}