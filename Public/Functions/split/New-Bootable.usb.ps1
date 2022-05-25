function New-Bootable.usb {
    [CmdletBinding()]
    param (
        [ValidateLength(0,11)]
        [string]$BootLabel = 'USB Boot',

        [ValidateLength(0,32)]
        [string]$DataLabel = 'USB Data'
    )

    #=================================================
    #	Start the Clock
    #=================================================
    $osdbootStartTime = Get-Date
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    $MinimumSizeGB = 7
    $MaximumSizeGB = 2000
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    #	Disable Autorun
    #=================================================
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    #	Select-Disk.usb
    #   Select a USB Disk
    #=================================================
    Write-Verbose '$SelectDisk = Select-Disk.usb -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB'
    $SelectDisk = Select-Disk.usb -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB
    #=================================================
    #	Select-Disk.usb
    #   Select a USB Disk
    #=================================================
    if (-NOT ($SelectDisk)) {
        Write-Warning "No USB Drives that met the required criteria were detected"
        Write-Warning "MinimumSizeGB: $MinimumSizeGB"
        Write-Warning "MaximumSizeGB: $MaximumSizeGB"
        Break
    }
    #=================================================
    #	Get-Disk.osd -BusType USB
    #   At this point I have the Disk object in $GetUSBDisk
    #=================================================
    Write-Verbose '$GetUSBDisk = Get-Disk.osd -BusType USB -Number $SelectDisk.Number'
    $GetUSBDisk = Get-Disk.osd -BusType USB -Number $SelectDisk.Number
    #=================================================
    #	Clear-Disk
    #   Prompt for Confirmation
    #=================================================
    if ($GetUSBDisk.NumberOfPartitions -eq 0) {
        Write-Verbose "Disk does not have any partitions.  This is a good thing!"
    }
    else {
        Write-Verbose '$GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true'
        $GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true -ErrorAction Stop
    }
    #=================================================
    #	Get-Disk.osd -BusType USB
    #	Run another Get-Disk to make sure that things are ok
    #=================================================
    Write-Verbose '$GetUSBDisk = Get-Disk.osd -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}'
    $GetUSBDisk = Get-Disk.osd -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}

    if (-NOT ($GetUSBDisk)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	-lt 2TB
    #=================================================
    if ($GetUSBDisk.PartitionStyle -eq 'RAW') {
        Write-Verbose '$GetUSBDisk | Initialize-Disk -PartitionStyle MBR'
        $GetUSBDisk | Initialize-Disk -PartitionStyle MBR -ErrorAction Stop
    }

    if ($GetUSBDisk.SizeGB -le 2000) {
        Write-Verbose '$DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel'
        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel -ErrorAction Stop
        
        Write-Verbose '$BootDisk = $GetUSBDisk | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel'
        $BootDisk = $GetUSBDisk | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel -ErrorAction Stop
    }
    #=================================================
    #	-ge 2TB
    #   This is not working as expected and will probably not be bootable
    #   So leaving it in here for historic purposes
    #=================================================
<#     if ($GetUSBDisk.SizeGB -gt 1800) {
        $GetUSBDisk | Initialize-Disk -PartitionStyle GPT
        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel

        $BootDisk = $GetUSBDisk | New-Partition -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel
    } #>
    #=================================================
    #	Complete
    #=================================================
    $osdbootEndTime = Get-Date
    $osdbootTimeSpan = New-TimeSpan -Start $osdbootStartTime -End $osdbootEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($osdbootTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
    #	Return
    #=================================================
    Return (Get-Disk.osd -BusType USB -Number $SelectDisk.Number)
    #=================================================
}