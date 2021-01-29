function Get-DiskBootWithPartitions {
    [CmdletBinding()]
    Param ()

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