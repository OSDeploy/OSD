function Get-DiskNonBootWithPartitions {
    <#
    .SYNOPSIS
    Returns online fixed non-boot disks that contain partitions.

    .DESCRIPTION
    Filters Get-Disk results to include only fixed, online, non-offline disks
    with one or more partitions that are not boot or system disks.

    .EXAMPLE
    Get-DiskNonBootWithPartitions
    Returns disk records for non-boot data disks.

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
        Where {$_.BootFromDisk -eq $false} | `
        Where {$_.IsBoot -eq $false} | `
        Where {$_.IsOffline -eq $false} | `
        Where {$_.IsSystem -eq $false} | `
        Select DiskNumber,BusType,FriendlyName,Size,PartitionStyle,NumberOfPartitions,ProvisioningType,OperationalStatus,BootFromDisk,IsBoot,IsOffline,IsSystem
    }
}
