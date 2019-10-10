<#
.SYNOPSIS
New-OSDDisk Private Function

.DESCRIPTION
New-OSDDisk Private Function

.NOTES
19.10.10     Created by David Segura @SeguraOSD
#>
function Initialize-OSDDisk {
    [CmdletBinding()]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Default = 0
        #Alias = Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0
    )
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    if (Get-OSDGather IsUEFI) {
        Write-Verbose "Initialize-Disk Number $DiskNumber PartitionStyle GPT"
        Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -ErrorAction SilentlyContinue
    } else {
        Write-Verbose "Initialize-Disk Number $DiskNumber PartitionStyle MBR"
        Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -ErrorAction SilentlyContinue
    }
}