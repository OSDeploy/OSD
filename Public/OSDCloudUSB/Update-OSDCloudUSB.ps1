function Update-OSDCloudUSB {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-StandardUser
    #=================================================
    #	USB WinPE Volumes
    #=================================================
    $OSDCloudWorkspace = Get-OSDCloud.workspace
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $UsbVolumes = Get-Volume.usb
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB Volumes found"

        $WinpeOSDVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
        if ($WinpeOSDVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
            foreach ($WinpeOSDVolume in $WinpeOSDVolumes) {
                Set-Volume -DriveLetter $WinpeOSDVolume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        $WinpeVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'WinPE'}
        if ($WinpeVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud USB WinPE volume label is set properly to WinPE"

            if ($OSDCloudWorkspace) {
                foreach ($WinpeVolume in $WinpeVolumes) {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\Media to $($WinpeVolume.DriveLetter):\"
                    robocopy "$OSDCloudWorkspace\Media" "$($WinpeVolume.DriveLetter):\" *.* /e /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any OSDCloud USB Volumes"
    }
    #=================================================
    #	USB OSDCloud Volumes
    #=================================================
    if ($OSDCloudWorkspace) {
        $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}

        foreach ($OSDCloudVolume in $OSDCloudVolumes) {
            if (Test-Path "$OSDCloudWorkspace\Autopilot") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\Autopilot to $($OSDCloudVolume.DriveLetter):\OSDCloud\Autopilot"
                robocopy "$OSDCloudWorkspace\Autopilot" "$($OSDCloud):\OSDCloud\Autopilot" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
            if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\DriverPacks to $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks"
                robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }        
            if (Test-Path (Join-Path $OSDCloudWorkspace 'OS')) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\OS to $($OSDCloudVolume.DriveLetter):\OSDCloud\OS"
                robocopy "$OSDCloudWorkspace\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
            if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\PowerShell to $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"
                robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
    Write-Host -ForegroundColor DarkGray "========================================================================="
}