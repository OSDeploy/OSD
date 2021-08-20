
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
PS> Get-Disk.osd -BootFromDisk:$true
PS> Get-Disk.osd -BootFromDisk:$false

.PARAMETER IsBoot
Returns Disk results based IsBoot property
PS> Get-Disk.osd -IsBoot:$true
PS> Get-Disk.osd -IsBoot:$false

.PARAMETER IsReadOnly
Returns Disk results based IsReadOnly property
PS> Get-Disk.osd -IsReadOnly:$true
PS> Get-Disk.osd -IsReadOnly:$false

.PARAMETER IsSystem
Returns Disk results based IsSystem property
PS> Get-Disk.osd -IsSystem:$true
PS> Get-Disk.osd -IsSystem:$false

.PARAMETER BusType
Returns Disk results in BusType values
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS> Get-Disk.osd -BusType NVMe
PS> Get-Disk.osd -BusType NVMe,SAS

.PARAMETER BusTypeNot
Returns Disk results notin BusType values
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS> Get-Disk.osd -BusTypeNot USB
PS> Get-Disk.osd -BusTypeNot USB,Virtual

.PARAMETER MediaType
Returns Disk results in MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
PS> Get-Disk.osd -MediaType SSD

.PARAMETER MediaTypeNot
Returns Disk results notin MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
PS> Get-Disk.osd -MediaTypeNot HDD

.PARAMETER PartitionStyle
Returns Disk results in PartitionStyle values
Values = 'GPT','MBR','RAW'
PS> Get-Disk.osd -PartitionStyle GPT

.PARAMETER PartitionStyleNot
Returns Disk results notin PartitionStyle values
Values = 'GPT','MBR','RAW'
PS> Get-Disk.osd -PartitionStyleNot RAW

.LINK
https://osd.osdeploy.com/module/functions/disk/get-disk

.NOTES
21.3.9      Removed Offline Drives
21.3.5      Added more BusTypes
21.2.19     Complete redesign
19.10.10    Created by David Segura @SeguraOSD
#>
function Get-Disk.osd {
    [CmdletBinding()]
    param (
        [Alias('Disk','DiskNumber')]
        [uint32]$Number,

        [bool]$BootFromDisk,
        [bool]$IsBoot,
        [bool]$IsReadOnly,
        [bool]$IsSystem,

        [ValidateSet('1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual')]
        [string[]]$BusType,
        [ValidateSet('1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual')]
        [string[]]$BusTypeNot,
        
        [ValidateSet('SSD','HDD','SCM','Unspecified')]
        [string[]]$MediaType,
        [ValidateSet('SSD','HDD','SCM','Unspecified')]
        [string[]]$MediaTypeNot,

        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyle,
        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyleNot
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Get Variables
    #=================================================
    $GetDisk = Get-Disk | Sort-Object DiskNumber | Select-Object -Property *
    $GetPhysicalDisk = Get-PhysicalDisk | Sort-Object DeviceId
    #=================================================
    #	Add Property MediaType
    #=================================================
    foreach ($Disk in $GetDisk) {
        foreach ($PhysicalDisk in $GetPhysicalDisk | Where-Object {$_.DeviceId -eq $Disk.Number}) {
            $Disk | Add-Member -NotePropertyName 'MediaType' -NotePropertyValue $PhysicalDisk.MediaType
        }
    }
    #=================================================
    #	Exclude Empty Disks or Card Readers
    #=================================================
    $GetDisk = $GetDisk | Where-Object {$_.IsOffline -eq $false}
    $GetDisk = $GetDisk | Where-Object {$_.OperationalStatus -ne 'No Media'}
    #=================================================
    #	-Number
    #=================================================
    if ($PSBoundParameters.ContainsKey('Number')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $Number}
    }
    #=================================================
    #	Filters
    #=================================================
    if ($PSBoundParameters.ContainsKey('BootFromDisk')) {$GetDisk = $GetDisk | Where-Object {$_.BootFromDisk -eq $BootFromDisk}}
    if ($PSBoundParameters.ContainsKey('IsBoot')) {$GetDisk = $GetDisk | Where-Object {$_.IsBoot -eq $IsBoot}}
    if ($PSBoundParameters.ContainsKey('IsReadOnly')) {$GetDisk = $GetDisk | Where-Object {$_.IsReadOnly -eq $IsReadOnly}}
    if ($PSBoundParameters.ContainsKey('IsSystem')) {$GetDisk = $GetDisk | Where-Object {$_.IsSystem -eq $IsSystem}}

    if ($BusType)               {$GetDisk = $GetDisk | Where-Object {$_.BusType -in $BusType}}
    if ($BusTypeNot)            {$GetDisk = $GetDisk | Where-Object {$_.BusType -notin $BusTypeNot}}
    if ($MediaType)             {$GetDisk = $GetDisk | Where-Object {$_.MediaType -in $MediaType}}
    if ($MediaTypeNot)          {$GetDisk = $GetDisk | Where-Object {$_.MediaType -notin $MediaTypeNot}}
    if ($PartitionStyle)        {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -in $PartitionStyle}}
    if ($PartitionStyleNot)     {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -notin $PartitionStyleNot}}
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
<#
.SYNOPSIS
Get-Disk with Fixed Disk results

.DESCRIPTION
Get-Disk with Fixed Disk results

.LINK
https://osd.osdeploy.com/module/functions
#>
function Get-Disk.fixed {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-Disk.osd
    #=================================================
    $GetDisk = Get-Disk.osd -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',USB,Virtual
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
<#
.SYNOPSIS
Get-Disk with USB Disk results

.DESCRIPTION
Get-Disk with USB Disk results

.LINK
https://osd.osdeploy.com/module/functions
#>
function Get-Disk.usb {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-Disk.osd
    #=================================================
    $GetDisk = Get-Disk.osd -BusType USB
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
function Get-Disk.storage {
    [CmdletBinding()]
    param ()
    #=================================================
    #   Get-Partition Information
    #=================================================
    $GetPartition = Get-Partition | `
    Where-Object {$_.DriveLetter -gt 0} | `
    Where-Object {$_.IsOffline -eq $false} | `
    Where-Object {$_.IsReadOnly -ne $true} | `
    Where-Object {$_.Size -gt 10000000000} | `
    Sort-Object -Property DriveLetter | `
    Select-Object -Property DriveLetter, DiskNumber
    #=================================================
    #   Get-Volume Information
    #=================================================
    $GetVolume = $(Get-Volume | `
    Sort-Object -Property DriveLetter | `
    Select-Object -Property DriveLetter,FileSystem,OperationalStatus,DriveType,FileSystemLabel,Size,SizeRemaining)
    #=================================================
    #   Create Object
    #=================================================
    $LocalResults = foreach ($Item in $GetPartition) {
        $GetVolumeProperties = $GetVolume | Where-Object {$_.DriveLetter -eq $Item.DriveLetter}
        $ObjectProperties = @{
            
            DiskNumber          = $Item.DiskNumber
            DriveLetter         = $GetVolumeProperties.DriveLetter
            FileSystem          = $GetVolumeProperties.FileSystem
            OperationalStatus   = $GetVolumeProperties.OperationalStatus
            DriveType           = $GetVolumeProperties.DriveType
            FileSystemLabel     = $GetVolumeProperties.FileSystemLabel
            Size                = $GetVolumeProperties.Size
            SizeRemaining       = $GetVolumeProperties.SizeRemaining

        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   Get-DriveInfo
    #=================================================
    $GetNetworkDrives = [System.IO.DriveInfo]::getdrives() | Where-Object {$_.DriveType -eq 'Network'} | Where-Object {$_.DriveFormat -eq 'NTFS'}
    $NetworkResults = foreach ($Item in $GetNetworkDrives) {
        $ObjectProperties = @{
            DiskNumber          = 99
            DriveLetter         = ($Item.Name).substring(0,1)
            FileSystem          = 'NTFS'
            OperationalStatus   = $Item.IsReady
            DriveType           = 'Network'
            FileSystemLabel     = $Item.VolumeLabel
            Size                = $Item.TotalSize
            SizeRemaining       = $Item.TotalFreeSpace

        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   Return Results
    #=================================================
    $LocalResults = $LocalResults | Sort-Object -Property DriveLetter
    $LocalResults = $LocalResults | Where-Object {$_.FileSystem -eq 'NTFS'}
    [array]$Results = [array]$LocalResults + [array]$NetworkResults
    Return [array]$Results
}