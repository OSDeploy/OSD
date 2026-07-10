function Get-OSDCoreDeploymentDisk {
    <#
    .SYNOPSIS
    Retrieves disk objects suitable for OS deployment with enhanced filtering capabilities.

    .DESCRIPTION
    Get-OSDCoreDeploymentDisk queries the system for physical disks and returns disk objects with extended properties including MediaType.
    The function automatically filters out offline disks, disks with no media, and incompatible bus types (USB, Virtual, etc.).
    It provides comprehensive filtering options based on disk properties such as boot status, bus type, media type, and partition style.

    .PARAMETER Number
    Specifies the disk number to retrieve. Can also be referenced using aliases 'Disk' or 'DiskNumber'.

    .PARAMETER BootFromDisk
    Filters disks where the system boots from the disk.

    .PARAMETER IsBoot
    Filters disks that contain boot partitions.

    .PARAMETER IsReadOnly
    Filters disks based on read-only status.

    .PARAMETER IsSystem
    Filters disks that contain system partitions.

    .PARAMETER BusType
    Filters disks by one or more specific bus types.
    Valid values: '1394', 'ATA', 'ATAPI', 'Fibre Channel', 'File Backed Virtual', 'iSCSI', 'MMC', 'MAX', 'Microsoft Reserved', 'NVMe', 'RAID', 'SAS', 'SATA', 'SCSI', 'SD', 'SSA', 'Storage Spaces', 'USB', 'Virtual'

    .PARAMETER BusTypeNot
    Excludes disks with specified bus types.
    Valid values: '1394', 'ATA', 'ATAPI', 'Fibre Channel', 'File Backed Virtual', 'iSCSI', 'MMC', 'MAX', 'Microsoft Reserved', 'NVMe', 'RAID', 'SAS', 'SATA', 'SCSI', 'SD', 'SSA', 'Storage Spaces', 'USB', 'Virtual'

    .PARAMETER MediaType
    Filters disks by one or more specific media types.
    Valid values: 'SSD', 'HDD', 'SCM', 'Unspecified'

    .PARAMETER MediaTypeNot
    Excludes disks with specified media types.
    Valid values: 'SSD', 'HDD', 'SCM', 'Unspecified'

    .PARAMETER PartitionStyle
    Filters disks by one or more specific partition styles.
    Valid values: 'GPT', 'MBR', 'RAW'

    .PARAMETER PartitionStyleNot
    Excludes disks with specified partition styles.
    Valid values: 'GPT', 'MBR', 'RAW'

    .EXAMPLE
    Get-OSDCoreDeploymentDisk

    Returns all available deployment-ready disks, excluding USB, virtual, and other incompatible bus types.

    .EXAMPLE
    Get-OSDCoreDeploymentDisk -Number 0

    Returns disk 0 if it meets deployment criteria.

    .EXAMPLE
    Get-OSDCoreDeploymentDisk -MediaType SSD

    Returns all SSD disks suitable for deployment.

    .EXAMPLE
    Get-OSDCoreDeploymentDisk -BusType NVMe,SATA -PartitionStyle GPT

    Returns all NVMe or SATA disks with GPT partition style.

    .EXAMPLE
    Get-OSDCoreDeploymentDisk -BusTypeNot USB -MediaTypeNot HDD

    Returns all non-USB, non-HDD disks (typically SSDs and NVMe drives).

    .NOTES
    Requires .NET System.Management access to the MSFT_Disk class and the Storage module Get-PhysicalDisk cmdlet.
    Automatically excludes: File Backed Virtual, MAX, Microsoft Reserved, USB, and Virtual bus types.
    The function throws an error if no disks match the specified criteria.
    A warning is issued when multiple disks match the criteria.
    #>
    [CmdletBinding()]
    param (
        [Alias('Disk','DiskNumber')]
        [uint32]$Number,

        [switch]$BootFromDisk,
        [switch]$IsBoot,
        [switch]$IsReadOnly,
        [switch]$IsSystem,

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
    # Test Get-PhysicalDisk and throw if not available
    if (-not (Get-Command -Name 'Get-PhysicalDisk' -ErrorAction SilentlyContinue)) {
        Throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Get-OSDCoreDeploymentDisk requires 'Get-PhysicalDisk' which is not available on this system"
    }
    #=================================================
    # Get Variables
    $busTypeMap = @{
        1  = 'SCSI'
        2  = 'ATAPI'
        3  = 'ATA'
        4  = '1394'
        5  = 'SSA'
        6  = 'Fibre Channel'
        7  = 'USB'
        8  = 'RAID'
        9  = 'iSCSI'
        10 = 'SAS'
        11 = 'SATA'
        12 = 'SD'
        13 = 'MMC'
        14 = 'Virtual'
        15 = 'File Backed Virtual'
        16 = 'Storage Spaces'
        17 = 'NVMe'
        18 = 'Microsoft Reserved'
        19 = 'MAX'
    }
    $partitionStyleMap = @{
        0 = 'RAW'
        1 = 'MBR'
        2 = 'GPT'
    }

    try {
        $searcher = [System.Management.ManagementObjectSearcher]::new(
            'root\Microsoft\Windows\Storage',
            'SELECT Number,IsOffline,OperationalStatus,BootFromDisk,IsBoot,IsReadOnly,IsSystem,BusType,PartitionStyle FROM MSFT_Disk'
        )
        $diskObjects = $searcher.Get()
    } catch {
        Throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to enumerate disks using MSFT_Disk via .NET: $($_.Exception.Message)"
    }

    $GetDisk = foreach ($diskObject in $diskObjects) {
        $busTypeCode = [int]$diskObject.BusType
        $partitionStyleCode = [int]$diskObject.PartitionStyle

        $operationalStatusCodes = @()
        if ($null -ne $diskObject.OperationalStatus) {
            if ($diskObject.OperationalStatus -is [System.Array]) {
                $operationalStatusCodes = @($diskObject.OperationalStatus | ForEach-Object { [int]$_ })
            } else {
                $operationalStatusCodes = @([int]$diskObject.OperationalStatus)
            }
        }

        $operationalStatus = if ($operationalStatusCodes -contains 31) {
            'No Media'
        } elseif ($operationalStatusCodes.Count -gt 0) {
            [string]$operationalStatusCodes[0]
        } else {
            'Unknown'
        }

        [PSCustomObject]@{
            Number           = [uint32]$diskObject.Number
            DiskNumber       = [uint32]$diskObject.Number
            IsOffline        = [bool]$diskObject.IsOffline
            OperationalStatus = $operationalStatus
            BootFromDisk     = [bool]$diskObject.BootFromDisk
            IsBoot           = [bool]$diskObject.IsBoot
            IsReadOnly       = [bool]$diskObject.IsReadOnly
            IsSystem         = [bool]$diskObject.IsSystem
            BusType          = if ($busTypeMap.ContainsKey($busTypeCode)) { $busTypeMap[$busTypeCode] } else { 'Unknown' }
            PartitionStyle   = if ($partitionStyleMap.ContainsKey($partitionStyleCode)) { $partitionStyleMap[$partitionStyleCode] } else { 'RAW' }
            MediaType        = 'Unspecified'
        }
    }

    $GetDisk = $GetDisk | Sort-Object DiskNumber
    $GetPhysicalDisk = Get-PhysicalDisk | Sort-Object DeviceId
    #=================================================
    # Add Property MediaType
    foreach ($Disk in $GetDisk) {
        foreach ($PhysicalDisk in $GetPhysicalDisk | Where-Object {$_.DeviceId -eq $Disk.Number}) {
            $Disk.MediaType = [string]$PhysicalDisk.MediaType
        }
    }
    #=================================================
    # Exclude Empty Disks or Card Readers
    $GetDisk = $GetDisk | Where-Object {$_.IsOffline -eq $false}
    $GetDisk = $GetDisk | Where-Object {$_.OperationalStatus -ne 'No Media'}
    #=================================================
    # Number
    if ($PSBoundParameters.ContainsKey('Number')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $Number}
    }
    #=================================================
    #	Filters
    if ($BootFromDisk) { $GetDisk = $GetDisk | Where-Object { $_.BootFromDisk -eq $true } }
    if ($IsBoot) { $GetDisk = $GetDisk | Where-Object { $_.IsBoot -eq $true } }
    if ($IsReadOnly) { $GetDisk = $GetDisk | Where-Object { $_.IsReadOnly -eq $true } }
    if ($IsSystem) { $GetDisk = $GetDisk | Where-Object { $_.IsSystem -eq $true } }
    if ($BusType) { $GetDisk = $GetDisk | Where-Object { $_.BusType -in $BusType } }
    if ($BusTypeNot) { $GetDisk = $GetDisk | Where-Object { $_.BusType -notin $BusTypeNot } }
    if ($MediaType) { $GetDisk = $GetDisk | Where-Object { $_.MediaType -in $MediaType } }
    if ($MediaTypeNot) { $GetDisk = $GetDisk | Where-Object { $_.MediaType -notin $MediaTypeNot } }
    if ($PartitionStyle) { $GetDisk = $GetDisk | Where-Object { $_.PartitionStyle -in $PartitionStyle } }
    if ($PartitionStyleNot) { $GetDisk = $GetDisk | Where-Object { $_.PartitionStyle -notin $PartitionStyleNot } }
    #=================================================
    # Filter out incompatible bustype
    $GetDisk = @($GetDisk | Where-Object { $_.BusType -notin 'File Backed Virtual','MAX','Microsoft Reserved','USB','Virtual' })
    #=================================================
    # if no disks found, throw
    if ($GetDisk.Count -eq 0) {
        Throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No disks were found that could be used for OSDCloud."
    }
    # if more than 1, then need to warn
    if ($GetDisk.Count -gt 1) {
        # Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] More than one disk is in this device."
        # Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] You will be prompted to clean one or more disks during OSDCloud."
    }

    return $GetDisk
    #=================================================
}
