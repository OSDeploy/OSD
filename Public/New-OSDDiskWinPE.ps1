<#
.SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives using

.DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives using

.LINK
https://osd.osdeploy.com/module/functions/new-osddiskwinpe

.NOTES
19.10.8     Created by David Segura @SeguraOSD
#>
function New-OSDDiskWinPE {
    [CmdletBinding()]
    param (
        #Size of the System Partition for BIOS based Computers
        #Default = 999MB
        #Range = 100MB - 1999MB
        #Alias = SSB Bios System SystemBios
        [Alias('SSB','Bios','System','SystemBios')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemBios = 260MB,

        #Size of the System Partition for UEFI based Computers
        #Default = 260MB
        #Range = 100MB - 1999MB
        #Alias = SSU Efi Uefi SystemEfi SystemUefi
        [Alias('SSU','Efi','Uefi','SystemEfi','SystemUefi')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemUefi = 260MB,

        #Size of the MSR Partition
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = SM MSR
        [Alias('SM','MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,

        #Size of the Recovery Partition
        #Default = 984MB
        #Range = 499MB - 999MB
        #Alias = SR Recovery Tools
        [Alias('SR','Recovery','Tools')]
        [ValidateRange(499MB,999MB)]
        [uint64]$SizeRecovery = 984MB,

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS
        [Alias('LS')]
        [string]$LabelSystem = 'System',
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LO
        [Alias('LO')]
        [string]$LabelOS = 'OS',
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR
        [Alias('LR')]
        [string]$LabelRecovery = 'Recovery',
        
        #Title displayed during script execution
        #Default = New-OSDDiskWinPE
        #Alias = T
        [Alias('T')]
        [string]$Title = 'New-OSDDiskWinPE'
    )
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (Get-OSDGather -Property IsWinPE) {Write-Verbose 'OSDWinPE: WinPE is running'}
    else {Write-Warning 'OSDWinPE: This function requires WinPE'; Break}
    #======================================================================================================
    #	Get Fixed Disks
    #======================================================================================================
    $FixedDisks = Get-Disk | Where-Object {(($_.BusType -ne 'USB') -and ($_.Size -gt 10GB))} | Sort-Object Number
    #======================================================================================================
    #	No Fixed Disks
    #======================================================================================================
    if ($null -eq $FixedDisks) {
        Write-Host "$Title could not find a Hard Drive to use for Windows Setup" -ForegroundColor Red
        Write-Host
        [void](Read-Host 'Press Enter to Continue')
        Write-Host
        Break
    }
    #======================================================================================================
    #	Clear-Disk
    #======================================================================================================
    Write-Host "All Fixed Disks must be cleared before Windows can be installed" -ForegroundColor Cyan
    Write-Host "All existing Data and Partitions will be destroyed from the following Drives" -ForegroundColor Cyan
    if ($FixedDisks.Count -gt 1) {Write-Host "You will need to confirm for each Drive that is detected" -ForegroundColor Red}
    Write-Host "=======================================================================================" -ForegroundColor Yellow
    foreach ($Disk in $FixedDisks) {
        Write-Host "Disk $($Disk.Number)    $($Disk.FriendlyName) ($([math]::Round($Disk.Size / 1000000000))GB $($Disk.PartitionStyle)) BusType=$($Disk.BusType) Partitions=$($Disk.NumberOfPartitions) BootDisk=$($Disk.BootFromDisk)" -ForegroundColor Yellow 
    }
    Write-Host "=======================================================================================" -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to Continue with Clear-Disk')
    foreach ($FixedDisk in $FixedDisks) {$FixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null}
    Write-Host
    #======================================================================================================
    #	Get RawDisks
    #======================================================================================================
    $RawDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.Size -gt 10GB) -and ($_.PartitionStyle -eq 'RAW')} | Sort-Object Number

    Write-Host "=======================================================================================" -ForegroundColor Yellow
    foreach ($Disk in $RawDisks) {
        Write-Host "Disk $($Disk.Number)    $($Disk.FriendlyName) ($([math]::Round($Disk.Size / 1000000000))GB $($Disk.PartitionStyle)) BusType=$($Disk.BusType) Partitions=$($Disk.NumberOfPartitions) BootDisk=$($Disk.BootFromDisk)" -ForegroundColor Yellow 
    }
    Write-Host "To quit this script without Partitioning, type X (and press Enter)" -ForegroundColor Yellow 
    Write-Host "=======================================================================================" -ForegroundColor Yellow
    #======================================================================================================
    #	2+ Raw Fixed Disks
    #======================================================================================================
    #if ($RawDisks.Count -gt 1) {
        do {
            $Selected = Read-Host "Type the Number of the Disk to Partition for Windows (and press Enter)"
        } until (($RawDisks.Number -Contains $Selected) -or $Selected -eq 'X')
        if ($Selected -eq 'X') {Break}
        $RawDisk = $RawDisks | Where-Object {$_.Number -eq $Selected}
    #} else {
        #$Selected = 0
        #$RawDisk = $RawDisks
    #}
    if (Get-OSDGather IsUEFI) {
        #======================================================================================================
        #	Initialize-Disk
        #======================================================================================================
        Write-Host "Prepare Disk $($RawDisk.Number)" -ForegroundColor Cyan
        Write-Host "Initialize-Disk PartitionStyle GPT" -ForegroundColor DarkGray
        Initialize-Disk -Number $($RawDisk.Number) -PartitionStyle GPT -ErrorAction SilentlyContinue
        #======================================================================================================
        #	System Partition
        #======================================================================================================
        Write-Host "Prepare $LabelSystem Partition" -ForegroundColor Cyan
        Write-Host "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeSystemUefi / 1MB)MB" -ForegroundColor DarkGray
        $PartitionSystem = New-Partition -DiskNumber $($RawDisk.Number) -Size $SizeSystemUefi -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

        Write-Host "Format-Volume FileSystem FAT32 NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelSystem" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false

        Write-Host "Set-Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -ForegroundColor DarkGray
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        #======================================================================================================
        #	MSR Partition
        #======================================================================================================
        Write-Host "Prepare MSR Partition" -ForegroundColor Cyan
        Write-Host "New-Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB" -ForegroundColor DarkGray
        $MsrPartition = New-Partition -DiskNumber $RawDisk.Number -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
        #======================================================================================================
        #	OSDisk
        #======================================================================================================
        Write-Host "Prepare $LabelOS Partition" -ForegroundColor Cyan
        $OSDisk = Get-Disk -Number $Selected
        $SizeOS = $($OSDisk.LargestFreeExtent) - $SizeRecovery
        $SizeOSGB = [math]::Round($SizeOS / 1GB,1)

        Write-Host "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeOSGB)GB DriveLetter " -ForegroundColor DarkGray -NoNewline
        Write-Host "W" -ForegroundColor Cyan
        $PartitionWindows = New-Partition -DiskNumber $($OSDisk.Number) -Size $SizeOS -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter W

        Write-Host "Format-Volume FileSystem NTFS NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelOS" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelOS" -FileSystem NTFS -Force -Confirm:$false
        #======================================================================================================
        #	Recovery Partition
        #======================================================================================================
        Write-Host "Prepare $LabelRecovery Partition" -ForegroundColor Cyan
        Write-Host "New-Partition GptType {de94bba4-06d1-4d40-a16a-bfd50179d6ac} UseMaximumSize" -ForegroundColor DarkGray
        $PartitionRecovery = New-Partition -DiskNumber $($OSDisk.Number) -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

        Write-Host "Format-Volume FileSystem NTFS NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelRecovery" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -confirm:$false

        Write-Host "Set-Partition Attributes 0x8000000000000001" -ForegroundColor DarkGray
        $null = @"
select disk $($OSDisk.Number)
select partition $($PartitionRecovery.PartitionNumber)
gpt attributes=0x8000000000000001 
exit 
"@ |
        diskpart.exe
    } else {
        #======================================================================================================
        #	Initialize-Disk
        #======================================================================================================
        Write-Host "Prepare Disk $($RawDisk.Number)" -ForegroundColor Cyan
        Write-Host "Initialize-Disk PartitionStyle MBR" -ForegroundColor DarkGray
        Initialize-Disk -Number $($RawDisk.Number) -PartitionStyle MBR -ErrorAction SilentlyContinue
        #======================================================================================================
        #	System Partition
        #======================================================================================================
        Write-Host "Prepare $LabelSystem Partition" -ForegroundColor Cyan
        Write-Host "New-Partition Size $($SizeSystemBios / 1MB)MB IsActive" -ForegroundColor DarkGray
        $PartitionSystem = New-Partition -DiskNumber $($RawDisk.Number) -Size $SizeSystemBios -IsActive

        Write-Host "Format-Volume FileSystem NTFS NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelSystem" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionSystem -FileSystem NTFS -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false
        #======================================================================================================
        #	OSDisk
        #======================================================================================================
        Write-Host "Prepare $LabelOS Partition" -ForegroundColor Cyan
        $OSDisk = Get-Disk -Number $Selected
        $SizeOS = $($OSDisk.LargestFreeExtent) - $SizeRecovery
        $SizeOSGB = [math]::Round($SizeOS / 1GB,1)

        Write-Host "New-Partition Size $($SizeOSGB)GB MbrType IFS DriveLetter " -ForegroundColor DarkGray -NoNewline
        Write-Host "W" -ForegroundColor Cyan
        $PartitionWindows = New-Partition -DiskNumber $($OSDisk.Number) -Size $SizeOS -MbrType IFS -DriveLetter W

        Write-Host "Format-Volume FileSystem NTFS NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelOS" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelOS" -FileSystem NTFS -Force -Confirm:$false
        #======================================================================================================
        #	Recovery Partition
        #======================================================================================================
        Write-Host "Prepare $LabelRecovery Partition" -ForegroundColor Cyan
        Write-Host "New-Partition UseMaximumSize" -ForegroundColor DarkGray
        $PartitionRecovery = New-Partition -DiskNumber $($OSDisk.Number) -UseMaximumSize

        Write-Host "Format-Volume FileSystem NTFS NewFileSystemLabel " -ForegroundColor DarkGray -NoNewline
        Write-Host "$LabelRecovery" -ForegroundColor Cyan
        $null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -confirm:$false

        Write-Host "Set-Partition id 27" -ForegroundColor DarkGray
        $null = @"
select disk $($OSDisk.Number)
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ |
        diskpart.exe
    }
}