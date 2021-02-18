function Get-OSDDisk {
    [CmdletBinding()]
    param (
        [Alias('Disk','DiskNumber')]
        [uint32]$Number,

        [bool]$BootFromDisk,
        [bool]$IsBoot,
        [bool]$IsReadOnly,
        [bool]$IsSystem,

        [ValidateSet('ATA','NVMe','SAS','SCSI','USB','Virtual')]
        [string[]]$BusType,
        [ValidateSet('ATA','NVMe','SAS','SCSI','USB','Virtual')]
        [string[]]$BusTypeNot,
        
        [ValidateSet('HDD','SSD','Unspecified')]
        [string[]]$MediaType,
        [ValidateSet('HDD','SSD','Unspecified')]
        [string[]]$MediaTypeNot,

        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyle,
        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyleNot
    )

    begin {
        if ($Number) {
            $GetDisk = Get-Disk -Number $Number | Select-Object -Property *
            $GetPhysicalDisk = Get-PhysicalDisk -DeviceNumber $Number | Sort-Object DeviceId
        } else {
            $GetDisk = Get-Disk | Sort-Object DiskNumber | Select-Object -Property *
            $GetPhysicalDisk = Get-PhysicalDisk | Sort-Object DeviceId
        }
    }
    process {
        foreach ($Disk in $GetDisk) {
            foreach ($PhysicalDisk in $GetPhysicalDisk | Where-Object {$_.DeviceId -eq $Disk.Number}) {
                $Disk | Add-Member -NotePropertyName 'MediaType' -NotePropertyValue $PhysicalDisk.MediaType
            }
        }
        if ($GetDisk) {
            Write-Verbose "The following Disks are present"
            foreach ($item in $GetDisk) {
                Write-Verbose "Disk $($item.Number) $($item.BusType) $($item.MediaType) $($item.FriendlyName) [$($item.PartitionStyle) $($item.NumberOfPartitions) Partitions]"
            }
        }
    }
    end {
        if ($BootFromDisk)          {$GetDisk = $GetDisk | Where-Object {$_.BootFromDisk -in $BootFromDisk}}
        if ($IsBoot)                {$GetDisk = $GetDisk | Where-Object {$_.IsBoot -in $IsBoot}}
        if ($IsReadOnly)            {$GetDisk = $GetDisk | Where-Object {$_.IsReadOnly -in $IsReadOnly}}
        if ($IsSystem)              {$GetDisk = $GetDisk | Where-Object {$_.IsSystem -in $IsSystem}}
        if ($BusType)               {$GetDisk = $GetDisk | Where-Object {$_.BusType -in $BusType}}
        if ($BusTypeNot)            {$GetDisk = $GetDisk | Where-Object {$_.BusType -notin $BusTypeNot}}
        if ($MediaType)             {$GetDisk = $GetDisk | Where-Object {$_.MediaType -in $MediaType}}
        if ($MediaTypeNot)          {$GetDisk = $GetDisk | Where-Object {$_.MediaType -notin $MediaTypeNot}}
        if ($PartitionStyle)        {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -in $PartitionStyle}}
        if ($PartitionStyleNot)     {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -notin $PartitionStyleNot}}
        Return $GetDisk
    }
}