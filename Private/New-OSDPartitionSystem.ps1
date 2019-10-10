<#
.SYNOPSIS
New-OSDDisk Private Function

.DESCRIPTION
New-OSDDisk Private Function

.NOTES
19.10.10     Created by David Segura @SeguraOSD
#>
function New-OSDPartitionSystem {
    [CmdletBinding()]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Default = 0
        #Alias = Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS, LabelS
        [Alias('LS','LabelS')]
        [string]$LabelSystem = 'System',

        #System Partition size for BIOS MBR based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        #Alias = SSM, Mbr, SystemM
        [Alias('SSM','Mbr','SystemM')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #System Partition size for UEFI GPT based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        #Alias = SSG, Efi, SystemG
        [Alias('SSG','Efi','SystemG')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #MSR Partition size
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = MSR
        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB
    )
    Write-Verbose "Prepare System Partition"
    if (Get-OSDGather -Property IsUEFI) {
        #======================================================================================================
        #	GPT
        #======================================================================================================
        Write-Verbose "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeSystemGpt / 1MB)MB"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemGpt -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

        Write-Verbose "Format-Volume FileSystem FAT32 NewFileSystemLabel $LabelSystem"
        Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false | Out-Null

        Write-Verbose "Set-Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        #======================================================================================================
        #	GPT MSR
        #======================================================================================================
        Write-Verbose "New-Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB"
        New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' | Out-Null
    } else {
        #======================================================================================================
        #	MBR
        #======================================================================================================
        Write-Verbose "New-Partition Size $($SizeSystemMbr / 1MB)MB IsActive"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive

        Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelSystem"
        Format-Volume -Partition $PartitionSystem -FileSystem NTFS -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false | Out-Null
    }
}