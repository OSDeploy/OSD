function Import-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,ValueFromPipelineByPropertyName,Mandatory)]
        [System.String]$WorkspacePath
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $UsbVolumes = Get-Volume.usb
    #=================================================
    #	USB Volumes
    #=================================================
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB Volumes"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }
    #=================================================
    #	Workspace
    #================================================
    if (Test-Path $WorkspacePath) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace already exists at $WorkspacePath"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Content will be overwritten"
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-Item $WorkspacePath"
        try {
            $null = New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create an OSDCloud Workspace at $WorkspacePath"
            Break
        }
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}

    if ($WinpeVolumes) {
        foreach ($WinpeVolume in $WinpeVolumes) {
            if (Test-Path -Path "$($WinPEVolume.DriveLetter):\") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\ to $WorkspacePath\Media"
                robocopy "$($WinPEVolume.DriveLetter):\" "$WorkspacePath\Media" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB WinPE volume"
        Break
    }

    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}

    if ($OSDCloudVolumes) {
        foreach ($OSDCloudVolume in $OSDCloudVolumes) {
            
            if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\Config to OSDCloud Workspace $WorkspacePath\Config"
                robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" "$WorkspacePath\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks to OSDCloud Workspace $WorkspacePath\DriverPacks"
                robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" "$WorkspacePath\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\OS to OSDCloud Workspace $WorkspacePath\OS"
                robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" "$WorkspacePath\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell to OSDCloud Workspace $WorkspacePath\PowerShell"
                robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" "$WorkspacePath\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB volume"
        Break
    }

    $null = Set-OSDCloud.workspace -WorkspacePath $WorkspacePath
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Import-OSDCloudUSB is complete"
    #=================================================
}