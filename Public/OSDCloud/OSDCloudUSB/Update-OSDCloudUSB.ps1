<#
.SYNOPSIS
Updates an OSDCloud USB by copying content from an OSDCloud Workspace
This function works with multiple OSDCloud USB Drives

.Description
Updates an OSDCloud USB by copying content from an OSDCloud Workspace
This function works with multiple OSDCloud USB Drives

.EXAMPLE
Update-OSDCloudUSB

.LINK
https://osdcloud.osdeploy.com
#>
function Update-OSDCloudUSB {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    #Block-NoCurl
    Block-WinPE
    Block-PowerShellVersionLt5
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $IsAdmin = Get-OSDGather -Property IsAdmin
    $UsbVolumes = Get-Volume.usb
    $WorkspacePath = Get-OSDCloud.workspace
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
    #	Set WinPE USB Volume Label
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}

    if ($WinpeVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
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
    #	Test OSDCloud Workspace
    #=================================================
    if (! $WorkspacePath) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not present on this system"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    elseif (! (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not at the path $WorkspacePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    elseif (! (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud WinPE does not exist at $WorkspacePath\Media\sources\boot.wim"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    $PowerShellPath = "$WorkspacePath\PowerShell"

    if (! (Test-Path "$PowerShellPath")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
        $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
    }
    if (! (Test-Path "$PowerShellPath\Offline\Modules")) {
        $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
    }
    if (! (Test-Path "$PowerShellPath\Offline\Scripts")) {
        $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
    }
    if (! (Test-Path "$PowerShellPath\Required\Modules")) {
        $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
    }
    if (! (Test-Path "$PowerShellPath\Required\Scripts")) {
        $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
    }

    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules and Scripts at $PowerShellPath"

    try {
        Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
    }
    catch {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
    }

    try {
        Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
    }
    catch {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
    }

    try {
        Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
    }
    catch {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
    }
    #=================================================
    #	Update all WinPE volumes with Workspace
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}

    foreach ($WinpeVolume in $WinpeVolumes) {
        if (Test-Path -Path "$($WinPEVolume.DriveLetter):\") {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\"
            robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
        }
    }
    #=================================================
    #   Update all OSDCloud volumes with Workspace
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}

    if ($OSDCloudVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Offline USB volumes found"
        foreach ($OSDCloudVolume in $OSDCloudVolumes) {
            if (Test-Path "$WorkspacePath\Config") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\Config to $($OSDCloudVolume.DriveLetter):\OSDCloud\Config"
                robocopy "$WorkspacePath\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$WorkspacePath\DriverPacks") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\DriverPacks to $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks"
                robocopy "$WorkspacePath\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$WorkspacePath\OS") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\OS $($OSDCloudVolume.DriveLetter):\OSDCloud\OS"
                robocopy "$WorkspacePath\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }

            if (Test-Path "$WorkspacePath\PowerShell") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\PowerShell to $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"
                robocopy "$WorkspacePath\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
}