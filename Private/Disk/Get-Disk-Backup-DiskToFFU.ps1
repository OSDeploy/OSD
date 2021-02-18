<#
.SYNOPSIS
Gets Disks that can be backed up

.DESCRIPTION
Gets Disks that can be backed up

.LINK
https://osd.osdeploy.com/module/functions/storage/Get-Disk-Backup-DiskToFFU

.NOTES
19.12.9    Created by David Segura @SeguraOSD
#>
function Get-Disk-Backup-DiskToFFU {
    [CmdletBinding()]
    param ()

    #Get all Disks
    $GetDisk = $(Get-Disk | Select-Object -Property * | Sort-Object DiskNumber)

    #Must have 1 or more Partitions
    $GetDisk = $GetDisk | Where-Object {$_.NumberOfPartitions -ge '1'}

    #Must be a Fixed Disk
    $GetDisk = $GetDisk | Where-Object {$_.ProvisioningType -eq 'Fixed'}

    #Must be Online
    $GetDisk = $GetDisk | Where-Object {$_.OperationalStatus -eq 'Online'}

    #Must have a Size
    $GetDisk = $GetDisk | Where-Object {$_.Size -gt 0}

    #Must not be Offline
    $GetDisk = $GetDisk | Where-Object {$_.IsOffline -eq $false}

    #TRUE if the disk contains the boot partition
    $GetDisk = $GetDisk | Where-Object {$_.IsBoot -eq $false}

    #Cannot be a USB Drive
    $GetDisk = $GetDisk | Where-Object {$_.BusType -ne 'USB'}

    #Return Results
    Return $GetDisk
}