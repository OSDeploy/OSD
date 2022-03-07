function Save-WinPECloudDriver {
    [CmdletBinding()]
    param (
        [ValidateSet('*','Dell','HP','IntelNet','LenovoDock','Nutanix','USB','VMware','WiFi')]
        [System.String[]]$CloudDriver,
        [System.String[]]$HardwareID,
        [System.String]$Path,
        [System.Management.Automation.SwitchParameter]$Clipboard
    )
    #=================================================
    #	Cloud Drivers
    #=================================================
    if ($CloudDriver -contains '*') {
        $CloudDriver = @('Dell','HP','IntelNet','LenovoDock','Nutanix','USB','VMware','WiFi')
    }

    $DellCloudDriverText            = 'Dell WinPE Driver Pack [A25]'
    $DellCloudDriverUrl             = 'http://downloads.dell.com/FOLDER07703466M/1/WinPE10.0-Drivers-A25-F0XPX.CAB'
    
    $HpCloudDriverText              = 'HP WinPE Driver Pack [2.0]'
    $HpCloudDriverUrl               = 'https://ftp.hp.com/pub/softpaq/sp112501-113000/sp112810.exe'

    $IntelEthernetCloudDriverText   = 'Intel Ethernet Driver Pack [26.8]'
    $IntelEthernetCloudDriverUrl    = 'https://downloadmirror.intel.com/710138/Wired_driver_26.8_x64.zip'
    
    $IntelWiFiCloudDriverText       = 'Intel Wireless Driver Pack [22.80.1]'
    $IntelWiFiCloudDriverUrl        = 'https://downloadmirror.intel.com/714401/WiFi-22.110.1-Driver64-Win10-Win11.zip'
    
    $LenovoDockCloudDriverText      = 'Lenovo Dock WinPE Driver Pack [22.1.31]'
    $LenovoDockCloudDriverUrl       = @(
                                        'https://download.lenovo.com/pccbbs/mobiles/rtk-winpe-w10.zip'
                                        'https://download.lenovo.com/km/media/attachment/USBCG2.zip'
                                        )

    $NutanixCloudDriverText         = 'Nutanix WinPE Driver Pack [Microsoft Catalog]'
    $NutanixCloudDriverHwids         = @(
                                        'VEN_1AF4&DEV_1000 and VEN_1AF4&DEV_1041' #Red Hat Nutanix VirtIO Ethernet Adapter
                                        'VEN_1AF4&DEV_1002' #Red Hat Nutanix VirtIO Balloon
                                        'VEN_1AF4&DEV_1004 and VEN_1AF4&DEV_1048' #Red Hat Nutanix VirtIO SCSI pass-through controller
                                        )
    
    $UsbDongleHwidsText             = 'USB Dongle Driver Pack [Microsoft Catalog]'
    $UsbDongleHwids                 = @(
                                        'VID_045E&PID_0927 VID_045E&PID_0927 VID_045E&PID_09A0 Surface Ethernet'
                                        'VID_0B95&PID_7720 VID_0B95&PID_7E2B Asix AX88772 USB2.0 to Fast Ethernet'
                                        'VID_0B95&PID_1790 ASIX AX88179 USB 3.0 to Gigabit Ethernet'
                                        'VID_0BDA&PID_8153 Realtek USB GbE and Dell DA 300'
                                        'VID_13B1&PID_0041'
                                        'VID_17EF&PID_720C Lenovo USB-C Ethernet'
                                        )
    
    $VmwareCloudDriverText          = 'VMware WinPE Driver Pack [Microsoft Catalog]'
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
    Block-NoInternet
    #=================================================
    #   Path
    #=================================================
    if (-not $Path) {
        $Path = Join-Path $env:TEMP (Get-Random)
        Write-Warning "Path was not specified, defaulting to $Path"
    }
    If (-not (Test-Path $Path)) {
        try {
            $null = New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop
        }
        catch {
            Write-Error $_
            Break
        }
    }
    #=================================================
    #   HardwareID
    #=================================================
    foreach ($Item in $HardwareID) {
        Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory (Join-Path $Path 'HardwareID')
    }
    #=================================================
    #   CloudDriver
    #=================================================
    foreach ($DriverPack in $CloudDriver) {
        #=================================================
        #   Dell
        #=================================================
        if ($DriverPack -eq 'Dell'){
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $DellCloudDriverText"

            if (Test-WebConnection -Uri $DellCloudDriverUrl) {
                $DriverPackDownload = Save-WebFile -SourceUrl $DellCloudDriverUrl

                if (Test-Path $DriverPackDownload.FullName) {
                    $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)
            
                    if (-NOT (Test-Path $DriverPackExpand)) {
                        New-Item -Path $DriverPackExpand -ItemType Directory -Force | Out-Null
                    }

                    Expand -R "$($DriverPackItem.FullName)" -F:* "$DriverPackExpand" | Out-Null
                    $null = Remove-Item -Path "$DriverPackExpand\winpe\x86" -Recurse
                }
            }
            else {
                Write-Warning "Unable to connect to $DellCloudDriverUrl"
            }
        }
        #=================================================
        #   HP
        #=================================================
        if ($DriverPack -eq 'HP') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $HpCloudDriverText"

            if (Test-WebConnection -Uri $HpCloudDriverUrl)   {
              $DriverPackDownload = Save-WebFile -SourceUrl $HpCloudDriverUrl

                if (Test-Path $DriverPackDownload.FullName) {
                    $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)

                    Start-Process -FilePath $DriverPackItem -ArgumentList "/s /e /f `"$DriverPackExpand`"" -Wait
                }
            }
            else {  
                Write-Warning "Unable to connect to $HpCloudDriverUrl"  
            }
        }
        #=================================================
        #   LenovoDock
        #=================================================
        if ($DriverPack -eq 'LenovoDock') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $LenovoDockCloudDriverText"

            foreach ($OnlineDriver in $LenovoDockCloudDriverUrl) {
                if (Test-WebConnection -Uri $OnlineDriver) {
                    $DriverPackDownload = Save-WebFile -SourceUrl $OnlineDriver

                    if (Test-Path $DriverPackDownload.FullName) {
                        $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                        $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)

                        Expand-Archive -Path $DriverPackItem -DestinationPath $DriverPackExpand -Force
                        Get-ChildItem -Path "$DriverPackExpand\WIN10\32" | Remove-Item -Recurse -Force
                    }
                }
                else {
                    Write-Warning "Unable to connect to $LenovoDockCloudDriverUrl"
                }
            }
        }
        #=================================================
        #   Intel Ethernet
        #=================================================
        if ($DriverPack -eq 'IntelNet') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $IntelEthernetCloudDriverText"

            if (Test-WebConnection -Uri $IntelEthernetCloudDriverUrl)   {
                $DriverPackDownload = Save-WebFile -SourceUrl $IntelEthernetCloudDriverUrl
                   if (Test-Path $DriverPackDownload.FullName) {
                    $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                    $DriverPackExpand = Join-Path $DriverPackItem.Directory $DriverPackItem.BaseName
                    Expand-Archive -Path $DriverPackItem -DestinationPath $DriverPackExpand -Force
                    $IntelExe = Get-ChildItem -Path $DriverPackExpand 'Wired_driver_26.8_x64.exe'
                    $IntelExe | Rename-Item -newname { $_.name -replace '.exe','.zip' } -Force -ErrorAction Ignore
                    $DriverPackItem = Get-ChildItem -Path $DriverPackExpand 'Wired_driver_26.8_x64.zip' -Recurse
                    #$DriverPackExpand = Join-Path $DriverPackItem.Directory $DriverPackItem.BaseName
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)
                    Expand-Archive -Path $DriverPackItem.FullName -DestinationPath $DriverPackExpand -Force
                    $RemoveItems = Get-ChildItem -Path $DriverPackExpand -Directory -Recurse | Where-Object {$_.Name -in @('APPS','NDIS63','NDIS64')}
                    foreach ($Item in $RemoveItems) {
                        Remove-Item $Item.FullName -Recurse -Force -ErrorAction Ignore
                    }
                }
            }
            else {
                Write-Warning "Unable to connect to $IntelEthernetCloudDriverUrl"
            }
        }
        #=================================================
        #   Intel WiFi
        #=================================================
        if ($DriverPack -eq 'WiFi') {
            Write-Host -ForegroundColor Yellow $IntelWiFiCloudDriverText
            if (Test-WebConnection -Uri $IntelWiFiCloudDriverUrl) {
                $DriverPackDownload = Save-WebFile -SourceUrl $IntelWiFiCloudDriverUrl
                if (Test-Path $DriverPackDownload.FullName) {
                    $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)
                    Expand-Archive -Path $DriverPackItem -DestinationPath $DriverPackExpand -Force
                }
            }
            else {
                Write-Warning "Unable to connect to $IntelWiFiCloudDriverUrl"
            }
        }
        #=================================================
        #   Nutanix
        #=================================================
        if ($DriverPack -eq 'Nutanix') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $NutanixCloudDriverText"
            Save-MsUpCatDriver -HardwareID $NutanixCloudDriverHwids -DestinationDirectory (Join-Path $Path $DriverPack)
        }
        #=================================================
        #   USB Dongles
        #=================================================
        if ($DriverPack -eq 'USB') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $UsbDongleHwidsText"
            Save-MsUpCatDriver -HardwareID $UsbDongleHwids -DestinationDirectory (Join-Path $Path $DriverPack)
        }
        #=================================================
        #   VMware
        #=================================================
        if ($DriverPack -eq 'VMware') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $VmwareCloudDriverText"
            Save-MsUpCatDriver -HardwareID $VmwareCloudDriverHwids -DestinationDirectory (Join-Path $Path $DriverPack)
        }
    }
    #=================================================
    #   Complete
    #=================================================
    $DriverPath = Get-Item $Path
    if ($Clipboard) {
        Set-Clipboard -Value $DriverPath.FullName -Verbose
    }
    Return $DriverPath
}