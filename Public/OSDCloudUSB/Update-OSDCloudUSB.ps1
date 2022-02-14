function Update-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [switch]$Mirror
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $UsbVolumes = Get-Volume.usb
    $OSDCloudWorkspace = Get-OSDCloud.workspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	Robocopy Switches
    #   Still working on this
    #=================================================
    if ($IsAdmin -and $Mirror) {
        $RobocopySwitches = '/mir /ndl /njh /njs /np /r:0 /w:0 /b /zb'
    }
    elseif ($IsAdmin) {
        $RobocopySwitches = '/e /ndl /njh /njs /np /r:0 /w:0 /b /zb'
    }
    elseif ($Mirror) {
        $RobocopySwitches = '/mir /ndl /njh /njs /np /r:0 /w:0'
    }
    else {
        $RobocopySwitches = '/e /ndl /njh /njs /np /r:0 /w:0'
    }
    #=================================================
    #	USB Volumes
    #=================================================
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB Volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You may need to run New-OSDCloudUSB first"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }
    #=================================================
    #	Set USB Volume Label
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}

    if ($WinpeVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
        if ($IsAdmin) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                Set-Volume -DriveLetter $WinpeVolume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB WinPE volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    $WinpeVolumes = Get-Volume.usb | Where-Object {($_.FileSystemLabel -eq 'WinPE') -or ($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
    if ($WinpeVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud USB WinPE volume label is set properly to WinPE"

        if ($OSDCloudWorkspace) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $OSDCloudWorkspace\Media to $($WinpeVolume.DriveLetter):\"
                if ($IsAdmin) {
                    robocopy "$OSDCloudWorkspace\Media" "$($WinpeVolume.DriveLetter):\" *.* /e /ndl /np /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /b /zb
                }
                else {
                    robocopy "$OSDCloudWorkspace\Media" "$($WinpeVolume.DriveLetter):\" *.* /e /ndl /np /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace to update WinPE"
        }
    }
    #=================================================
    #	Update PowerShell Modules
    #=================================================
    if ($OSDCloudWorkspace -and (Test-Path $OSDCloudWorkspace)) {
        if (-not (Test-Path "$OSDCloudWorkspace\PowerShell")) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $OSDCloudWorkspace\PowerShell"
            $null = New-Item -Path "$OSDCloudWorkspace\PowerShell\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$OSDCloudWorkspace\PowerShell\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$OSDCloudWorkspace\PowerShell\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$OSDCloudWorkspace\PowerShell\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
        }
    
        try {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules at $OSDCloudWorkspace\PowerShell"
            Save-Module OSD,WindowsAutoPilotIntune -Path "$OSDCloudWorkspace\PowerShell\Offline\Modules"
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the PowerShell content at $OSDCloudWorkspace\PowerShell"
        }
    }
    #=================================================
    #	USB OSDCloud Volumes
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}

    if ($OSDCloudWorkspace -and (Test-Path $OSDCloudWorkspace) -and $OSDCloudVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud USB volumes found"
        foreach ($OSDCloudVolume in $OSDCloudVolumes) {

            if (Test-Path "$OSDCloudWorkspace\Config") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $OSDCloudWorkspace\Config to $($OSDCloudVolume.DriveLetter):\OSDCloud\Config"
                if ($IsAdmin) {
                    robocopy "$OSDCloudWorkspace\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$OSDCloudWorkspace\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $OSDCloudWorkspace\DriverPacks to $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks"
                if ($IsAdmin) {
                    robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$OSDCloudWorkspace\OS") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $OSDCloudWorkspace\OS $($OSDCloudVolume.DriveLetter):\OSDCloud\OS"
                if ($IsAdmin) {
                    robocopy "$OSDCloudWorkspace\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$OSDCloudWorkspace\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $OSDCloudWorkspace\PowerShell to $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"
                if ($IsAdmin) {
                    robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
    }
    #=================================================
    #	Save Driver Packs
    #=================================================
















    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
}