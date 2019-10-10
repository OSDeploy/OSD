function New-OSDPartitionSystem {
    [CmdletBinding()]
    param (
        #Number of the Disk to prepare
        #Alias = Disk DiskNumber
        [Parameter(Position = 0)]
        [Alias('Disk','DiskNumber')]
        [int]$Number = 0,

        #Size of the System Partition for BIOS based Computers
        #Default = 999MB
        #Range = 100MB - 1999MB
        #Alias = SzSM Mbr SystemBios
        [Alias('SzSM','Mbr','SystemMbr')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #Size of the System Partition for UEFI based Computers
        #Default = 260MB
        #Range = 100MB - 1999MB
        #Alias = SzSG Efi SystemGpt
        [Alias('SzSG','Efi','SystemGpt')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS
        [Alias('LS')]
        [string]$LabelSystem = 'System',

        #Size of the MSR Partition
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = MSR
        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB
    )
    Write-Verbose "Prepare System Partition"
    if (Get-OSDGather IsUEFI) {
        #======================================================================================================
        #	GPT
        #======================================================================================================
        Write-Verbose "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeSystemGpt / 1MB)MB"
        $PartitionSystem = New-Partition -DiskNumber $Number -Size $SizeSystemGpt -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

        Write-Verbose "Format-Volume FileSystem FAT32 NewFileSystemLabel $LabelSystem"
        Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false | Out-Null

        Write-Verbose "Set-Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        #======================================================================================================
        #	GPT MSR
        #======================================================================================================
        Write-Verbose "New-Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae} Size $($SizeMSR / 1MB)MB"
        New-Partition -DiskNumber $Number -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' | Out-Null
    } else {
        #======================================================================================================
        #	MBR
        #======================================================================================================
        Write-Verbose "New-Partition Size $($SizeSystemMbr / 1MB)MB IsActive"
        $PartitionSystem = New-Partition -DiskNumber $Number -Size $SizeSystemMbr -IsActive

        Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelSystem"
        Format-Volume -Partition $PartitionSystem -FileSystem NTFS -NewFileSystemLabel "$LabelSystem" -Force -Confirm:$false | Out-Null
    }
}