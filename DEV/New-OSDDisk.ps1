<#
.SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives

.DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives

.LINK
https://osd.osdeploy.com/module/functions/new-osddisk

.NOTES
19.10.9     Created by David Segura @SeguraOSD
#>
function New-OSDDisk {
    [CmdletBinding()]
    param (
        #Title displayed during script execution
        #Default = New-OSDDiskWinPE
        #Alias = T
        [Alias('T')]
        [string]$Title = 'New-OSDDisk',

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS
        [Alias('LS')]
        [string]$LabelSystem = 'System',

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

        #Size of the MSR Partition
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = MSR
        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LO
        [Alias('LO')]
        [string]$LabelWindows = 'OS',

        #Skips the creation of the Recovery Partition
        #Alias = NoR
        [Alias('NoR')]
        [switch]$NoRecovery,
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR
        [Alias('LR')]
        [string]$LabelRecovery = 'Recovery',

        #Size of the Recovery Partition
        #Default = 984MB
        #Range = 499MB - 40000MB
        #Alias = SR Recovery Tools
        [Alias('SR','Recovery','Tools')]
        [ValidateRange(499MB,40000MB)]
        [uint64]$SizeRecovery = 984MB,

        #Number of the Disk to prepare
        #Default = 0
        #Alias = Disk Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Cleans all Fixed Disks
        #Alias = Clean CleanAll
        [Alias('Clean','CleanAll')]
        [switch]$CleanAllFixedDisks,

        #This is a very destructive Function.  You must use the Force parameter to execute
        [switch]$Force
    )
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (!(Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$Title : This function requires WinPE.  Exiting"
        Break
    }
    #======================================================================================================
    #	Force
    #======================================================================================================
    if (!($Force.IsPresent)) {
        Write-Warning "$Title : The Force parameter to execute.  Exiting"
        Break
    }
    #======================================================================================================
    #	Get All Fixed Disks
    #======================================================================================================
    if ($CleanAllFixedDisks.IsPresent) {
        $FixedDisks = Get-Disk | Where-Object {(($_.BusType -ne 'USB') -and ($_.Size -gt 10GB))} | Sort-Object Number
    } else {
        $FixedDisks = Get-Disk -Number $DiskNumber
    }
    #======================================================================================================
    #	No Fixed Disks
    #======================================================================================================
    if ($null -eq $FixedDisks) {
        Write-Warning "$Title : Could not find a Hard Drive to prepare"
        Break
    }
    #======================================================================================================
    #	Clear-Disk
    #======================================================================================================
    Write-Verbose "All Fixed Disks must be cleared before Windows can be installed"
    Write-Verbose "All existing Data and Partitions will be destroyed from the following Drives"
    Write-Verbose "======================================================================================="
    foreach ($FixedDisk in $FixedDisks) {
        Write-Verbose "Disk $($FixedDisk.Number)    $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions) BootDisk=$($FixedDisk.BootFromDisk)"
    }
    Write-Verbose "======================================================================================="
    #[void](Read-Host "Press Enter to Continue with $Title")
    foreach ($FixedDisk in $FixedDisks) {
        $FixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction SilentlyContinue | Out-Null
    }
    #======================================================================================================
    #	Get RawDisk
    #======================================================================================================
    $OSDDisk = Get-Disk -Number $DiskNumber
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    Initialize-OSDDisk -Number $($OSDDisk.Number) -Verbose
    #======================================================================================================
    #	New-OSDPartitionSystem
    #======================================================================================================
    New-OSDPartitionSystem -Number $($OSDDisk.Number) -SizeSystemMbr $SizeSystemMbr -SizeSystemGpt $SizeSystemGpt -LabelSystem $LabelSystem -SizeMSR $SizeMSR -Verbose
    #======================================================================================================
    #	Partitions
    #======================================================================================================
    if (Get-OSDGather IsUEFI) {
        #======================================================================================================
        #	OSDisk
        #======================================================================================================
        Write-Verbose "Prepare $LabelWindows Partition"
        if ($NoRecovery.IsPresent) {
            Write-Verbose "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $($OSDDisk.Number) -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter W
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
            $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        } else {
            $OSDDisk = Get-Disk -Number $DiskNumber
            $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
    
            Write-Verbose "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeWindowsGB)GB DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $($OSDDisk.Number) -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter W
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
            $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
            #======================================================================================================
            #	Recovery Partition
            #======================================================================================================
            Write-Verbose "Prepare $LabelRecovery Partition"
            Write-Verbose "New-Partition GptType {de94bba4-06d1-4d40-a16a-bfd50179d6ac} UseMaximumSize"
            $PartitionRecovery = New-Partition -DiskNumber $($OSDDisk.Number) -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
            $null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
    
            Write-Verbose "Set-Partition Attributes 0x8000000000000001"
            $null = @"
select disk $($OSDDisk.Number)
select partition $($PartitionRecovery.PartitionNumber)
gpt attributes=0x8000000000000001 
exit 
"@ |
            diskpart.exe
        }

    } else {
        #======================================================================================================
        #	OSDisk
        #======================================================================================================
        Write-Verbose "Prepare Windows Partition"
        if ($NoRecovery.IsPresent) {
            Write-Verbose "New-Partition MbrType IFS DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $($OSDDisk.Number) -UseMaximumSize -MbrType IFS -DriveLetter W
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
            $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        } else {
            $OSDDisk = Get-Disk -Number $DiskNumber
            $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
    
            Write-Verbose "New-Partition Size $($SizeWindowsGB)GB MbrType IFS DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $($OSDDisk.Number) -Size $SizeWindows -MbrType IFS -DriveLetter W
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
            $null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
            #======================================================================================================
            #	Recovery Partition
            #======================================================================================================
            Write-Verbose "Prepare $LabelRecovery Partition"
            Write-Verbose "New-Partition UseMaximumSize"
            $PartitionRecovery = New-Partition -DiskNumber $($OSDDisk.Number) -UseMaximumSize
    
            Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
            $null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
    
            Write-Verbose "Set-Partition id 27"
            $null = @"
select disk $($OSDDisk.Number)
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ |
        diskpart.exe
        }
    }
}