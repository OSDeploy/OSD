<#
.SYNOPSIS
Mirrors an OSDCloud USB to an OSDCloud Workspace

.Description
Mirrors an OSDCloud USB to an OSDCloud Workspace

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.EXAMPLE
Sync-OSDCloudUSB

.LINK
https://osdcloud.osdeploy.com
#>
function Sync-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath,

        [switch]$Force
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	Force
    #=================================================
    if ($PSBoundParameters.ContainsKey('Force')) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB Content delta will be MIRRORED"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Press CTRL + C to abort. Waiting 5 seconds"
        Start-Sleep -Seconds 5
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB Content delta will be LISTED"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Use the -Force parameter to MIRROR content"
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
        Get-Help Sync-OSDCloudUSB -Examples
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Get-Help Sync-OSDCloudUSB -Examples
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Get-Help Sync-OSDCloudUSB -Examples
        Break
    }
    #=================================================
    #	WinpeVolumes
    #=================================================
    $UsbVolumes = Get-Volume.usb

    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB Volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You may need to run New-OSDCloudUSB first"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }

    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'WinPE') -or ($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}

    if ($WinpeVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud WinPE volumes found"

        foreach ($WinpeVolume in $WinpeVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Content DELTA of OSDCloud Workspace at $WorkspacePath\Media and OSDCloud USB at $($WinpeVolume.DriveLetter):\"
            if ($IsAdmin) {
                robocopy "$WorkspacePath\Media" "$($WinpeVolume.DriveLetter):\" *.* /e /ndl /np /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /b /zb /L
            }
            else {
                robocopy "$WorkspacePath\Media" "$($WinpeVolume.DriveLetter):\" *.* /e /ndl /np /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /L
            }
        }
    }










    
    Break
    #=================================================
    #	Update PowerShell Modules
    #=================================================
    if ($WorkspacePath -and (Test-Path $WorkspacePath)) {
        if (-not (Test-Path "$WorkspacePath\PowerShell")) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
            $null = New-Item -Path "$WorkspacePath\PowerShell\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$WorkspacePath\PowerShell\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$WorkspacePath\PowerShell\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            $null = New-Item -Path "$WorkspacePath\PowerShell\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
        }
    
        try {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules at $WorkspacePath\PowerShell"
            Save-Module OSD,WindowsAutoPilotIntune -Path "$WorkspacePath\PowerShell\Offline\Modules"
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the PowerShell content at $WorkspacePath\PowerShell"
        }
    }
    #=================================================
    #	USB OSDCloud Volumes
    #=================================================
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
    #=================================================
    #	Save Driver Packs
    #=================================================
















    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
}