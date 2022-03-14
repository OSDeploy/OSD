function Save-WinPECloudDriver {
    <#
    .SYNOPSIS
    Download and expand WinPE Drivers
    
    .DESCRIPTION
    Download and expand WinPE Drivers
    This function must be run in Windows
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.IO.FileInfo])]
    param (
        [System.String[]]
        #WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi
        [ValidateSet('*','Dell','HP','IntelNet','LenovoDock','Surface','Nutanix','USB','VMware','WiFi')]
        $CloudDriver,

        [System.String[]]
        #WinPE Driver: HardwareID of the Driver download from Microsoft Catalog
        [Alias('HardwareID')]
        $DriverHWID,

        [System.String]
        #WinPE Driver: Destination path to save the drivers
        #If not specified, a random directory in $env:TEMP is selected
        $Path
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	CloudDriver
    #=================================================
    if ($CloudDriver -contains '*') {
        $CloudDriver = @('Dell','HP','IntelNet','LenovoDock','Nutanix','Surface','USB','VMware','WiFi')
    }

    $DellCloudDriverText                = 'Dell WinPE Driver Pack'
    $DellCloudDriverPack                = Get-DellWinPEDriverPack
    
    $HpCloudDriverText                  = 'HP WinPE Driver Pack'
    $HpCloudDriverPack                  = Get-HpWinPEDriverPack

    $OSDCatalogIntelEthernetDriver      = Get-OSDCatalogIntelEthernetDriver | `
                                        Where-Object {($_.OSVersion -match '10.0')} | `
                                        Where-Object {($_.OSArch -match 'x64')} | `
                                        Select-Object -First 1
    $IntelEthernetCloudDriverUrl        = $OSDCatalogIntelEthernetDriver.DriverUrl
    $IntelEthernetCloudDriverVersion    = $OSDCatalogIntelEthernetDriver.DriverVersion
    $IntelEthernetCloudDriverText       = "Intel Ethernet Driver Pack [$IntelEthernetCloudDriverVersion] $IntelEthernetCloudDriverUrl"

    $OSDCatalogIntelWirelessDriver      = Get-OSDCatalogIntelWirelessDriver | `
                                        Where-Object {($_.OSVersion -match '10.0')} | `
                                        Where-Object {($_.OSArch -match 'x64')} | `
                                        Select-Object -First 1
    $IntelWiFiCloudDriverUrl            = $OSDCatalogIntelWirelessDriver.DriverUrl
    $IntelWiFiCloudDriverVersion        = $OSDCatalogIntelWirelessDriver.DriverVersion
    $IntelWiFiCloudDriverText           = "Intel Wireless Driver Pack [$IntelWiFiCloudDriverVersion] $IntelWiFiCloudDriverUrl"

    $LenovoCloudDriverText              = 'Lenovo WinPE Driver Pack'
    $LenovoCloudDriverPacks             = @(
                                        'https://pcsupport.lenovo.com/downloads/DS105415'
                                        'https://pcsupport.lenovo.com/downloads/DS542093'
                                        'https://pcsupport.lenovo.com/downloads/DS542998'
                                        'https://support.lenovo.com/downloads/DS104737'
                                        'https://support.lenovo.com/downloads/DS105119'
                                        'https://support.lenovo.com/downloads/DS105977'
                                        'https://support.lenovo.com/downloads/DS106048'
                                        'https://support.lenovo.com/downloads/DS106096'
                                        'https://support.lenovo.com/downloads/DS112079'
                                        'https://support.lenovo.com/downloads/DS112425'
                                        'https://support.lenovo.com/downloads/DS113152'
                                        'https://support.lenovo.com/downloads/DS119040'
                                        'https://support.lenovo.com/downloads/DS119264'
                                        'https://support.lenovo.com/downloads/DS119270'
                                        'https://support.lenovo.com/downloads/DS119281'
                                        'https://support.lenovo.com/downloads/DS120413'
                                        'https://support.lenovo.com/downloads/DS120934'
                                        'https://support.lenovo.com/downloads/DS500698'
                                        'https://support.lenovo.com/downloads/DS500699'
                                        'https://support.lenovo.com/downloads/DS500715'
                                        'https://support.lenovo.com/downloads/DS500728'
                                        'https://support.lenovo.com/downloads/DS500738'
                                        'https://support.lenovo.com/downloads/DS501356'
                                        'https://support.lenovo.com/downloads/DS501531'
                                        'https://support.lenovo.com/downloads/DS502154'
                                        'https://support.lenovo.com/downloads/DS502454'
                                        'https://support.lenovo.com/downloads/DS503363'
                                        'https://support.lenovo.com/downloads/DS503944'
                                        'https://support.lenovo.com/downloads/DS504611'
                                        'https://support.lenovo.com/downloads/DS504613'
                                        'https://support.lenovo.com/downloads/DS505256'
                                        'https://support.lenovo.com/downloads/DS505931'
                                        'https://support.lenovo.com/downloads/DS541513'
                                        'https://support.lenovo.com/downloads/DS542109'
                                        'https://support.lenovo.com/downloads/DS543834'
                                        'https://support.lenovo.com/downloads/DS544286'
                                        'https://support.lenovo.com/downloads/DS545020'
                                        'https://support.lenovo.com/downloads/DS545687'
                                        'https://support.lenovo.com/downloads/DS546529'
                                        'https://support.lenovo.com/downloads/DS547277'
                                        'https://support.lenovo.com/downloads/DS547601'
                                        'https://support.lenovo.com/downloads/DS547827'
                                        'https://support.lenovo.com/downloads/DS548453'
                                        'https://support.lenovo.com/downloads/DS549669'
                                        'https://support.lenovo.com/downloads/DS549738'
                                        'https://support.lenovo.com/downloads/DS551195'
                                        'https://support.lenovo.com/downloads/DS551368'
                                        'https://support.lenovo.com/downloads/DS554384'
                                        'https://support.lenovo.com/downloads/ds504277'
                                    )

    $LenovoDockCloudDriverText          = 'Lenovo Dock WinPE Driver Pack [22.1.31]'
    $LenovoDockCloudDriverUrl           = @(
                                        'https://download.lenovo.com/pccbbs/mobiles/rtk-winpe-w10.zip'
                                        'https://download.lenovo.com/km/media/attachment/USBCG2.zip'
                                        )

    $NutanixCloudDriverText             = 'Nutanix WinPE Driver Pack [Microsoft Catalog]'
    $NutanixCloudDriverHwids            = @(
                                        'VEN_1AF4&DEV_1000 and VEN_1AF4&DEV_1041' #Red Hat Nutanix VirtIO Ethernet Adapter
                                        'VEN_1AF4&DEV_1002' #Red Hat Nutanix VirtIO Balloon
                                        'VEN_1AF4&DEV_1004 and VEN_1AF4&DEV_1048' #Red Hat Nutanix VirtIO SCSI pass-through controller
                                        )

                                        #https://docs.microsoft.com/en-us/surface/enable-surface-keyboard-for-windows-pe-deployment
    $SurfaceCloudDriverText             = 'Surface WinPE Driver Pack [Microsoft Catalog]'
    $SurfaceCloudDriverHwids            = @(
                                        'MSHW0028' #Button and MSHW0040
                                        'MSHW0084' #Serial Hub
                                        'MSHW0091' #ACPI Notify
                                        'MSHW0094' #Null
                                        'MSHW0096' #Keyboard
                                        'MSHW0146' #Battery
                                        'MSHW0153' #HotPlug
                                        'MSHW0184' #Light Sensor
                                        'VEN_8086&DEV_A0D0 VEN_8086&DEV_43D0 VEN_8086&DEV_A0D1 VEN_8086&DEV_43D1' #Touch
                                        )
    
    $UsbDongleHwidsText                 = 'USB Dongle Driver Pack [Microsoft Catalog]'
    $UsbDongleHwids                     = @(
                                        'VID_045E&PID_0927 VID_045E&PID_0927 VID_045E&PID_09A0 Surface Ethernet'
                                        'VID_0B95&PID_7720 VID_0B95&PID_7E2B Asix AX88772 USB2.0 to Fast Ethernet'
                                        'VID_0B95&PID_1790 ASIX AX88179 USB 3.0 to Gigabit Ethernet'
                                        'VID_0BDA&PID_8153 Realtek USB GbE and Dell DA 300'
                                        'VID_13B1&PID_0041'
                                        'VID_17EF&PID_720C Lenovo USB-C Ethernet'
                                        )
    
    $VmwareCloudDriverText              = 'VMware WinPE Driver Pack [Microsoft Catalog]'
    $VmwareCloudDriverHwids             = @(
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
    #   DriverHWID
    #=================================================
    foreach ($Item in $DriverHWID) {
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

            if (Test-WebConnection -Uri $DellCloudDriverPack) {
               $DriverPackDownload = Save-WebFile -SourceUrl $DellCloudDriverPack

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
                Write-Warning "Unable to connect to $DellCloudDriverPack"
         }
        }
        #=================================================
        #   HP
        #=================================================
        if ($DriverPack -eq 'HP') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $HpCloudDriverText"

            if (Test-WebConnection -Uri $HpCloudDriverPack)   {
              $DriverPackDownload = Save-WebFile -SourceUrl $HpCloudDriverPack

                if (Test-Path $DriverPackDownload.FullName) {
                    $DriverPackItem = Get-Item -Path $DriverPackDownload.FullName
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)

                    Start-Process -FilePath $DriverPackItem -ArgumentList "/s /e /f `"$DriverPackExpand`"" -Wait
                }
            }
            else {  
                Write-Warning "Unable to connect to $HpCloudDriverPack"  
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
                    $DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)
                    Expand-Archive -Path $DriverPackItem -DestinationPath $DriverPackExpand -Force

                    #$DriverPackExpand = Join-Path $DriverPackItem.Directory $DriverPackItem.BaseName
                    #Expand-Archive -Path $DriverPackItem -DestinationPath $DriverPackExpand -Force
                    #$IntelExe = Get-ChildItem -Path $DriverPackExpand 'Wired_driver_26.8_x64.exe'
                    #$IntelExe | Rename-Item -newname { $_.name -replace '.exe','.zip' } -Force -ErrorAction Ignore
                    #$DriverPackItem = Get-ChildItem -Path $DriverPackExpand 'Wired_driver_26.8_x64.zip' -Recurse
                    #$DriverPackExpand = Join-Path $DriverPackItem.Directory $DriverPackItem.BaseName
                    #$DriverPackExpand = Join-Path $Path (Join-Path $DriverPack $DriverPackItem.BaseName)
                    #Expand-Archive -Path $DriverPackItem.FullName -DestinationPath $DriverPackExpand -Force
                    $RemoveItems = Get-ChildItem -Path $DriverPackExpand -Directory -Recurse | Where-Object {$_.Name -in @('APPS','DDP_Profiles','DOCS','NDIS63','NDIS64','NVMUpdatePackage','RDMA')}
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
        #   Nutanix
        #=================================================
        if ($DriverPack -eq 'Nutanix') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $NutanixCloudDriverText"
            Save-MsUpCatDriver -HardwareID $NutanixCloudDriverHwids -DestinationDirectory (Join-Path $Path $DriverPack)
        }
        #=================================================
        #   Surface
        #=================================================
        if ($DriverPack -eq 'Surface') {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $SurfaceCloudDriverText"
            Save-MsUpCatDriver -HardwareID $SurfaceCloudDriverHwids -DestinationDirectory (Join-Path $Path $DriverPack)
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
    #=================================================
}