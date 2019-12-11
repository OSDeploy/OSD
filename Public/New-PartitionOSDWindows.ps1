<#
.SYNOPSIS
New-OSDDisk Private Function

.DESCRIPTION
New-OSDDisk Private Function

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
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LW, LabelW
        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'OS',
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR, LabelR
        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        #Skips the creation of the Recovery Partition
        [switch]$SkipRecoveryPartition,

        #Size of the Recovery Partition
        #Default = 990MB
        #Range = 350MB - 80000MB (80GB)
        #Alias = SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB
    )

    #======================================================================================================
    #	GPT WINDOWS
    #======================================================================================================
    if ((Get-OSDGather -Property IsUEFI) -and ($SkipRecoveryPartition.IsPresent)) {
        $OSDDisk = Get-Disk -Number $DiskNumber
        if ($global:OSDDiskSandbox -eq $true) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

            Write-Host "SANDBOX: New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} DriveLetter W" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows" -ForegroundColor DarkGray



        }
        if ($global:OSDDiskSandbox -eq $false) {
            Write-Warning "New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter W

            Write-Warning "Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
            #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
exit 
"@ | diskpart.exe

        }
    }

    #======================================================================================================
    #	GPT WINDOWS + RECOVERY
    #======================================================================================================
    if ((Get-OSDGather -Property IsUEFI) -and (! $SkipRecoveryPartition.IsPresent)) {
        $OSDDisk = Get-Disk -Number $DiskNumber
        if ($global:OSDDiskSandbox -eq $true) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

            Write-Host "SANDBOX: New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeWindowsGB)GB DriveLetter W" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows" -ForegroundColor DarkGray
            Write-Host "SANDBOX: New-Partition GptType {de94bba4-06d1-4d40-a16a-bfd50179d6ac} UseMaximumSize" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Set-Partition Attributes 0x8000000000000001" -ForegroundColor DarkGray
        }
        if ($global:OSDDiskSandbox -eq $false) {
            $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

            Write-Warning "New-Partition GptType {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7} Size $($SizeWindowsGB)GB DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter W

            Write-Warning "Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
            #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
exit 
"@ | diskpart.exe

            Write-Warning "New-Partition GptType {de94bba4-06d1-4d40-a16a-bfd50179d6ac} UseMaximumSize"
            $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

            Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
            #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
exit 
"@ | diskpart.exe

            Write-Warning "Set-Partition Attributes 0x8000000000000001"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
gpt attributes=0x8000000000000001
exit 
"@ | diskpart.exe
        }
    }

    #======================================================================================================
    #	MBR WINDOWS
    #======================================================================================================
    if ((! (Get-OSDGather -Property IsUEFI)) -and ($SkipRecoveryPartition.IsPresent)) {
        if ($global:OSDDiskSandbox -eq $true) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
            Write-Host "SANDBOX: New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter W" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows" -ForegroundColor DarkGray
        }
        if ($global:OSDDiskSandbox -eq $false) {
            Write-Warning "New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter W
    
            Write-Warning "Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
            #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
exit 
"@ | diskpart.exe
        }
    }

    #======================================================================================================
    #	MBR WINDOWS + RECOVERY
    #======================================================================================================
    if ((! (Get-OSDGather -Property IsUEFI)) -and (! $SkipRecoveryPartition.IsPresent)) {

        if ($global:OSDDiskSandbox -eq $true) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

            Write-Host "SANDBOX: New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter W" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows" -ForegroundColor DarkGray
            Write-Host "SANDBOX: New-Partition -DiskNumber $DiskNumber -UseMaximumSize" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery" -ForegroundColor DarkGray
            Write-Host "SANDBOX: Set-Partition id 27" -ForegroundColor DarkGray
        }
        if ($global:OSDDiskSandbox -eq $false) {
            $OSDDisk = Get-Disk -Number $DiskNumber
            $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
    
            Write-Warning "New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter W"
            $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter W
    
            Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
            #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
exit 
"@ | diskpart.exe

            Write-Warning "New-Partition -DiskNumber $DiskNumber -UseMaximumSize"
            $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -UseMaximumSize
    
            Write-Warning "Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery"
            #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
exit 
"@ | diskpart.exe

            Write-Warning "Set-Partition id 27"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ | diskpart.exe
        }
    }
}