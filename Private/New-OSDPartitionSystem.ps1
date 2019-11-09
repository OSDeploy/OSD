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
    #======================================================================================================
    #	UEFI GPT SYSTEM + MSR
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        if ($global:OSDDiskSandbox -eq $true) {
            Write-Host "SANDBOX: New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $($SizeSystemGpt / 1MB)MB" -ForegroundColor DarkGray

            #Write-Host "SANDBOX: Format-Volume -FileSystem FAT32 -NewFileSystemLabel $LabelSystem" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART select disk $DiskNumber" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART select partition $($PartitionSystem.PartitionNumber)" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART format fs=fat32 quick label='$LabelSystem'" -ForegroundColor DarkGray

            Write-Host "SANDBOX: Set-Partition -GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -ForegroundColor DarkGray
            Write-Host "SANDBOX: New-Partition -GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB" -ForegroundColor DarkGray
        }
        if ($global:OSDDiskSandbox -eq $false) {
            Write-Warning "New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $($SizeSystemGpt / 1MB)MB"
            $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeSystemGpt

            #Write-Warning "Format-Volume -FileSystem FAT32 -NewFileSystemLabel $LabelSystem"
            #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem FAT32 -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false
            Write-Warning "DISKPART select disk $DiskNumber"
            Write-Warning "DISKPART select partition $($PartitionSystem.PartitionNumber)"
            Write-Warning "DISKPART format fs=fat32 quick label='$LabelSystem'"
$null = @"
select disk $DiskNumber
select partition $($PartitionSystem.PartitionNumber)
format fs=fat32 quick label="$LabelSystem"
exit 
"@ | diskpart.exe

            Write-Warning "Set-Partition -GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
            $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
            Write-Warning "New-Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB"
            $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
        }
    }
    #======================================================================================================
    #	BIOS MBR SYSTEM
    #======================================================================================================
    if (! (Get-OSDGather -Property IsUEFI)) {

        if ($global:OSDDiskSandbox -eq $true) {
            Write-Host "SANDBOX: New-Partition Size $($SizeSystemMbr / 1MB)MB IsActive" -ForegroundColor DarkGray
            
            #Write-Host "SANDBOX: Format-Volume FileSystem NTFS NewFileSystemLabel $LabelSystem" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART select disk $DiskNumber" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART select partition $($PartitionSystem.PartitionNumber)" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART format fs=ntfs quick label='$LabelSystem'" -ForegroundColor DarkGray
        }
        
        if ($global:OSDDiskSandbox -eq $false) {

            Write-Warning "New-Partition Size $($SizeSystemMbr / 1MB)MB IsActive"
            $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive

            #Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelSystem"
            #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem NTFS -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false
            Write-Warning "DISKPART select disk $DiskNumber"
            Write-Warning "DISKPART select partition $($PartitionSystem.PartitionNumber)"
            Write-Warning "DISKPART format fs=ntfs quick label='$LabelSystem'"
$null = @"
select disk $DiskNumber
select partition $($PartitionSystem.PartitionNumber)
format fs=ntfs quick label="$LabelSystem"
exit 
"@ | diskpart.exe

        }
    }
}