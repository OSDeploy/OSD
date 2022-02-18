<#
.SYNOPSIS
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.Description
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.EXAMPLE
Update-OSDCloudUSB -WorkspacePath C:\OSDCloud

.LINK
https://osdcloud.osdeploy.com
#>
function Update-OSDCloudUSBv1 {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath,

        [switch]$Offline
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Update-OSDCloudUSB              Update WinPE"
    Write-Host -ForegroundColor Yellow "Update-OSDCloudUSB -Offline     Update WinPE and Offline content"
    $UsbVolumes = Get-Volume.usb
    $WorkspacePath = Get-OSDCloud.workspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
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
        Write-Host -ForegroundColor DarkGray "========================================================================="
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
    #	WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop

    if (-NOT ($WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}

    foreach ($WinpeVolume in $WinpeVolumes) {
        if ((Test-Path -Path "$WorkspacePath\Media") -and (Test-Path -Path "$($WinPEVolume.DriveLetter):\")) {
            if ($IsAdmin) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Admin Copying $WorkspacePath\Media to OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\"
                robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
            }
            else {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\"
                robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    #=================================================
    #   PowerShell
    #=================================================
    if ($PSBoundParameters.ContainsKey('Offline')) {
        if ($WorkspacePath -and (Test-Path $WorkspacePath)) {
            if (-not (Test-Path "$WorkspacePath\PowerShell")) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
                $null = New-Item -Path "$WorkspacePath\PowerShell\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $null = New-Item -Path "$WorkspacePath\PowerShell\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                $null = New-Item -Path "$WorkspacePath\PowerShell\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $null = New-Item -Path "$WorkspacePath\PowerShell\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            }
    
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules at $WorkspacePath\PowerShell"
        
            try {
                Save-Module OSD -Path "$WorkspacePath\PowerShell\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module $WorkspacePath\PowerShell"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Module WindowsAutoPilotIntune -Path "$WorkspacePath\PowerShell\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module $WorkspacePath\PowerShell"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        }
    }
    #=================================================
    #   USB OSDCloud Volumes
    #=================================================
    if ($PSBoundParameters.ContainsKey('Offline')) {
        $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}
    
        if ($WorkspacePath -and (Test-Path $WorkspacePath) -and $OSDCloudVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud USB volumes found"
            foreach ($OSDCloudVolume in $OSDCloudVolumes) {
    
                if (Test-Path "$WorkspacePath\Config") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\Config to $($OSDCloudVolume.DriveLetter):\OSDCloud\Config"
                    if ($IsAdmin) {
                        robocopy "$WorkspacePath\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                    }
                    else {
                        robocopy "$WorkspacePath\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
    
                if (Test-Path "$WorkspacePath\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\DriverPacks to $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks"
                    if ($IsAdmin) {
                        robocopy "$WorkspacePath\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                    }
                    else {
                        robocopy "$WorkspacePath\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
    
                if (Test-Path "$WorkspacePath\OS") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\OS $($OSDCloudVolume.DriveLetter):\OSDCloud\OS"
                    if ($IsAdmin) {
                        robocopy "$WorkspacePath\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                    }
                    else {
                        robocopy "$WorkspacePath\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
    
                if (Test-Path "$WorkspacePath\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\PowerShell to $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"
                    if ($IsAdmin) {
                        robocopy "$WorkspacePath\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                    }
                    else {
                        robocopy "$WorkspacePath\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
            }
        }
    }
    #=================================================
    #   Complete
    #=================================================
    if ($PSBoundParameters.ContainsKey('Offline')) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB (WinPE and Offline) is complete"
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB (WinPE) is complete"
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
}