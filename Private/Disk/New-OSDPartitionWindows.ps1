<#
.SYNOPSIS
New-OSDDisk Private Function

.DESCRIPTION
New-OSDDisk Private Function

.LINK
https://osd.osdeploy.com/module/functions/storage/new-osdpartitionwindows

.NOTES
19.10.10     Created by David Segura @SeguraOSD
#>
function New-OSDPartitionWindows {
    [CmdletBinding()]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Default = 0
        #Alias = Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR, LabelR
        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LW, LabelW
        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'OS',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #Size of the Recovery Partition
        #Default = 990MB
        #Range = 350MB - 80000MB (80GB)
        #Alias = SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB,

        #Skips the creation of the Recovery Partition
        [Alias('SkipRecovery','SkipRecoveryPartition')]
        [switch]$NoRecoveryPartition
    )

    #=================================================
    #	Get-Disk.osd
    #=================================================
    $GetOSDDisk = Get-Disk.osd -Number $DiskNumber
    #=================================================
    #	Failure: No Fixed Disks are present
    #=================================================
    if ($null -eq $GetOSDDisk) {
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #=================================================
    #	PartitionStyle
    #=================================================
    if (-NOT ($PartitionStyle)) {
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle is set to $PartitionStyle"
    #=================================================
    #	GPT WINDOWS
    #=================================================
    if ($PartitionStyle -eq 'GPT' -and $NoRecoveryPartition -eq $true) {
        Write-Verbose "Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "DISKPART> select disk $DiskNumber"
        Write-Verbose "DISKPART> select partition $($PartitionWindows.PartitionNumber)"
        Write-Verbose "DISKPART> format fs=$FileSystem quick label='$LabelWindows'"
        Write-Verbose "DISKPART> assign letter C"
        Write-Verbose "DISKPART> exit"
        Write-Verbose "Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"
        
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

        $SizeWindows = $($GetOSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        Write-Verbose "Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

        Write-Verbose "Creating GPT Recovery Partition"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

        Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
        Write-Verbose "Formatting GPT Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "Set-Partition Attributes 0x8000000000000001"
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
        Write-Verbose "Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter C
    
        Write-Verbose "Format-Volume -DriveLetter C -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"
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

        $OSDDisk = Get-Disk -Number $DiskNumber
        $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter c

        Write-Verbose "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

        Write-Verbose "New-Partition -DiskNumber $DiskNumber -UseMaximumSize"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -UseMaximumSize

        Write-Verbose "Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "Set-Partition id 27"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ | diskpart.exe
    }
}