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
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0
    )
    #======================================================================================================
    #	UEFI GPT
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        if ($global:OSDDiskSandbox -eq $true) {
            Write-Host "SANDBOX: Initialize-Disk -Number $DiskNumber -PartitionStyle GPT" -ForegroundColor DarkGray
        }
        if ($global:OSDDiskSandbox -eq $false) {
            Write-Warning "Initialize-Disk -Number $DiskNumber -PartitionStyle GPT"
            Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -ErrorAction SilentlyContinue | Out-Null
        }
    }
    #======================================================================================================
    #	BIOS MBR
    #======================================================================================================
    if (! (Get-OSDGather -Property IsUEFI)) {
        if ($global:OSDDiskSandbox -eq $true) {
            Write-Host "SANDBOX: Initialize-Disk -Number $DiskNumber -PartitionStyle MBR" -ForegroundColor DarkGray
        }

        if ($global:OSDDiskSandbox -eq $false) {
            Write-Warning "Initialize-Disk -Number $DiskNumber -PartitionStyle MBR"
            Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -ErrorAction SilentlyContinue | Out-Null
        }
    }
}