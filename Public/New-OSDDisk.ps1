<#
.SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

.DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

.LINK
https://osd.osdeploy.com/module/functions/new-osddisk

.NOTES
19.10.10     Created by David Segura @SeguraOSD
#>
function New-OSDDisk {
    [CmdletBinding()]
    param (
        #Title displayed during script execution
        #Default = New-OSDDisk
        #Alias = T
        [Alias('T')]
        [string]$Title = 'New-OSDDisk',

        #Fixed Disk Number
        #For multiple Fixed Disks, use the SelectDisk parameter
        #Default = 0
        #Alias = Disk, Number
        [Alias('Disk','Number')]
        [int]$DiskNumber = 0,

        #Clear-Disk Scope
        #All will Clear all non-RAW Fixed Disks
        #OSDDisk will Clear only the DiskNumber or SelectDisk
        #Default = All
        #Alias = Clear
        [Alias('Clear')]
        [ValidateSet('All','OSDDisk')]
        [string]$ClearDisk = 'All',

        #Drive Label of the System Partition
        #Default = System
        #Alias = LS, LabelS
        [Alias('LS','LabelS')]
        [string]$LabelSystem = 'System',
        
        #Drive Label of the Windows Partition
        #Default = OS
        #Alias = LW, LabelW
        [Alias('LW','LabelW')]
        [string]$LabelWindows = 'OS',
        
        #Drive Label of the Recovery Partition
        #Default = Recovery
        #Alias = LR, LabelR
        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        #System Partition size for BIOS MBR based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        #Alias = SSM, Mbr, SystemM
        [Alias('SSM','Mbr','SystemM')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemMbr = 260MB,

        #System Partition size for UEFI GPT based Computers
        #Default = 260MB
        #Range = 100MB - 3000MB (3GB)
        #Alias = SSG, Efi, SystemG
        [Alias('SSG','Efi','SystemG')]
        [ValidateRange(100MB,3000MB)]
        [uint64]$SizeSystemGpt = 260MB,

        #MSR Partition size
        #Default = 16MB
        #Range = 16MB - 128MB
        #Alias = MSR
        [Alias('MSR')]
        [ValidateRange(16MB,128MB)]
        [uint64]$SizeMSR = 16MB,

        #Size of the Recovery Partition
        #Default = 990MB
        #Range = 350MB - 80000MB (80GB)
        #Alias = SR, Recovery
        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB,

        #Select OSDDisk if multiple Fixed Disks are present
        #Supersedes the DiskNumber parameter
        #Ignored if only one Fixed Disk is present
        [switch]$SelectDisk,

        #Skips the creation of the Recovery Partition
        [switch]$SkipRecoveryPartition,

        #Confirm before Clear-Disk and Initialize-Disk
        [switch]$Confirm,

        #Required for execution as a safety precaution
        [switch]$Force
    )
    
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    #======================================================================================================
    #	Force Validation
    #======================================================================================================
    if (!($Force.IsPresent)) {
        Write-Warning "OSD $OSDVersion $Title is running in Sandbox.  Use the Force parameter for execution"
    }
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
    #	SelectDisk
    #======================================================================================================
    if ((($FixedDisks | Measure-Object).Count -eq 1) -and ($FixedDisks.PartitionStyle -eq 'RAW') -and ($Force.IsPresent)) {
        $OSDDisk = $FixedDisks
    } else {
        Write-Host "=================================================================================================" -ForegroundColor Cyan
        foreach ($FixedDisk in $FixedDisks) {
            Write-Host "Disk $($FixedDisk.Number)    $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions) IsBoot=$($FixedDisk.BootFromDisk)" -ForegroundColor Cyan
        }
        Write-Host "=================================================================================================" -ForegroundColor Cyan
        if ($SelectDisk -and $FixedDisks.Count -gt 1) {
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
    }
    #======================================================================================================
    #	Simulation
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
            if ($SkipRecoveryPartition.IsPresent) {
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
            if ($SkipRecoveryPartition.IsPresent) {
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
            $DirtyOSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null
        } else {
            $DirtyOSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction SilentlyContinue | Out-Null
        }
    } else {
        if ($null -ne $DirtyFixedDisks) {
            Write-Verbose "======================================================================================="
            #Write-Warning "All existing Data and Partitions will be destroyed from the following Drives"
            foreach ($DirtyFixedDisk in $DirtyFixedDisks) {
                Write-Verbose "Disk $($DirtyFixedDisk.Number)    $($DirtyFixedDisk.FriendlyName) ($([math]::Round($DirtyFixedDisk.Size / 1000000000))GB $($DirtyFixedDisk.PartitionStyle)) BusType=$($DirtyFixedDisk.BusType) Partitions=$($DirtyFixedDisk.NumberOfPartitions) IsBoot=$($DirtyFixedDisk.BootFromDisk)"
            }
            Write-Verbose "======================================================================================="
            if ($Confirm.IsPresent) {
                foreach ($DirtyFixedDisk in $DirtyFixedDisks) {$DirtyFixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null}
            } else {
                foreach ($DirtyFixedDisk in $DirtyFixedDisks) {$DirtyFixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction SilentlyContinue | Out-Null}
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
            $ConfirmInit = Read-Host "Press P to Partition this OSDDisk, or X to quit (and press Enter)"
        } until ($ConfirmInit -eq 'P' -or $ConfirmInit -eq 'X')
        if ($ConfirmInit -eq 'X') {Break}
    }
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    Initialize-OSDDisk -DiskNumber $($OSDDisk.Number)
    #======================================================================================================
    #	New-OSDPartitionSystem
    #======================================================================================================
    New-OSDPartitionSystem -DiskNumber $($OSDDisk.Number) -SizeSystemMbr $SizeSystemMbr -SizeSystemGpt $SizeSystemGpt -LabelSystem $LabelSystem -SizeMSR $SizeMSR
    
    if ($SkipRecoveryPartition.IsPresent) {
        New-OSDPartitionWindows -DiskNumber $($OSDDisk.Number) -LabelWindows $LabelWindows -SkipRecoveryPartition
    } else {
        New-OSDPartitionWindows -DiskNumber $($OSDDisk.Number) -LabelWindows $LabelWindows -LabelRecovery $LabelRecovery -SizeRecovery $SizeRecovery
    }
}