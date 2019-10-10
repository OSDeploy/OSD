<#
.SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives

.DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives

.LINK
https://osd.osdeploy.com/module/functions/new-osddisk

.NOTES
19.10.9     Created by David Segura @SeguraOSD
#>
function New-OSDDisk {
    [CmdletBinding()]
    param (
        #Number of the Disk to prepare
        #Use Verbose to select a Disk
        #Default = 0
        #Alias = Disk Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Prevents the cleaning of additional Disks
        #Confirm overrides this 
        #Alias = Clear
        [Alias('Clear')]
        [ValidateSet('All','OSDDisk')]
        [string]$ClearDisk = 'All',

        #Title displayed during script execution
        #Default = New-OSDDiskWinPE
        #Alias = T
        [Alias('T')]
        [string]$Title = 'New-OSDDisk',

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS
        [Alias('LS')]
        [string]$LabelSystem = 'System',

        #Size of the System Partition for BIOS based Computers
        #Default = 999MB
        #Range = 100MB - 1999MB
        #Alias = SzSM Mbr SystemBios
        [Alias('SzSM','Mbr','SystemMbr')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #Size of the System Partition for UEFI based Computers
        #Default = 260MB
        #Range = 100MB - 1999MB
        #Alias = SzSG Efi SystemGpt
        [Alias('SzSG','Efi','SystemGpt')]
        [ValidateRange(100MB,1999MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #Size of the MSR Partition
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = MSR
        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LW
        [Alias('LW')]
        [string]$LabelWindows = 'OS',

        #Skips the creation of the Recovery Partition
        #Alias = NoR
        [Alias('NoR')]
        [switch]$NoRecovery,
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR
        [Alias('LR')]
        [string]$LabelRecovery = 'Recovery',

        #Size of the Recovery Partition
        #Default = 984MB
        #Range = 499MB - 40000MB
        #Alias = SR Recovery Tools
        [Alias('SR','Recovery','Tools')]
        [ValidateRange(499MB,40000MB)]
        [uint64]$SizeRecovery = 984MB,

        #Allows the selection of the OSDDisk if multiple Fixed Disks are present
        #Supersedes the DiskNumber parameter
        [switch]$MultiSelect,

        #Confirm before Clear-Disk and Initialize-Disk
        [switch]$Confirm,

        #This is a very destructive Function
        #Use the Force parameter for full automation
        [switch]$Force
    )
    #======================================================================================================
    #	Get-Disk
    #======================================================================================================
    $FixedDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual') -and ($_.Size -gt 15GB)} | Sort-Object Number
    $DirtyFixedDisks = $FixedDisks | Where-Object {$_.PartitionStyle -ne 'RAW'}
    $DirtyOSDDisk = $FixedDisks | Where-Object {($_.DiskNumber -eq $DiskNumber) -and ($_.PartitionStyle -ne 'RAW')}
    #======================================================================================================
    #	No Fixed Disks
    #======================================================================================================
    if ($null -eq $FixedDisks) {
        Write-Warning "$Title could not find any Fixed Disks"
        Break
    }
    #======================================================================================================
    #	MultiSelect
    #======================================================================================================
    Write-Host "=================================================================================================" -ForegroundColor Cyan
    foreach ($FixedDisk in $FixedDisks) {
        Write-Host "Disk $($FixedDisk.Number)    $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions) BootDisk=$($FixedDisk.BootFromDisk)" -ForegroundColor Cyan
    }
    Write-Host "=================================================================================================" -ForegroundColor Cyan

    if ($MultiSelect -and $FixedDisks.Count -gt 1) {
        #======================================================================================================
        #	Wizard Select Disk
        #======================================================================================================
        do {
            $Selected = Read-Host "Type the Number of the Disk to Partition or press X to quit (and press Enter)"
        } until (($FixedDisks.Number -Contains $Selected) -or $Selected -eq 'X')
        if ($Selected -eq 'X') {Break}
        $OSDDisk = $FixedDisks | Where-Object {$_.Number -eq $Selected}
    } else {
        $OSDDisk = $FixedDisks | Where-Object {$_.Number -eq $DiskNumber}
    }  
    #======================================================================================================
    #	Simulate
    #======================================================================================================
    if (!($Force.IsPresent)) {
        $VerbosePreference = 'Continue'
        if (Get-OSDGather -Property IsWinPE) {
            Write-Verbose "Session is in WinPE"
        } else {
            Write-Warning "Session is not in WinPE"
        }
        if (Get-OSDGather -Property IsAdmin) {
            Write-Verbose "Session has Administrative Rights"
        } else {
            Write-Warning "Session does not have Administrative Rights"
        }
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "Disk will be Initialized as GPT (UEFI)"
        } else {
            Write-Warning "Disk will be Initialized as MBR (BIOS)"
        }
        if ($ClearDisk -eq 'All') {
            foreach ($FixedDisk in $FixedDisks) {
                if ($FixedDisk.PartitionStyle -ne 'RAW') {
                    Write-Warning "Clear Disk $($FixedDisk.Number) $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions)"
                }
            }
        }
<#         if ($ClearDisk -eq 'Confirm') {
            foreach ($FixedDisk in $FixedDisks) {
                if ($FixedDisk.PartitionStyle -ne 'RAW') {
                    Write-Warning "Confirm Clear Disk $($FixedDisk.Number) $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions)"
                }
            }
        } #>
        if ($ClearDisk -eq 'OSDDisk') {
            if ($null -ne $OSDDisk -and $OSDDisk.PartitionStyle -ne 'RAW') {
                Write-Warning "Clear Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB $($OSDDisk.PartitionStyle)) BusType=$($OSDDisk.BusType) Partitions=$($OSDDisk.NumberOfPartitions)"
            }
        }
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
            Write-Verbose "Initialize Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB) $PartitionStyle"
            Write-Verbose "Disk $($OSDDisk.Number) System Partition $($SizeSystemGpt / 1MB)MB FAT32 $LabelSystem"
            Write-Verbose "Disk $($OSDDisk.Number) MSR Partition $($SizeMSR / 1MB)MB"
            if ($NoRecovery.IsPresent) {
                $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR
                $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
                Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows"
            } else {
                $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR - $SizeRecovery
                $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
                Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows"
                Write-Verbose "Disk $($OSDDisk.Number) Recovery Partition $($SizeRecovery / 1MB)MB NTFS $LabelRecovery"
            }
        }
        else {
            $PartitionStyle = 'MBR'
            Write-Verbose "Initialize Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB) $PartitionStyle"
            Write-Verbose "Disk $($OSDDisk.Number) System Partition $($SizeSystemMbr / 1MB)MB FAT32 $LabelSystem"
            if ($NoRecovery.IsPresent) {
                $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr - $SizeMSR
                $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
                Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows"
            } else {
                $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr - $SizeRecovery
                $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
                Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows"
                Write-Verbose "Disk $($OSDDisk.Number) Recovery Partition $($SizeRecovery / 1MB)MB NTFS $LabelRecovery"
            }
        }
        Write-Host
        Write-Verbose "Force parameter is required to bypass $Title validation"
        Break
    }
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (!(Get-OSDGather -Property IsWinPE)) {Write-Warning "$Title requires WinPE.  Exiting";Break}
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (!(Get-OSDGather -Property IsAdmin)) {Write-Warning "$Title requires Admin Rights.  Exiting";Break}
    #======================================================================================================
    #	Clear-Disk
    #======================================================================================================
    if ($ClearDisk -eq 'OSDDisk') {
        if ($Confirm.IsPresent) {
            $DirtyOSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction Stop
        } else {
            $DirtyOSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction Stop
        }
    } else {
        if ($null -ne $DirtyFixedDisks) {
            Write-Verbose "Fixed Disks should be cleared before $Title can partition"
            Write-Verbose "All existing Data and Partitions will be destroyed from the following Drives"
            Write-Verbose "======================================================================================="
            foreach ($DirtyFixedDisk in $DirtyFixedDisks) {
                Write-Verbose "Disk $($DirtyFixedDisk.Number)    $($DirtyFixedDisk.FriendlyName) ($([math]::Round($DirtyFixedDisk.Size / 1000000000))GB $($DirtyFixedDisk.PartitionStyle)) BusType=$($DirtyFixedDisk.BusType) Partitions=$($DirtyFixedDisk.NumberOfPartitions) BootDisk=$($DirtyFixedDisk.BootFromDisk)"
            }
            Write-Verbose "======================================================================================="
            if ($Confirm.IsPresent) {
                foreach ($DirtyFixedDisk in $DirtyFixedDisks) {$DirtyFixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction Stop}
            } else {
                foreach ($DirtyFixedDisk in $DirtyFixedDisks) {$DirtyFixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction Stop}
            }
        }
    }
    #======================================================================================================
    #	Get OSDDisks
    #======================================================================================================
    $OSDDisk = Get-Disk -Number $OSDDisk.Number
    #======================================================================================================
    #	RAW
    #======================================================================================================
    if ($OSDDisk.PartitionStyle -ne 'RAW') {
        Write-Warning "OSDDisk does not have RAW PartitionStyle.  $Title cannot create additional Partitions.  Exiting"
        Break
    }
    #======================================================================================================
    #	Display OSDDisk
    #======================================================================================================
    Write-Host "=================================================================================================" -ForegroundColor Cyan
    Write-Host "OSDDisk: Disk $($OSDDisk.Number)    $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB $($OSDDisk.PartitionStyle)) BusType=$($OSDDisk.BusType)" -ForegroundColor Cyan
    Write-Host "=================================================================================================" -ForegroundColor Cyan
    if ($Confirm.IsPresent) {
        do {
            $ConfirmInit = Read-Host "Press C to continue or X to quit (and press Enter)"
        } until ($ConfirmInit -eq 'C' -or $ConfirmInit -eq 'X')
        if ($ConfirmInit -eq 'X') {Break}
    }
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    Initialize-OSDDisk -Number $($OSDDisk.Number)
    #======================================================================================================
    #	New-OSDPartitionSystem
    #======================================================================================================
    New-OSDPartitionSystem -Number $($OSDDisk.Number) -SizeSystemMbr $SizeSystemMbr -SizeSystemGpt $SizeSystemGpt -LabelSystem $LabelSystem -SizeMSR $SizeMSR
    
    if ($NoRecovery.IsPresent) {
        New-OSDPartitionWindows -Number $($OSDDisk.Number) -LabelWindows $LabelWindows -NoRecovery
    } else {
        New-OSDPartitionWindows -Number $($OSDDisk.Number) -LabelWindows $LabelWindows -LabelRecovery $LabelRecovery -SizeRecovery $SizeRecovery
    }
}