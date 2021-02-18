<#
.SYNOPSIS
Creates a GPT or MBR System Partition

.DESCRIPTION
Creates a GPT or MBR System Partition

.LINK
https://osd.osdeploy.com/module/functions/storage/new-OSDPartitionSystem

.NOTES
19.12.11     Created by David Segura @SeguraOSD
#>
function New-OSDPartitionSystem {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Alias = Disk, Number
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

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

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('F')]
        [switch]$Force
    )

    begin {
        #======================================================================================================
        #	OSD Module Information
        #======================================================================================================
        $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
        Write-Verbose "OSD $OSDVersion $Title"
        #======================================================================================================
        #	Set Defaults
        #======================================================================================================
        $GetOSDDisk = $null
        $Sandbox = $true
        #======================================================================================================
        #	Force Validation
        #======================================================================================================
        if ($Force.IsPresent) {$Sandbox = $false}
        #======================================================================================================
        #	PartitionStyle
        #======================================================================================================
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
        #======================================================================================================
        #	Get all Fixed Disks larger than 15GB
        #======================================================================================================
        if ($DiskNumber) {
            $GetOSDDisk = Get-OSDDisk -BusTypeNot USB,Virtual -PartitionStyle $PartitionStyle -Number $DiskNumber | `
            Where-Object {($_.LargestFreeExtent -gt 0)} | `
            Where-Object {($_.NumberOfPartitions -eq 0)} | `
            Where-Object {($_.Size -gt 15GB)} | `
            Sort-Object Number | Select-Object -First 1
        } else {
            $GetOSDDisk = Get-OSDDisk -BusTypeNot USB,Virtual -PartitionStyle $PartitionStyle | `
            Where-Object {($_.LargestFreeExtent -gt 0)} | `
            Where-Object {($_.NumberOfPartitions -eq 0)} | `
            Where-Object {($_.Size -gt 15GB)} | `
            Sort-Object Number | Select-Object -First 1
        }
        #======================================================================================================
        #	No RAW Disks
        #======================================================================================================
        if ($null -eq $GetOSDDisk) {
            Write-Warning "Disks must be Initialzed before adding a System Partition"
            Write-Warning "Clear-OSDDisk then Initialize-OSDDisk then New-OSDPartitionSystem"
            Return $null
        }
        $DiskNumber = $GetOSDDisk.DiskNumber[0]
        #======================================================================================================
        #	IsWinPE
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsWinPE)) {
            Write-Warning "WinPE is required for execution"
            $Sandbox = $true
        }
        #======================================================================================================
        #	IsAdmin
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsAdmin)) {
            Write-Warning "Administrative Rights are required for execution"
            $Sandbox = $true
        }
        #======================================================================================================
        #	Sandbox
        #======================================================================================================
        if ($Sandbox -eq $true) {
            Write-Warning "$Title is running in Sandbox (non-desctructive)"
            Write-Warning "Disks will not be initialized while in Sandbox"
            Write-Warning "-Force parameter is required to bypass Sandbox"
            Write-Warning "-Confirm parameter is enabled in Sandbox"
            $ConfirmPreference = 'Low'
        }
        #======================================================================================================
    }
    process {
        #======================================================================================================
        #	New-Partition
        #======================================================================================================
        foreach ($item in $GetOSDDisk) {
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
    }
    end {Return Get-Disk -Number $DiskNumber}
}