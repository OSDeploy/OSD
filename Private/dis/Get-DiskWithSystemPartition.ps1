function Get-DiskWithSystemPartition {
    <#
    .SYNOPSIS
    Gets fixed disks that contain the system partition.

    .DESCRIPTION
    Returns online, fixed disks that have at least one partition and are marked
    as system disks by the storage subsystem.

    .EXAMPLE
    Get-DiskWithSystemPartition
    Returns the disk object representing the current system disk.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and normalized required sections
    #>
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

    #TRUE if this disk contains the system partition, or FALSE otherwise
    $GetDisk = $GetDisk | Where-Object {$_.IsSystem -eq $true}

    #Return Results
    Return $GetDisk
}
