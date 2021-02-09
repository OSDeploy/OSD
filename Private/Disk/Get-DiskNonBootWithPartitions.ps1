function Get-DiskNonBootWithPartitions {
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