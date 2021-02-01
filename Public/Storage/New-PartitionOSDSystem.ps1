<#
.SYNOPSIS
Creates a GPT or MBR System Partition

.DESCRIPTION
Creates a GPT or MBR System Partition

.LINK
https://osd.osdeploy.com/module/functions/storage/new-partitionosdsystem

.NOTES
19.12.11     Created by David Segura @SeguraOSD
#>
function New-PartitionOSDSystem {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Alias = Disk, Number
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Disk','Number')]
        [int]$DiskNumber,

        #Drive Label of the System Partition
        #Default = System
        [string]$Label = 'System',

        #System Partition size for BIOS MBR based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeMBR = 260MB,

        #System Partition size for UEFI GPT based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeGPT = 260MB,

        #MSR Partition size
        #Default = 16MB
        #Range = 16MB - 128MB
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,

        #Force parameter is required to make changes
        [switch]$Force
    )
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (Get-OSDGather -Property IsAdmin) {
        Write-Verbose 'New-PartitionOSDSystem is running with Administrative Rights'
    } else {
        Write-Warning 'New-PartitionOSDSystem requires Administrative Rights'
        if ($Force -eq $true) {Break}
    }
    #======================================================================================================
    #	PartitionStyle
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        Write-Verbose "Get-OSDGather -Property IsUEFI: True"
        $PartitionStyle = 'GPT'
    } else {
        Write-Verbose "Get-OSDGather -Property IsUEFI: False"
        $PartitionStyle = 'MBR'
    }
    #======================================================================================================
    #	GetFixedDisks
    #======================================================================================================
    $GetFixedDisks = @()
    if ($DiskNumber) {
        $GetFixedDisks = Get-Disk -Number $DiskNumber | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual') -and ($_.Size -gt 10GB) -and ($_.NumberOfPartitions -eq 0) -and ($_.LargestFreeExtent -gt 0) -and ($_.PartitionStyle -eq $PartitionStyle)}
    } else {
        $GetFixedDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual') -and ($_.Size -gt 10GB) -and ($_.NumberOfPartitions -eq 0) -and ($_.LargestFreeExtent -gt 0) -and ($_.PartitionStyle -eq $PartitionStyle)} | Sort-Object Number | Select-Object -First 1
    }
    #======================================================================================================
    #	Verify GetFixedDisks
    #======================================================================================================
    if ($null -eq $GetFixedDisks) {
        Write-Warning 'New-PartitionOSDSystem did not find any usable Disks'
        Return
    }
    $DiskNumber = $GetFixedDisks.DiskNumber[0]
    #======================================================================================================
    #	New-Partition
    #======================================================================================================
    foreach ($item in $GetFixedDisks) {
        if ($PartitionStyle -eq 'GPT') {
            if ($Force -eq $true) {
                Write-Verbose "New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $($SizeGPT / 1MB)MB"
                $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeGPT
                #Write-Warning "Format-Volume -FileSystem FAT32 -NewFileSystemLabel $Label"
                #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem FAT32 -NewFileSystemLabel "$Label" -Force -Confirm:$false
                Write-Verbose "DISKPART select disk $DiskNumber"
                Write-Verbose "DISKPART select partition $($PartitionSystem.PartitionNumber)"
                Write-Verbose "DISKPART format fs=fat32 quick label='$Label'"
$null = @"
select disk $DiskNumber
select partition $($PartitionSystem.PartitionNumber)
format fs=fat32 quick label="$Label"
exit 
"@ | diskpart.exe
    
                Write-Verbose "Set-Partition -GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
                $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
                Write-Verbose "New-Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB"
                $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
            } else {
                Write-Host "What if: New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $($SizeGPT / 1MB)MB" -ForegroundColor DarkGray
                #Write-Host "What if: Format-Volume -FileSystem FAT32 -NewFileSystemLabel $Label" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART select disk $DiskNumber" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART select partition $($PartitionSystem.PartitionNumber)" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART format fs=fat32 quick label='$Label'" -ForegroundColor DarkGray
                Write-Host "What if: Set-Partition -GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -ForegroundColor DarkGray
                Write-Host "What if: New-Partition -GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB" -ForegroundColor DarkGray
            }
        }
        if ($PartitionStyle -eq 'MBR') {
            if ($Force -eq $true) {
                Write-Verbose "New-Partition Size $($SizeMBR / 1MB)MB IsActive"
                $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeMBR -IsActive
                #Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $Label"
                #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem NTFS -NewFileSystemLabel "$Label" -Force -Confirm:$false
                Write-Verbose "DISKPART select disk $DiskNumber"
                Write-Verbose "DISKPART select partition $($PartitionSystem.PartitionNumber)"
                Write-Verbose "DISKPART format fs=ntfs quick label='$Label'"
$null = @"
select disk $DiskNumber
select partition $($PartitionSystem.PartitionNumber)
format fs=ntfs quick label="$Label"
exit 
"@ | diskpart.exe
            } else {
                Write-Host "What if: New-Partition Size $($SizeMBR / 1MB)MB IsActive" -ForegroundColor DarkGray
                #Write-Host "What if: Format-Volume FileSystem NTFS NewFileSystemLabel $Label" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART select disk $DiskNumber" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART select partition $($PartitionSystem.PartitionNumber)" -ForegroundColor DarkGray
                Write-Host "What if: DISKPART format fs=ntfs quick label='$Label'" -ForegroundColor DarkGray
            }
        }
    }
    #======================================================================================================}
    Return Get-Disk -Number $DiskNumber
}