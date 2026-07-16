function Get-DiskBootWithPartitions {
    <#
    .SYNOPSIS
    Returns online fixed boot disks that contain partitions.

    .DESCRIPTION
    Filters Get-Disk results to include only fixed, online, non-offline disks
    with one or more partitions that are flagged as boot and system disks.

    .EXAMPLE
    Get-DiskBootWithPartitions
    Returns disk records for the boot/system disk set.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Added initial in-function help block
    #>
    [CmdletBinding()]
    param ()

    begin {}
    process {}
    end {
        Return Get-Disk | Sort DiskNumber | `
        Where {$_.NumberOfPartitions -ge '1'} | `
        Where {$_.ProvisioningType -eq 'Fixed'} | `
        Where {$_.OperationalStatus -eq 'Online'} | `
        Where {$_.BootFromDisk -eq $true} | `
        Where {$_.IsBoot -eq $true} | `
        Where {$_.IsOffline -eq $false} | `
        Where {$_.IsSystem -eq $true} | `
        Select DiskNumber,BusType,FriendlyName,Size,PartitionStyle,NumberOfPartitions,ProvisioningType,OperationalStatus,BootFromDisk,IsBoot,IsOffline,IsSystem
    }
}
