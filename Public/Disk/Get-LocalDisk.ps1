<#
.SYNOPSIS
Returns Get-Disk + MediaType with BusTypeNot USB,Virtual

.DESCRIPTION
Returns Get-Disk + MediaType with BusTypeNot USB,Virtual

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
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS> Get-OSDDisk -BusType NVMe
PS> Get-OSDDisk -BusType NVMe,SAS

.PARAMETER BusTypeNot
Returns Disk results notin BusType values
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS> Get-OSDDisk -BusTypeNot USB
PS> Get-OSDDisk -BusTypeNot USB,Virtual

.PARAMETER MediaType
Returns Disk results in MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
PS> Get-OSDDisk -MediaType SSD

.PARAMETER MediaTypeNot
Returns Disk results notin MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
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
https://osd.osdeploy.com/module/functions/disk/get-localdisk

.NOTES
21.3.5  Added more BusTypes
21.2.22 Initial Release
#>
function Get-LocalDisk {
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
    #======================================================================================================
    #	PSBoundParameters
    #======================================================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #======================================================================================================
    #	OSD Module and Command Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	Get-OSDDisk
    #======================================================================================================
    $GetLocalDisk = Get-OSDDisk -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',SD,USB,Virtual
    #======================================================================================================
    #	-Number
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('Number')) {
        $GetLocalDisk = $GetLocalDisk | Where-Object {$_.DiskNumber -eq $Number}
    }
    #======================================================================================================
    #	Filters
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('BootFromDisk')) {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.BootFromDisk -eq $BootFromDisk}}
    if ($PSBoundParameters.ContainsKey('IsBoot')) {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.IsBoot -eq $IsBoot}}
    if ($PSBoundParameters.ContainsKey('IsReadOnly')) {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.IsReadOnly -eq $IsReadOnly}}
    if ($PSBoundParameters.ContainsKey('IsSystem')) {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.IsSystem -eq $IsSystem}}

    if ($BusType)               {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.BusType -in $BusType}}
    if ($BusTypeNot)            {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.BusType -notin $BusTypeNot}}
    if ($MediaType)             {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.MediaType -in $MediaType}}
    if ($MediaTypeNot)          {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.MediaType -notin $MediaTypeNot}}
    if ($PartitionStyle)        {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.PartitionStyle -in $PartitionStyle}}
    if ($PartitionStyleNot)     {$GetLocalDisk = $GetLocalDisk | Where-Object {$_.PartitionStyle -notin $PartitionStyleNot}}
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetLocalDisk
    #======================================================================================================
}