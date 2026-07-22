function New-OSDCloudPartitionSystem {
    <#
    .SYNOPSIS
    Creates the system partition layout for GPT or MBR disks.

    .DESCRIPTION
    Creates the system partition layout for GPT or MBR disks, formats the partition,
    applies the expected partition attributes, and assigns drive letter S for OSDCloud workflows.

    .PARAMETER DiskNumber
    Target disk number to partition.

    .PARAMETER LabelSystem
    Volume label to apply to the system partition.

    .PARAMETER PartitionStyle
    Partition style to use, GPT or MBR. If omitted, the style is inferred from the current boot mode.

    .PARAMETER SizeSystemMbr
    System partition size for MBR layouts.

    .PARAMETER SizeSystemGpt
    System partition size for GPT layouts.

    .PARAMETER SizeMSR
    MSR partition size for GPT layouts.

    .EXAMPLE
    New-OSDCloudPartitionSystem -DiskNumber 0 -PartitionStyle GPT
    Creates and formats GPT system and MSR partitions on disk 0.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-21 - Refreshed help, parameter comments, and verbose tracing
    #>
    [CmdletBinding()]
    param (
        #Target disk number to partition
        #Aliases: Disk, Number
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        #Volume label for the system partition
        #Default = System
        [string]$LabelSystem = 'System',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #System partition size for BIOS or legacy MBR layouts
        #Default = 499MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 499MB,

        #System partition size for UEFI GPT layouts
        #Default = 499MB
        #Range = 100MB - 3000MB (3GB)
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 499MB,

        #MSR partition size for GPT layouts
        #Default = 16MB
        #Range = 16MB - 128MB
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB
    )
    #=================================================
    #	PartitionStyle
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting system partition workflow for disk $DiskNumber"
    if (-NOT ($PartitionStyle)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle was not supplied; inferring from current boot mode"
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle is set to $PartitionStyle"
    #=================================================
    #	GPT
    #=================================================
    if ($PartitionStyle -eq 'GPT') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT system partition on disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT System Partition"
        $PartitionSystem = New-Partition -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DiskNumber $DiskNumber -Size $SizeSystemGpt

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT system partition as FAT32 with label $LabelSystem"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT System Partition FAT32 with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'fat32' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the EFI system partition GPT type"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"
        $PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Assigning drive letter S to the GPT system partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting GPT System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT MSR partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MSR Partition GptType {e3c9e316-0b5c-4db8-817d-f92df00215ae}"
        $null = New-Partition -DiskNumber $DiskNumber -Size $SizeMSR -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
    }
    #=================================================
    #	MBR
    #=================================================
    if ($PartitionStyle -eq 'MBR') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating active MBR system partition on disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR System Partition as Active"
        $PartitionSystem = New-Partition -DiskNumber $DiskNumber -Size $SizeSystemMbr -IsActive

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR system partition as NTFS with label $LabelSystem"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR System Partition NTFS with Label $LabelSystem"
        Invoke-DiskpartFormatSystemPartition -DiskNumber $DiskNumber -PartitionNumber $PartitionSystem.PartitionNumber -FileSystem 'ntfs' -LabelSystem $LabelSystem

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Assigning drive letter S to the MBR system partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Setting MBR System Partition NewDriveLetter S"
        $PartitionSystem | Set-Partition -NewDriveLetter S
    }
}
function New-OSDCloudPartitionWindows {
    <#
    .SYNOPSIS
    Creates the Windows and optional recovery partitions.

    .DESCRIPTION
    Builds GPT or MBR Windows layouts, formats the Windows partition, optionally creates the recovery partition,
    and assigns the drive letters and recovery attributes expected by Windows deployment workflows.

    .PARAMETER DiskNumber
    Target disk number to partition.

    .PARAMETER LabelRecovery
    Volume label to apply to the recovery partition.

    .PARAMETER LabelWindows
    Volume label to apply to the Windows partition.

    .PARAMETER PartitionStyle
    Partition style to use, GPT or MBR. If omitted, the style is inferred from the current boot mode.

    .PARAMETER SizeRecovery
    Recovery partition size when the recovery partition is created.

    .PARAMETER NoRecoveryPartition
    Skips creation of the recovery partition.

    .EXAMPLE
    New-OSDPartitionWindows -DiskNumber 0 -PartitionStyle GPT
    Creates Windows and recovery partitions on disk 0.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-21 - Refreshed help, parameter comments, and verbose tracing
    #>
    [CmdletBinding()]
    param (
        #Target disk number to partition
        #Default = 0
        #Aliases: Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Volume label for the recovery partition
        #Default = Recovery
        #Aliases: LR, LabelR
        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        #Volume label for the Windows partition
        #Default = Windows
        #Aliases: LW, LabelW
        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'Windows',

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        #Recovery partition size when recovery is created
        #Default = 2000MB
        #Range = 350MB - 80000MB (80GB)
        #Aliases: SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 2000MB,

        #Skips creation of the recovery partition
        [Alias('SkipRecovery','SkipRecoveryPartition')]
        [System.Management.Automation.SwitchParameter]$NoRecoveryPartition
    )
    #=================================================
    #	Get-OSDCloudDisk
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting Windows partition workflow for disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Looking up disk metadata for disk $DiskNumber"
    $GetOSDDisk = Get-OSDCloudDisk -Number $DiskNumber
    #=================================================
    #	Failure: No Fixed Disks are present
    #=================================================
    if ($null -eq $GetOSDDisk) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Disk lookup failed for disk $DiskNumber"
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #=================================================
    #	PartitionStyle
    #=================================================
    if (-NOT ($PartitionStyle)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle was not supplied; inferring from current boot mode"
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle is set to $PartitionStyle"
    #=================================================
    #	GPT WINDOWS
    #=================================================
    if ($PartitionStyle -eq 'GPT' -and $NoRecoveryPartition -eq $true) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows partition without a recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select partition $($PartitionWindows.PartitionNumber)"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> format fs=$FileSystem quick label='$LabelWindows'"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> assign letter C"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	GPT WINDOWS + RECOVERY
    #=================================================
    if ($PartitionStyle -eq 'GPT' -and $NoRecoveryPartition -eq $false) {

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Calculating Windows partition size from the remaining free space"
        $SizeWindows = $($GetOSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows partition with a recovery partition reserved"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -DriveLetter C

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Windows Partition NTFS with Label $LabelWindows on Drive Letter C"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating GPT Recovery Partition"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the GPT recovery partition as NTFS with label $LabelRecovery"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume FileSystem NTFS NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting GPT Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the recovery partition GPT attributes"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set-Partition Attributes 0x8000000000000001"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
gpt attributes=0x8000000000000001
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	MBR WINDOWS
    #=================================================
    if ($PartitionStyle -eq 'MBR' -and $NoRecoveryPartition -eq $true) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows partition without a recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -MbrType IFS -DriveLetter C

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume -DriveLetter C -FileSystem NTFS -NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"
$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe
    }
    #=================================================
    #	MBR WINDOWS + RECOVERY
    #=================================================
    if ($PartitionStyle -eq 'MBR' -and $NoRecoveryPartition -eq $false) {

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Reading disk geometry before creating the MBR Windows partition"
        $OSDDisk = Get-Disk -Number $DiskNumber
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Calculating Windows partition size from the remaining free space"
        $SizeWindows = $($OSDDisk.LargestFreeExtent) - $SizeRecovery
        $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows partition with a recovery partition reserved"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR Windows Partition"
        $PartitionWindows = New-Partition -DiskNumber $DiskNumber -Size $SizeWindows -MbrType IFS -DriveLetter c

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR Windows partition as NTFS with label $LabelWindows"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume FileSystem NTFS NewFileSystemLabel $LabelWindows"
        #$null = Format-Volume -Partition $PartitionWindows -NewFileSystemLabel "$LabelWindows" -FileSystem NTFS -Force -Confirm:$false
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting MBR Recovery Partition NTFS with Label $LabelRecovery on Drive Letter R"

$null = @"
select disk $DiskNumber
select partition $($PartitionWindows.PartitionNumber)
format fs=ntfs quick label="$LabelWindows"
assign letter C
exit 
"@ | diskpart.exe

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating MBR recovery partition"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] New-Partition -DiskNumber $DiskNumber -UseMaximumSize"
        $PartitionRecovery = New-Partition -DiskNumber $DiskNumber -UseMaximumSize

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Formatting the MBR recovery partition as NTFS with label $LabelRecovery"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Format-Volume -FileSystem NTFS -NewFileSystemLabel $LabelRecovery"
        #$null = Format-Volume -Partition $PartitionRecovery -NewFileSystemLabel "$LabelRecovery" -FileSystem NTFS -Confirm:$false

$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
format fs=ntfs quick label="$LabelRecovery"
assign letter R
exit 
"@ | diskpart.exe

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying the recovery partition ID 27"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set-Partition id 27"
$null = @"
select disk $DiskNumber
select partition $($PartitionRecovery.PartitionNumber)
set id=27
exit 
"@ | diskpart.exe
    }
}
function Clear-DeviceLocalDisk {
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
        $GetDisk = Get-DeviceLocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
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
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle = $PartitionStyle"
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
            Invoke-DiskpartClean -DiskNumber $Item.Number

            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }

            $ClearDisk += Get-OSDCloudDisk -Number $Item.Number
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
function Get-DeviceDataDisk {
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
function Get-DeviceLocalDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-OSDCloudDisk
    #=================================================
    $GetDisk = Get-OSDCloudDisk -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',USB,Virtual
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
function Get-DeviceLocalDiskPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDCloudPartition | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
function Get-DeviceLocalDiskVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDCloudVolume | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
function Get-OSDCloudDisk {
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
function Get-OSDCloudPartition {
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
    $GetDisk = Get-OSDCloudDisk -BusType USB
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
function Get-OSDCloudVolume {
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
    $GetPartition = Get-DeviceUSBPartition
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
function Get-DeviceUSBDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-OSDCloudDisk
    #=================================================
    $GetDisk = Get-OSDCloudDisk -BusType USB
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
function Get-DeviceUSBPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDCloudPartition | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
function Get-DeviceUSBVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDCloudVolume | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
function Invoke-SelectDeviceDataDisk {
    [CmdletBinding()]
    param (
        [int]$NotDiskNumber,
        [System.Management.Automation.SwitchParameter]$Skip,
        [System.Management.Automation.SwitchParameter]$SelectOne
    )
    #=================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=================================================
    $Results = Get-DeviceDataDisk | Sort-Object -Property DriveLetter
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
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectDeviceLocalDisk {
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
        $Results = Get-DeviceLocalDisk
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectDeviceLocalVolume {
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
        $Results = Get-DeviceLocalDiskVolume | Sort-Object -Property DriveLetter | `
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
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectOSDCloudDisk {
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
        $Results = Get-DeviceLocalDisk
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectOSDCloudVolume {
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
        $Results = Get-OSDCloudVolume | Sort-Object -Property DriveLetter | `
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
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectDeviceUSBDisk {
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
        $Results = Get-DeviceUSBDisk | Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function Invoke-SelectDeviceUSBVolume {
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
        $Results = Get-DeviceUSBVolume | Sort-Object -Property DriveLetter | `
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
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Automatically select "
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
function New-OSDCloudDisk {
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
    Default = 2000MB
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
    New-OSDCloudDisk
    Displays Get-Help New-OSDCloudDisk

    .EXAMPLE
    New-OSDCloudDisk -Force
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
        [uint64]$SizeSystemGpt = 500MB,

        [Alias('SSM','Mbr','SystemM')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 500MB,

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
        [uint64]$SizeRecovery = 2000MB,

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
        $GetDisk = Get-DeviceLocalDisk | Sort-Object Number
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
        if ($global:OSDCloudDevice.IsUEFI -eq $true) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PartitionStyle = $PartitionStyle"
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

        $OSDisk = Invoke-SelectDeviceLocalDisk -Input $GetDisk
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
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Initializing Disk $($OSDisk.Number) as $PartitionStyle"
        $OSDisk | Initialize-Disk -PartitionStyle $PartitionStyle

    }
    #Create from unpartitioned Disk
    elseif (($OSDisk.NumberOfPartitions -eq 0) -and ($OSDisk.PartitionStyle -ne $PartitionStyle)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cleaning Disk $($OSDisk.Number)"
        Invoke-DiskpartClean -DiskNumber $OSDisk.Number

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Initializing Disk $($OSDisk.Number) as $PartitionStyle"
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
            Invoke-DiskpartClean -DiskNumber $OSDisk.Number

            Write-Warning "Initializing $PartitionStyle Disk $($OSDisk.Number) $($OSDisk.BusType) $($OSDisk.SizeGB) $($OSDisk.FriendlyName) $($OSDisk.Model)"
            $OSDisk | Initialize-Disk -PartitionStyle $PartitionStyle
        }
    }
    #=================================================
    #	Reassign Volume S
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'S'}

    if ($GetVolume) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Reassigning Drive Letter S"
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
    New-OSDCloudPartitionSystem @SystemPartition
    #=================================================
    #	Reassign Volume C
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'C'}

    if ($GetVolume) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Reassigning Drive Letter C"
        Get-Partition -DriveLetter 'C' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
    }
    #=================================================
    #	Reassign Volume R
    #=================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'R'}

    if ($GetVolume) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Reassigning Drive Letter R"
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
    New-OSDCloudPartitionWindows @WindowsPartition
    #=================================================
    #	DataDisks
    #=================================================
    Get-OSDCloudDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName, Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
}
