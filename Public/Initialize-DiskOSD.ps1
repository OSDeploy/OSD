<#
.SYNOPSIS
Initializes any RAW Disks.  Automatically selects GPT or MBR

.DESCRIPTION
Initializes any RAW Disks.  Automatically selects GPT or MBR

.LINK
https://osd.osdeploy.com/module/functions/initialize-diskosd

.NOTES
19.12.9    Created by David Segura @SeguraOSD
#>
function Initialize-DiskOSD {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Alias = Disk, Number
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Disk','DiskNumber')]
        [uint32]$Number
    )
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (Get-OSDGather -Property IsAdmin) {
        Write-Verbose 'Initialize-DiskOSD is running with Administrative Rights'
    } else {
        Write-Warning 'Initialize-DiskOSD requires Administrative Rights'
        if ($WhatIfPreference) {
            Write-Warning 'Initialize-DiskOSD Break'
        } else {
            Break
        }
    }
    #======================================================================================================
    #	GetFixedDisks
    #======================================================================================================
    $GetFixedDisks = @()
    if ($Number) {
        $GetFixedDisks = Get-Disk -Number $Number | Where-Object {$_.PartitionStyle -eq 'RAW'}
    } else {
        $GetFixedDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual') -and ($_.Size -gt 15GB) -and ($_.PartitionStyle -eq 'RAW')} | Sort-Object Number
    }
    
    if ($null -eq $GetFixedDisks) {
        Write-Verbose 'Initialize-DiskOSD does not find any Disks that need to be Initialized'
        Continue
    }
    #======================================================================================================
    #	PartitionStyle
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        $PartitionStyle = 'GPT'
    } else {
        $PartitionStyle = 'MBR'
    }
    #======================================================================================================
    #	Initialize-Disk
    #======================================================================================================
    foreach ($item in $GetFixedDisks) {
        if ($PSCmdlet.ShouldProcess("Disk $($item.Number)","Initialize-Disk $PartitionStyle")){
            Initialize-Disk -Number $item.Number -PartitionStyle $PartitionStyle
        }
    }
    #======================================================================================================
}