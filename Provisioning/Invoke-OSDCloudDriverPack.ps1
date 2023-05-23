#=================================================
#region Start Transcript
if (Test-Path "$env:Windir\debug") {
    $Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Invoke-OSDCloudDriverPack.log"
    Start-Transcript -Path (Join-Path "$env:Windir\debug" $Global:Transcript) -ErrorAction Ignore
}
#endregion
#=================================================
#region Apply OSDCloud DriverPack
if (Test-Path 'C:\Drivers') {
    $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

    foreach ($Item in $DriverPacks) {
        if ($Item.Extension -eq '.ppkg') {
            Write-Host "Applying Provisioning Package at $($Item.FullName)"
            #$ArgumentList = "/Online /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
            #Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow

            dism.exe /Online /Add-ProvisioningPackage /PackagePath:"$($Item.FullName)"

            schtasks /Change /TN "Microsoft\Windows\Management\Provisioning\Retry" /Enable

            schtasks /Query
            Continue
        }

        $ExpandFile = $Item.FullName
        Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Reviewing $ExpandFile"

        $DestinationPath = Join-Path $Item.Directory $Item.BaseName
        #=================================================
        #   Zip
        #=================================================
        if ($Item.Extension -eq '.zip') {
            Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for ZIP file"

            if (Test-Path "$DestinationPath") {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has already been extracted"
            }
            else {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding ZIP DriverPack to $DestinationPath"
                Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force

                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying DriverPack with PNPUNATTEND"
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=================================================
        #   Cab
        #=================================================
        if ($Item.Extension -eq '.cab') {
            Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for CAB file"

            if (Test-Path "$DestinationPath") {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has already been extracted"
            }
            else {
                New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding CAB DriverPack to $DestinationPath"
                Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null

                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying DriverPack with PNPUNATTEND"
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=================================================
        #   Dell EXE
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if ($Item.VersionInfo.FileDescription -match 'Dell') {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for Dell EXE file"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ProductVersion: $($Item.VersionInfo.ProductVersion)"

                if (Test-Path "$DestinationPath") {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has already been extracted"
                }
                else {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding Dell DriverPack to $DestinationPath"
                    $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                    Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait

                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying DriverPack with PNPUNATTEND"
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=================================================
        #   HP
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if (($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($Item.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($Item.VersionInfo.FileDescription -like "HP *")) {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for HP EXE file"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ProductVersion: $($Item.VersionInfo.ProductVersion)"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) InternalName: $($Item.VersionInfo.InternalName)"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OriginalFilename: $($Item.VersionInfo.OriginalFilename)"

                if (Test-Path "$DestinationPath") {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has already been extracted"
                }
                else {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding HP DriverPack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait

                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying DriverPack with PNPUNATTEND"
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=================================================
        #   Lenovo
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if (($Item.VersionInfo.FileDescription -match 'Lenovo') -or ($Item.Name -match 'tc_') -or ($Item.Name -match 'tp_') -or ($Item.Name -match 'ts_') -or ($Item.Name -match '500w') -or ($Item.Name -match 'sccm_') -or ($Item.Name -match 'm710e') -or ($Item.Name -match 'tp10') -or ($Item.Name -match 'tp8') -or ($Item.Name -match 'yoga')) {
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for Lenovo EXE file"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ProductVersion: $($Item.VersionInfo.ProductVersion)"

                $DestinationPath = Join-Path $Item.Directory 'SCCM'

                if (Test-Path "$DestinationPath") {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has already been extracted"
                }
                else {
                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding Lenovo DriverPack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait

                    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying DriverPack with PNPUNATTEND"
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=================================================
        #   MSI
        #=================================================
        if ($Item.Extension -eq '.msi') {
            Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for MSI file"

            $DateStamp = Get-Date -Format yyyyMMddTHHmmss
            $logFile = '{0}-{1}.log' -f $ExpandFile,$DateStamp
            $MSIArguments = @(
                "/i"
                ('"{0}"' -f $ExpandFile)
                "/qb"
                "/norestart"
                "/L*v"
                $logFile
            )
            Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
            Continue
        }
        #=================================================
        #   Everything Else
        #=================================================
        Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) File does not appear to be a DriverPack"
        #=================================================
    }
}
#=================================================
#region End Transcript
if (Test-Path "$env:Windir\debug") {
    Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================