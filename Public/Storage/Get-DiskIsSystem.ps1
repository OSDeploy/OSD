<#
.SYNOPSIS
Gets the Disk containing the SYSTEM partition

.DESCRIPTION
Gets the Disk containing the SYSTEM partition

.LINK
https://osd.osdeploy.com/module/functions/storage/get-diskissystem

.NOTES
19.12.9    Created by David Segura @SeguraOSD
#>
function Get-DiskIsSystem {
    [CmdletBinding()]
    Param ()

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

    #TRUE if this disk contains the system partition, or FALSE otherwise
    $GetDisk = $GetDisk | Where-Object {$_.IsSystem -eq $true}

    #Return Results
    Return $GetDisk
}