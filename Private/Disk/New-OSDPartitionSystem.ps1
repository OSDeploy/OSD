<#
.SYNOPSIS
Creates a GPT or MBR System Partition

.DESCRIPTION
Creates a GPT or MBR System Partition

.LINK
https://osd.osdeploy.com/module/functions/storage/new-OSDPartitionSystem

.NOTES
19.12.11     Created by David Segura @SeguraOSD
#>
function New-OSDPartitionSystem {
    [CmdletBinding()]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Alias = Disk, Number
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        #Drive Label of the System Partition
        #Default = System
        [string]$LabelSystem = 'System',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #System Partition size for BIOS MBR based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #System Partition size for UEFI GPT based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #MSR Partition size
        #Default = 16MB
        #Range = 16MB - 128MB
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB
    )

    #======================================================================================================
    #	PartitionStyle
    #======================================================================================================
    if (-NOT ($PartitionStyle)) {
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle is set to $PartitionStyle"
    #======================================================================================================
    #	GPT
    #======================================================================================================
    if ($PartitionStyle -eq 'GPT') {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Creating GPT System Partition"
        $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeSystemGpt

        Write-Host -ForegroundColor Green -BackgroundColor Black "Formatting GPT System Partition FAT32 with Label $LabelSystem"
        Diskpart-FormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'fat32' -LabelSystem $LabelSystem

        Write-Host -ForegroundColor Green -BackgroundColor Black "Setting GPT System Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

        Write-Host -ForegroundColor Green -BackgroundColor Black "Setting GPT System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "Creating MSR Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae}"
        $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
    }
    #======================================================================================================
    #	MBR
    #======================================================================================================
    if ($PartitionStyle -eq 'MBR') {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Creating MBR System Partition as Active"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "Formatting MBR System Partition NTFS with Label $LabelSystem"
        Diskpart-FormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'ntfs' -LabelSystem $LabelSystem

        Write-Host -ForegroundColor Green -BackgroundColor Black "Setting MBR System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S
    }
}