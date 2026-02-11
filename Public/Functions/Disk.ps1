<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu

.NOTES
21.1.27    Initial Release
#>
function Backup-DiskToFFU {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Start the Clock
    #=================================================
    $backupdiskffuStartTime = Get-Date
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	Module and Command Information
    #=================================================
    $GetCommandName = $MyInvocation.MyCommand | Select-Object -ExpandProperty Name
    $GetModuleBase = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty ModuleBase
    $GetModulePath = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Path
    $GetModuleVersion = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name $GetCommandName | Select-Object -ExpandProperty HelpUri
    Write-Host "$GetCommandName" -ForegroundColor Cyan
    Write-Host "$GetCommandHelpUri"
    Write-Host ""
    #=================================================
    #	Invoke-SelectFFUDisk
    #=================================================
    $SelectFFUDisk = Invoke-SelectFFUDisk -SelectOne
    #=================================================
    #	Bail if there are no results
    #=================================================
    if (-NOT ($SelectFFUDisk)) {
        Write-Warning "No Fixed Drives that met the required criteria were detected"
        Break
    }
    #=================================================
    #	Invoke-SelectDataDisk
    #=================================================
    $SelectFFUDestination = Invoke-SelectDataDisk -NotDiskNumber $SelectFFUDisk.DiskNumber
    #=================================================
    #	Bail if there are no results
    #=================================================
    if (-NOT ($SelectFFUDestination)) {
        Write-Warning "Could not find a Disk to use for an FFU Backup"
        Break
    }

    $Description = "$(Get-MyComputerManufacturer -Brief) $(Get-MyComputerModel -Brief) $(Get-MyBiosSerialNumber -Brief)"
    $Compress = 'Default'
    $DiskNumber = $SelectFFUDisk.DiskNumber
    $Name = "disk$DiskNumber"
    $ImageFile = "$($SelectFFUDestination.DriveLetter):\BackupFFU\$(Get-MyComputerManufacturer -Brief)\$(Get-MyComputerModel -Brief)\$(Get-MyBiosSerialNumber -Brief)_$Name.ffu"
    $ParentDirectory = Split-Path $ImageFile -Parent

    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Cmd Syntax:'
    Write-Host -ForegroundColor White       "DISM.exe /Capture-FFU /ImageFile=`"$ImageFile`" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:`"$Name`" /Description:`"$Description`" /Compress:$Compress"
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    
    do {$ConfirmFFU = Read-Host "Type FFU to create the Backup, or X to Exit"}
    until (($ConfirmFFU -eq 'FFU') -or ($ConfirmFFU -eq 'X'))

    if ($env:SystemDrive -ne 'X:') {
        Write-Warning "You need to boot into WinPE to capture the FFU, but you aren't so I'm not gonna do it for you!"
    }
    elseif ($ConfirmFFU -eq 'FFU') {
        if (!(Test-Path "$ParentDirectory")) {
            Try {New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop}
            Catch {Write-Warning "Destination appears to be Read Only.  Try another Destination Drive"; Break}
        }
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        Return Get-WindowsImage -ImagePath $ImageFile
    }
}
function Clear-LocalDisk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('I')]
        [System.Management.Automation.SwitchParameter]$Initialize,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [System.Management.Automation.SwitchParameter]$Force,

        [System.Management.Automation.SwitchParameter]$NoResults,

        [Alias('W','Warn','Warning')]
        [System.Management.Automation.SwitchParameter]$ShowWarning
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=================================================
    #	Enable Verbose if Force parameter is not $true
    #=================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    }
    #=================================================
    #	Get DiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #=================================================
    #	-PartitionStyle
    #=================================================
    if (-NOT ($PSBoundParameters.ContainsKey('PartitionStyle'))) {
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle = $PartitionStyle"
    #=================================================
    #	Get-Help
    #=================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #=================================================
    #	Display Disk Information
    #=================================================
    $GetDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName,Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
    
    if ($IsForcePresent -eq $false) {
        Break
    }
    #=================================================
    #	Display Warning
    #=================================================
    if ($PSBoundParameters.ContainsKey('ShowWarning')) {
        Write-Warning "All data on the cleared Disk will be cleared and all data will be lost"
        pause
    }
    #=================================================
    #	Clear-Disk
    #=================================================
    $ClearDisk = @()
    foreach ($Item in $GetDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
        ))
        {
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Diskpart-Clean -DiskNumber $Item.Number

            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    #=================================================
    #	Return
    #=================================================
    if ($PSBoundParameters.ContainsKey('NoResults')) {
        #Don't return results
    }
    else {
        $ClearDisk | Select-Object -Property DiskNumber, BusType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName, Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
    }
    #=================================================
}
function Clear-USBDisk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('I')]
        [System.Management.Automation.SwitchParameter]$Initialize,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('F')]
        [System.Management.Automation.SwitchParameter]$Force,

        [Alias('W','Warn','Warning')]
        [System.Management.Automation.SwitchParameter]$ShowWarning
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=================================================
    #	Enable Verbose if Force parameter is not $true
    #=================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-USBDisk | Sort-Object Number
    }
    #=================================================
    #	Get DiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #=================================================
    #	-PartitionStyle
    #=================================================
    if (-NOT ($PSBoundParameters.ContainsKey('PartitionStyle'))) {
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle = $PartitionStyle"
    #=================================================
    #	Get-Help
    #=================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #=================================================
    #	Display Disk Information
    #=================================================
    $GetDisk | Select-Object -Property Number, BusType, MediaType,`
    FriendlyName, PartitionStyle, NumberOfPartitions,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
    if ($IsForcePresent -eq $false) {
        Break
    }
    #=================================================
    #	Display Warning
    #=================================================
    if ($PSBoundParameters.ContainsKey('ShowWarning')) {
        Write-Warning "All data on the cleared Disk will be cleared and all data will be lost"
        pause
    }
    #=================================================
    #	Clear-Disk
    #=================================================
    $ClearDisk = @()
    foreach ($Item in $GetDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
        ))
        {
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Clear-Disk -Number $Item.Number -RemoveData -RemoveOEM -ErrorAction Stop
            
            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    #=================================================
    #	Return
    #=================================================
    $ClearDisk | Select-Object -Property Number, BusType, MediaType,`
    FriendlyName, PartitionStyle, NumberOfPartitions,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    #=================================================
}
function Get-DataDisk {
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
function Get-LocalDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-OSDDisk
    #=================================================
    $GetDisk = Get-OSDDisk -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',USB,Virtual
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
function Get-LocalDiskPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDPartition | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
function Get-LocalDiskVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDVolume | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
function Get-OSDDisk {
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
function Get-OSDPartition {
    [CmdletBinding()]
    param ()
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Get Variables
    #=================================================
    $GetDisk = Get-OSDDisk -BusType USB
    $GetPartition = Get-Partition | Sort-Object DiskNumber, PartitionNumber
    #=================================================
    #	Add Property IsUSB
    #=================================================
    foreach ($Partition in $GetPartition) {
        if ($Partition.DiskNumber -in $($GetDisk).DiskNumber) {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=================================================
    #	Return
    #=================================================
    Return $GetPartition
    #=================================================
}
function Get-OSDVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Get Variables
    #=================================================
    $GetPartition = Get-USBPartition
    $GetVolume = Get-Volume | Sort-Object DriveLetter
    #=================================================
    #	Add Property IsUSB
    #=================================================
    foreach ($Volume in $GetVolume) {
        if ($Volume.Path -in $($GetPartition).AccessPaths) {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=================================================
    #	Return
    #=================================================
    Return $GetVolume | Sort-Object DriveLetter | Select-Object -Property DriveLetter, FileSystemLabel, FileSystem, `
                        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}}, `
                        @{Name='SizeRemainingGB';Expression={[int]($_.SizeRemaining / 1000000000)}}, `
                        @{Name='SizeRemainingMB';Expression={[int]($_.SizeRemaining / 1000000)}}, `
                        IsUSB, DriveType, OperationalStatus, HealthStatus
    #=================================================
}
function Get-USBDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-OSDDisk
    #   Hyper-V VM: look for passthrough disks that are likely Offline USB (SSD/NVMe) drives
    #=================================================
    $isVM = Test-isVM

    if ($isVM) {
        $GetDisk = Get-OSDDisk -MediaType SSD
    }
    else {
        $GetDisk = Get-OSDDisk -BusType USB
    }
    
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
function Get-USBPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDPartition | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
function Get-USBVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDVolume | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
function Invoke-SelectDataDisk {
    [CmdletBinding()]
    param (
        [int]$NotDiskNumber,
        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=================================================
    $Results = Get-DataDisk | Sort-Object -Property DriveLetter
    #=================================================
    #	Filter NotDiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('NotDiskNumber')) {
        $Results = $Results | Where-Object {$_.DiskNumber -ne $NotDiskNumber}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        @{Name='FreeGB';Expression={[int]($_.SizeRemaining / 1000000000)}},`
        @{Name='TotalGB';Expression={[int]($_.Size / 1000000000)}},`
        FileSystem, DriveType, DiskNumber | Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Disk to save the FFU on by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Disk to save the FFU on by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectFFUDisk {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    $Results = Get-LocalDisk
    #=================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=================================================
    $Results = Get-LocalDisk
    $InUseDrives = $Results | Where-Object {$_.IsBoot -eq $true}
    foreach ($Item in $InUseDrives) {
        Write-Warning "$($Item.FriendlyName) cannot be backed up because it is in use"
    }
    $Results = $Results | Where-Object {$_.IsBoot -eq $false}
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectLocalDisk {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-LocalDisk
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectLocalVolume {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem,

        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Volume
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-LocalDiskVolume | Sort-Object -Property DriveLetter | `
        Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    }
    #=================================================
    #	Filter the File System
    #=================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $Results = $Results | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        SizeGB, SizeRemainingGB, SizeRemainingMB, DriveType | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Volume by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Volume by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectOSDDisk {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-LocalDisk
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($GetDisk | Measure-Object).Count -eq 1) {
                $SelectedItem = $GetDisk
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $GetDisk | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($GetDisk | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectOSDVolume {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem,

        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Volume
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-OSDVolume | Sort-Object -Property DriveLetter | `
        Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    }
    #=================================================
    #	Filter the File System
    #=================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $Results = $Results | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        SizeGB, SizeRemainingGB, SizeRemainingMB, `
        IsUSB, DriveType | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Volume by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Volume by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectUSBDisk {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        
        [Alias('Min','MinGB','MinSize')]
        [int]$MinimumSizeGB = 8,

        [Alias('Max','MaxGB','MaxSize')]
        [int]$MaximumSizeGB = 1800,

        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-USBDisk | Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Invoke-SelectUSBVolume {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem,

        [System.Management.Automation.SwitchParameter]
        $Skip,
        
        [System.Management.Automation.SwitchParameter]
        $SelectOne
    )
    #=================================================
    #	Get-Volume
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-USBVolume | Sort-Object -Property DriveLetter | `
        Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    }
    #=================================================
    #	Filter the File System
    #=================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $Results = $Results | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        SizeGB, SizeRemainingGB, SizeRemainingMB, DriveType | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}
function New-BootableUSBDrive {
    [CmdletBinding()]
    param (
        [ValidateLength(0,11)]
        [string]$BootLabel = 'USB Boot',

        [ValidateLength(0,32)]
        [string]$DataLabel = 'USB Data'
    )

    #=================================================
    #	Start the Clock
    #=================================================
    $osdbootStartTime = Get-Date
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    $MinimumSizeGB = 7
    $MaximumSizeGB = 2000
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    #	Disable Autorun
    #=================================================
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    #	Invoke-SelectUSBDisk
    #   Select a USB Disk
    #=================================================
    Write-Verbose '$SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB'
    $SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB
    #=================================================
    #	Invoke-SelectUSBDisk
    #   Select a USB Disk
    #=================================================
    if (-NOT ($SelectDisk)) {
        Write-Warning "No USB Drives that met the required criteria were detected"
        Write-Warning "MinimumSizeGB: $MinimumSizeGB"
        Write-Warning "MaximumSizeGB: $MaximumSizeGB"
        Break
    }
    #=================================================
    #	Get-OSDDisk -BusType USB
    #   At this point I have the Disk object in $GetUSBDisk
    #=================================================
    Write-Verbose '$GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number'
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number

    $GetUSBDisk
    #=================================================
    #	Clear-Disk
    #   Prompt for Confirmation
    #=================================================
    if ($GetUSBDisk.NumberOfPartitions -eq 0) {
        Write-Verbose "Disk does not have any partitions.  This is a good thing!"
    }
    else {
        Write-Verbose '$GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true'
        $GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true -ErrorAction Stop
    }
    #=================================================
    #	Get-OSDDisk -BusType USB
    #	Run another Get-Disk to make sure that things are ok
    #=================================================
    Write-Verbose '$GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}'
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}

    if (-NOT ($GetUSBDisk)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	-lt 2TB
    #=================================================
    if ($GetUSBDisk.PartitionStyle -eq 'RAW') {
        Write-Verbose '$GetUSBDisk | Initialize-Disk -PartitionStyle MBR'
        $GetUSBDisk | Initialize-Disk -PartitionStyle MBR -ErrorAction Stop
    }
    if ($GetUSBDisk.PartitionStyle -eq 'GPT') {
        Write-Verbose '$GetUSBDisk | Set-Disk -PartitionStyle MBR'
        Set-Disk -Number $GetUSBDisk.Number -PartitionStyle MBR -ErrorAction Stop
    }
    if ($GetUSBDisk.SizeGB -le 2000) {
        Write-Verbose '$DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel'
        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel -ErrorAction Stop
        
        Write-Verbose '$BootDisk = $GetUSBDisk | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel'
        $BootDisk = $GetUSBDisk | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel -ErrorAction Stop
    }
    #=================================================
    #	-ge 2TB
    #   This is not working as expected and will probably not be bootable
    #   So leaving it in here for historic purposes
    #=================================================
<#     if ($GetUSBDisk.SizeGB -gt 1800) {
        $GetUSBDisk | Initialize-Disk -PartitionStyle GPT
        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel

        $BootDisk = $GetUSBDisk | New-Partition -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel
    } #>
    #=================================================
    #	Complete
    #=================================================
    $osdbootEndTime = Get-Date
    $osdbootTimeSpan = New-TimeSpan -Start $osdbootStartTime -End $osdbootEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($osdbootTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDDisk -BusType USB -Number $SelectDisk.Number)
    #=================================================
}
function New-OSDisk {
    <#
    .SYNOPSIS
    Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

    .DESCRIPTION
    Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

    .PARAMETER DiskNumber
    Specifies the disk number for which to get the associated Disk object
    Alias = Disk, Number

    .PARAMETER Force
    Required for execution
    Alias = F

    .PARAMETER LabelRecovery
    Drive Label of the Recovery Partition
    Default = Recovery
    Alias = LR, LabelR

    .PARAMETER LabelSystem
    Drive Label of the System Partition
    Default = System
    Alias = LS, LabelS

    .PARAMETER LabelWindows
    Drive Label of the Windows Partition
    Default = OS
    Alias = LW, LabelW

    .PARAMETER NoRecoveryPartition
    Alias = SkipRecovery, SkipRecoveryPartition
    Skips the creation of the Recovery Partition

    .PARAMETER PartitionStyle
    Override the automatic Partition Style of the Initialized Disk
    EFI Default = GPT
    BIOS Default = MBR
    Alias = PS

    .PARAMETER SizeMSR
    MSR Partition size
    Default = 16MB
    Range = 16MB - 128MB
    Alias = MSR

    .PARAMETER SizeRecovery
    Size of the Recovery Partition
    Default = 990MB
    Range = 350MB - 80000MB (80GB)
    Alias = SR, Recovery

    .PARAMETER SizeSystemGpt
    System Partition size for UEFI GPT based Computers
    Default = 260MB
    Range = 100MB - 3000MB (3GB)
    Alias = SSG, Efi, SystemG

    .PARAMETER SizeSystemMbr
    System Partition size for BIOS MBR based Computers
    Default = 260MB
    Range = 100MB - 3000MB (3GB)
    Alias = SSM, Mbr, SystemM

    .EXAMPLE
    New-OSDisk
    Displays Get-Help New-OSDisk

    .EXAMPLE
    New-OSDisk -Force
    Interactive.  Prompted to Confirm Clear-Disk for each Local Disk

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    19.10.10    Created by David Segura @SeguraOSD
    21.2.19     Complete redesign
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Alias('LS','LabelS')]
        [string]$LabelSystem = 'System',

        [Alias('SSG','Efi','SystemG')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 260MB,

        [Alias('SSM','Mbr','SystemM')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 260MB,

        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,

        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'OS',

        [Alias('SkipRecovery','SkipRecoveryPartition')]
        [System.Management.Automation.SwitchParameter]$NoRecoveryPartition,

        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [System.Management.Automation.SwitchParameter]$Force
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-WinOS
    #=================================================
    #	Enable Verbose if Force parameter is not $true
    #=================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-LocalDisk | Sort-Object Number
    }
    #=================================================
    #	Get DiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #=================================================
    #	OSDisks must be large enough for a Windows installation
    #=================================================
    $GetDisk = $GetDisk | Where-Object {$_.Size -gt 15GB}
    #=================================================
    #	-PartitionStyle
    #=================================================
    if (-NOT ($PSBoundParameters.ContainsKey('PartitionStyle'))) {
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle = $PartitionStyle"
    #=================================================
    #	Get-Help
    #=================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #=================================================
    #	Display Disk Information
    #=================================================
    if ($IsForcePresent -eq $false) {
        $GetDisk | Select-Object -Property DiskNumber, BusType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName, Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        
        Break
    }
    #=================================================
    #	Failure: No Fixed Disks are present
    #=================================================
    if ($null -eq $GetDisk) {
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #=================================================
    #	Set Defaults
    #=================================================
    $OSDisk = $null
    $DataDisks = $null
    #=================================================
    #	Identify OSDisk
    #=================================================
    if (($GetDisk | Measure-Object).Count -eq 1) {
        $OSDisk = $GetDisk
    } else {

        $OSDisk = Invoke-SelectLocalDisk -Input $GetDisk
        $DataDisks = $GetDisk | Where-Object {$_.Number -ne $OSDisk.Number}
    }
    Write-Host ""
    #=================================================
    #	Make sure there is only one OSDisk
    #=================================================
    if (($OSDisk | Measure-Object).Count -gt 1) {
        Write-Warning "Something went wrong"
        Break
    }
    #=================================================
    #   Create OSDisk
    #=================================================
    #Create from RAW Disk
    if (($OSDisk.NumberOfPartitions -eq 0) -and ($OSDisk.PartitionStyle -eq 'RAW')) {
        Write-Verbose "Initializing Disk $($OSDisk.Number) as $PartitionStyle"
        $OSDisk | Initialize-Disk -PartitionStyle $PartitionStyle

    }
    #Create from unpartitioned Disk
    elseif (($OSDisk.NumberOfPartitions -eq 0) -and ($OSDisk.PartitionStyle -ne $PartitionStyle)) {
        Write-Verbose "Cleaning Disk $($OSDisk.Number)"
        Diskpart-Clean -DiskNumber $OSDisk.Number

        Write-Verbose "Initializing Disk $($OSDisk.Number) as $PartitionStyle"
        $OSDisk | Initialize-Disk -PartitionStyle $PartitionStyle
    }
    #Prompt for confirmation to clear the existing disk
    else {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($OSDisk.Number) $($OSDisk.BusType) $($OSDisk.SizeGB) $($OSDisk.FriendlyName) $($OSDisk.Model) [$($OSDisk.PartitionStyle) $($OSDisk.NumberOfPartitions) Partitions]",
            "Clear-Disk"
        ))
        {
            Write-Warning "Cleaning Disk $($OSDisk.Number) $($OSDisk.BusType) $($OSDisk.SizeGB) $($OSDisk.FriendlyName) $($OSDisk.Model) [$($OSDisk.PartitionStyle) $($OSDisk.NumberOfPartitions) Partitions]"
            Diskpart-Clean -DiskNumber $OSDisk.Number

            Write-Warning "Initializing $PartitionStyle Disk $($OSDisk.Number) $($OSDisk.BusType) $($OSDisk.SizeGB) $($OSDisk.FriendlyName) $($OSDisk.Model)"
            $OSDisk | Initialize-Disk -PartitionStyle $PartitionStyle
        }
    }
    #=================================================
    #	Reassign Volume S
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'S'}

    if ($GetVolume) {
        Write-Verbose "Reassigning Drive Letter S"
        #Get-Partition -DriveLetter 'S' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
        Get-Volume -DriveLetter S | Get-Partition | Remove-PartitionAccessPath -AccessPath 'S:\' -ErrorAction SilentlyContinue
    }
    #=================================================
    #	System Partition
    #=================================================
    $SystemPartition = @{
        DiskNumber          = $OSDisk.Number
        LabelSystem         = $LabelSystem
        PartitionStyle      = $PartitionStyle
        SizeMSR             = $SizeMSR
        SizeSystemMbr       = $SizeSystemMbr
        SizeSystemGpt       = $SizeSystemGpt
    }
    New-OSDPartitionSystem @SystemPartition
    #=================================================
    #	Reassign Volume C
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'C'}

    if ($GetVolume) {
        Write-Verbose "Reassigning Drive Letter C"
        Get-Partition -DriveLetter 'C' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
    }
    #=================================================
    #	Reassign Volume R
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'R'}

    if ($GetVolume) {
        Write-Verbose "Reassigning Drive Letter R"
        #Get-Partition -DriveLetter 'R' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
        Get-Volume -DriveLetter R | Get-Partition | Remove-PartitionAccessPath -AccessPath 'R:\' -ErrorAction SilentlyContinue
    }
    #=================================================
    #	Windows Partition
    #=================================================
    $WindowsPartition = @{
        DiskNumber              = $OSDisk.Number
        LabelRecovery           = $LabelRecovery
        LabelWindows            = $LabelWindows
        PartitionStyle          = $PartitionStyle
        SizeRecovery            = $SizeRecovery
        NoRecoveryPartition     = $NoRecoveryPartition
    }
    New-OSDPartitionWindows @WindowsPartition
    #=================================================
    #	DataDisks
    #=================================================
    Get-OSDDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName, Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
}
function Start-DiskImageGUI {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #	Run
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\DiskImageGUI.ps1"
    #=======================================================================
}
