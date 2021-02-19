<#
.SYNOPSIS
Similar to Get-Disk, but includes the MediaType

.DESCRIPTION
Similar to Get-Disk, but includes the MediaType

.PARAMETER Number
Specifies the disk number for which to get the associated Disk object
Alias = Disk, DiskNumber

.PARAMETER BootFromDisk
Returns Disk results based BootFromDisk property
PS> Get-OSDDisk -BootFromDisk:$true
PS> Get-OSDDisk -BootFromDisk:$false

.PARAMETER IsBoot
Returns Disk results based IsBoot property
PS> Get-OSDDisk -IsBoot:$true
PS> Get-OSDDisk -IsBoot:$false

.PARAMETER IsReadOnly
Returns Disk results based IsReadOnly property
PS> Get-OSDDisk -IsReadOnly:$true
PS> Get-OSDDisk -IsReadOnly:$false

.PARAMETER IsSystem
Returns Disk results based IsSystem property
PS> Get-OSDDisk -IsSystem:$true
PS> Get-OSDDisk -IsSystem:$false

.PARAMETER BusType
Returns Disk results in BusType values
Values = 'ATA','NVMe','SAS','SCSI','USB','Virtual'
PS> Get-OSDDisk -BusType NVMe
PS> Get-OSDDisk -BusType NVMe,SAS

.PARAMETER BusTypeNot
Returns Disk results notin BusType values
Values = 'ATA','NVMe','SAS','SCSI','USB','Virtual'
PS> Get-OSDDisk -BusTypeNot USB
PS> Get-OSDDisk -BusTypeNot USB,Virtual

.PARAMETER MediaType
Returns Disk results in MediaType values
Values = 'HDD','SSD','Unspecified'
PS> Get-OSDDisk -MediaType SSD

.PARAMETER MediaTypeNot
Returns Disk results notin MediaType values
Values = 'HDD','SSD','Unspecified'
PS> Get-OSDDisk -MediaTypeNot HDD

.PARAMETER PartitionStyle
Returns Disk results in PartitionStyle values
Values = 'GPT','MBR','RAW')
PS> Get-OSDDisk -PartitionStyle GPT

.PARAMETER PartitionStyleNot
Returns Disk results notin PartitionStyle values
Values = 'GPT','MBR','RAW')
PS> Get-OSDDisk -PartitionStyleNot RAW

.LINK
https://osd.osdeploy.com/module/osddisk/get-osddisk

.NOTES
19.10.10    Created by David Segura @SeguraOSD
21.2.19     Complete redesign
#>
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
        if ($BusType)               {$GetDisk = $GetDisk | Where-Object {$_.BusType -in $BusType}}
        if ($BusTypeNot)            {$GetDisk = $GetDisk | Where-Object {$_.BusType -notin $BusTypeNot}}
        if ($IsBoot)                {$GetDisk = $GetDisk | Where-Object {$_.IsBoot -in $IsBoot}}
        if ($IsReadOnly)            {$GetDisk = $GetDisk | Where-Object {$_.IsReadOnly -in $IsReadOnly}}
        if ($IsSystem)              {$GetDisk = $GetDisk | Where-Object {$_.IsSystem -in $IsSystem}}
        if ($MediaType)             {$GetDisk = $GetDisk | Where-Object {$_.MediaType -in $MediaType}}
        if ($MediaTypeNot)          {$GetDisk = $GetDisk | Where-Object {$_.MediaType -notin $MediaTypeNot}}
        if ($PartitionStyle)        {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -in $PartitionStyle}}
        if ($PartitionStyleNot)     {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -notin $PartitionStyleNot}}
        Return $GetDisk
    }
}