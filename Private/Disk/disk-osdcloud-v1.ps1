function New-OSDPartitionSystem {
    <#
    .SYNOPSIS
    Creates the system partition layout for GPT or MBR disks.

    .DESCRIPTION
    Creates the system partition layout for GPT or MBR disks, formats the partition,
    applies the expected partition attributes, and assigns drive letter S for OSD workflows.

    .PARAMETER DiskNumber
    Target disk number to partition.

    .PARAMETER LabelSystem
    Volume label to apply to the system partition.

    .PARAMETER PartitionStyle
    Partition style to use, GPT or MBR. If omitted, the style is inferred from the current boot mode.

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
    2026-07-21 - Refreshed help, parameter comments, and verbose tracing
    #>
    [CmdletBinding()]
    param (
        #Target disk number to partition
        #Aliases: Disk, Number
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        #Volume label for the system partition
        #Default = System
        [string]$LabelSystem = 'System',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #System partition size for BIOS or legacy MBR layouts
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #System partition size for UEFI GPT layouts
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #MSR partition size for GPT layouts
        #Default = 16MB
        #Range = 16MB - 128MB
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB
    )
    #=================================================
    #	PartitionStyle
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting system partition workflow for disk $DiskNumber"
    if (-NOT ($PartitionStyle)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle was not supplied; inferring from current boot mode"
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
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT system partition on disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT System Partition"
        $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeSystemGpt

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT system partition as FAT32 with label $LabelSystem"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT System Partition FAT32 with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'fat32' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the EFI system partition GPT type"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Assigning drive letter S to the GPT system partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT MSR partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MSR Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae}"
        $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
    }
    #=================================================
    #	MBR
    #=================================================
    if ($PartitionStyle -eq 'MBR') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating active MBR system partition on disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR System Partition as Active"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR system partition as NTFS with label $LabelSystem"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR System Partition NTFS with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'ntfs' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Assigning drive letter S to the MBR system partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting MBR System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S
    }
}
function New-OSDPartitionWindows {
    <#
    .SYNOPSIS
    Creates the Windows and optional recovery partitions.

    .DESCRIPTION
    Builds GPT or MBR Windows layouts, formats the Windows partition, optionally creates the recovery partition,
    and assigns the drive letters and recovery attributes expected by Windows deployment workflows.

    .PARAMETER DiskNumber
    Target disk number to partition.

    .PARAMETER LabelRecovery
    Volume label to apply to the recovery partition.

    .PARAMETER LabelWindows
    Volume label to apply to the Windows partition.

    .PARAMETER PartitionStyle
    Partition style to use, GPT or MBR. If omitted, the style is inferred from the current boot mode.

    .PARAMETER SizeRecovery
    Recovery partition size when the recovery partition is created.

    .PARAMETER NoRecoveryPartition
    Skips creation of the recovery partition.

    .EXAMPLE
    New-OSDPartitionWindows -DiskNumber 0 -PartitionStyle GPT
    Creates Windows and recovery partitions on disk 0.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-21 - Refreshed help, parameter comments, and verbose tracing
    #>
    [CmdletBinding()]
    param (
        #Target disk number to partition
        #Default = 0
        #Aliases: Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Volume label for the recovery partition
        #Default = Recovery
        #Aliases: LR, LabelR
        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        #Volume label for the Windows partition
        #Default = OS
        #Aliases: LW, LabelW
        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'OS',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #Recovery partition size when recovery is created
        #Default = 990MB
        #Range = 350MB - 80000MB (80GB)
        #Aliases: SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB,

        #Skips creation of the recovery partition
        [Alias('SkipRecovery','SkipRecoveryPartition')]
        [System.Management.Automation.SwitchParameter]$NoRecoveryPartition
    )
    #=================================================
    #	Get-OSDDisk
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting Windows partition workflow for disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Looking up disk metadata for disk $DiskNumber"
    $GetOSDDisk = Get-OSDDisk -Number $DiskNumber
    #=================================================
    #	Failure: No Fixed Disks are present
    #=================================================
    if ($null -eq $GetOSDDisk) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Disk lookup failed for disk $DiskNumber"
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #=================================================
    #	PartitionStyle
    #=================================================
    if (-NOT ($PartitionStyle)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle was not supplied; inferring from current boot mode"
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle is set to $PartitionStyle"
    #=================================================
    #	GPT WINDOWS
    #=================================================
    if ($PartitionStyle -eq 'GPT' -and $NoRecoveryPartition -eq $true) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows partition without a recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select partition $($PartitionWindows.PartitionNumber)"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> format fs=$FileSystem quick label='$LabelWindows'"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> assign letter C"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	GPT WINDOWS + RECOVERY
    #=================================================
    if ($PartitionStyle -eq 'GPT' -and $NoRecoveryPartition -eq $false) {

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Calculating Windows partition size from the remaining free space"
        $SizeWindows = $($GetOSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows partition with a recovery partition reserved"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Recovery Partition"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT recovery partition as NTFS with label $LabelRecovery"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the recovery partition GPT attributes"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set-Partition Attributes 0x8000000000000001"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
gpt attributes=0x8000000000000001
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	MBR WINDOWS
    #=================================================
    if ($PartitionStyle -eq 'MBR' -and $NoRecoveryPartition -eq $true) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows partition without a recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter C

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume -DriveLetter C -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"
$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	MBR WINDOWS + RECOVERY
    #=================================================
    if ($PartitionStyle -eq 'MBR' -and $NoRecoveryPartition -eq $false) {

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Reading disk geometry before creating the MBR Windows partition"
        $OSDDisk = Get-Disk -Number $DiskNumber
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Calculating Windows partition size from the remaining free space"
        $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows partition with a recovery partition reserved"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter c

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] New-Partition -DiskNumber $DiskNumber -UseMaximumSize"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -UseMaximumSize

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR recovery partition as NTFS with label $LabelRecovery"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the recovery partition ID 27"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set-Partition id 27"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ | diskpart.exe
    }
}
