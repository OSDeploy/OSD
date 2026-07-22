<#
.SYNOPSIS
New-OSDDisk Private Function

.DESCRIPTION
New-OSDDisk Private Function

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
19.10.10     Created by David Segura @SeguraOSD
#>
function New-OSDCloudPartitionWindows {
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
        #Default = 2000MB
        #Range = 350MB - 80000MB (80GB)
        #Alias = SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 2000MB,

        #Skips the creation of the Recovery Partition
        [Alias('SkipRecovery','SkipRecoveryPartition')]
        [System.Management.Automation.SwitchParameter]$NoRecoveryPartition
    )

    #=================================================
    #	Get-OSDCloudDisk
    #=================================================
    $GetOSDDisk = Get-OSDCloudDisk -Number $DiskNumber
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
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
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
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
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

        $SizeWindows = $($GetOSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Recovery Partition"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

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
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter C
    
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

        $OSDDisk = Get-Disk -Number $DiskNumber
        $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter c

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

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] New-Partition -DiskNumber $DiskNumber -UseMaximumSize"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -UseMaximumSize

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set-Partition id 27"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ | diskpart.exe
    }
}