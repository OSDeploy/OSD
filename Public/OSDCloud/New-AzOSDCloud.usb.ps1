<#
.SYNOPSIS
Clear, Initialize, 2 Partition, and Format a USB Disk for use with OSDCloud

.Description
Clear, Initialize, 2 Partition, and Format a USB Disk for use with OSDCloud

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function New-AzOSDCloudUsb {
    [CmdletBinding()]
    param (
        [System.Uri]$Uri = 'https://winpe.blob.core.windows.net/public/OSDCloud_22.1.30.iso'
    )
    #=================================================
    #	Start the Clock
    #=================================================
    $azosdcloudusbStartTime = Get-Date
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloud'
    #=================================================
    #	Download ISO
    #=================================================
    if ($Uri.AbsolutePath) {
        $WinpeIsoUrl = $Uri.AbsolutePath
    }
    else {
        $WinpeIsoUrl = $Uri.OriginalString
    }
    $WinpeIsoDownload = Save-WebFile -SourceUrl $WinpeIsoUrl -DestinationDirectory (Join-Path $HOME 'Downloads')

    if ($WinpeIsoUrl) {

    }
    else {
        Write-Warning "Could not download $WinpeIsoUrl"
        Break
    }

    Break
    #=================================================
    #	New-Bootable.usb
    #=================================================
    $BootableUSB = New-Bootable.usb -BootLabel $BootLabel -DataLabel $DataLabel
    #=================================================
    #	Get-Partition.usb
    #=================================================
    $UsbBootPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($UsbBootPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    $UsbDataPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($UsbDataPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }



    Break
    #=================================================
    #	Copy OSDCloud
    #=================================================
    if ((Test-Path -Path "$WorkspacePath\Media") -and (Test-Path -Path "$($UsbBootPartition.DriveLetter):\")) {
        robocopy "$WorkspacePath\Media" "$($UsbBootPartition.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    if (Test-Path -Path "$WorkspacePath\Autopilot") {
        robocopy "$WorkspacePath\Autopilot" "$($UsbDataPartition.DriveLetter):\OSDCloud\Autopilot" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    if (Test-Path -Path "$WorkspacePath\ODT") {
        robocopy "$WorkspacePath\ODT" "$($UsbDataPartition.DriveLetter):\OSDCloud\ODT" *.* /e /ndl /njh /njs /np /r:0 /w:0
    }
    #=================================================
    #	Complete
    #=================================================
    $azosdcloudusbEndTime = Get-Date
    $azosdcloudusbTimeSpan = New-TimeSpan -Start $azosdcloudusbStartTime -End $azosdcloudusbEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($azosdcloudusbTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
}