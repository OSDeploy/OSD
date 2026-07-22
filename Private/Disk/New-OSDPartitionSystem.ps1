function New-OSDPartitionSystem {
    <#
    .SYNOPSIS
    Creates the system partition layout for GPT or MBR disks.

    .DESCRIPTION
    Creates and formats the system partition on the target disk, then applies
    the expected partition attributes and drive letter for OSD workflows.

    .PARAMETER DiskNumber
    Target disk number.

    .PARAMETER LabelSystem
    Label to apply to the system partition.

    .PARAMETER PartitionStyle
    Partition style to use, GPT or MBR. If omitted, style is inferred.

    .PARAMETER SizeSystemMbr
    System partition size for MBR layouts.

    .PARAMETER SizeSystemGpt
    System partition size for GPT layouts.

    .PARAMETER SizeMSR
    MSR partition size for GPT layouts.

    .EXAMPLE
    New-OSDPartitionSystem -DiskNumber 0 -PartitionStyle GPT
    Creates and formats GPT system and MSR partitions on disk 0.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and normalized required sections
    #>
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

    #=================================================
    #	PartitionStyle
    #=================================================
    if (-NOT ($PartitionStyle)) {
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle is set to $PartitionStyle"
    #=================================================
    #	GPT
    #=================================================
    if ($PartitionStyle -eq 'GPT') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT System Partition"
        $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeSystemGpt

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT System Partition FAT32 with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'fat32' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MSR Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae}"
        $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
    }
    #=================================================
    #	MBR
    #=================================================
    if ($PartitionStyle -eq 'MBR') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR System Partition as Active"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR System Partition NTFS with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'ntfs' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting MBR System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S
    }
}
