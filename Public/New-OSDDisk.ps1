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

        #This is a very destructive Function
        #Use the Force parameter for full automation
        [switch]$Force,

        [switch]$Execute
    )
    #======================================================================================================
    #	Get-Disk
    #======================================================================================================
    $FixedDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual')} | Sort-Object Number
    $RawDisks = $FixedDisks | Where-Object {$_.PartitionStyle -eq 'RAW'} | Sort-Object Number
    $ClearDisks = $FixedDisks | Where-Object {$_.PartitionStyle -ne 'RAW'} | Sort-Object Number
    $OSDDisk = $FixedDisks | Where-Object {$_.DiskNumber -eq $DiskNumber}
    #======================================================================================================
    #	Simulate
    #======================================================================================================
    if (!($Execute.IsPresent)) {
        $VerbosePreference = 'Continue'
        if (Get-OSDGather -Property IsAdmin) {
            Write-Verbose "Session has Administrative Rights"
        } else {
            Write-Warning "Session does not have Administrative Rights"
        }
        if (Get-OSDGather -Property IsWinPE) {
            Write-Verbose "Session is in WinPE"
        } else {
            Write-Warning "Session is not in WinPE"
        }
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "Disk will be Initialized as GPT (UEFI)"
        } else {
            Write-Warning "Disk will be Initialized as MBR (BIOS)"
        }
        foreach ($FixedDisk in $FixedDisks) {
            <# if ($FixedDisk.PartitionStyle -eq 'RAW') {
                Write-Verbose "$($FixedDisk.Number) $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions)"
            } #>
            if ($FixedDisk.PartitionStyle -ne 'RAW') {
                Write-Warning "Clear Disk $($FixedDisk.Number) $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions)"
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
        Write-Verbose "Use the Execute parameter to bypass $Title validation"
        
        Break
    }













    $RawDisks = Get-Disk | Where-Object {(($_.BusType -ne 'USB') -and ($_.Size -gt 10GB))} | Sort-Object Number





    Break


    Write-Verbose 

    $FixedDisks = Get-Disk | Where-Object {(($_.BusType -ne 'USB') -and ($_.Size -gt 10GB))} | Sort-Object Number












    if ($Execute.IsPresent) {Write-Host "Execute"}
    else {Write-Host "Do Nothing"}

    Break
    #======================================================================================================
    #	Force
    #======================================================================================================
    if (!$Force.IsPresent) {
        $VerbosePreference -eq 'Continue'
        #Write-Warning "$Title : This is a very destructive function"
        #Write-Warning "$Title : Use the -Confirm parameter to step through $Title"
        #Write-Warning "$Title : Use the -Force parameter to ignore this warning and continue with $Title"
        #Break
    }
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (!(Get-OSDGather -Property IsWinPE)) {Write-Warning "$Title : This function requires WinPE.  Exiting";Break}
    #======================================================================================================
    #	Get All Fixed Disks
    #======================================================================================================
    if (($NoCleanAll.IsPresent) -or ($VerbosePreference -eq 'Continue')) {
        $FixedDisks = Get-Disk | Where-Object {(($_.BusType -ne 'USB') -and ($_.Size -gt 10GB))} | Sort-Object Number
    } else {
        $FixedDisks = Get-Disk -Number $DiskNumber
    }
    #======================================================================================================
    #	No Fixed Disks
    #======================================================================================================
    if ($null -eq $FixedDisks) {
        Write-Warning "$Title : Could not find a Hard Drive to prepare"
        Break
    }
    #======================================================================================================
    #	Clear-Disk
    #======================================================================================================
    Write-Verbose "All Fixed Disks must be cleared before Windows can be installed"
    Write-Verbose "All existing Data and Partitions will be destroyed from the following Drives"
    Write-Verbose "======================================================================================="
    foreach ($FixedDisk in $FixedDisks) {
        Write-Verbose "Disk $($FixedDisk.Number)    $($FixedDisk.FriendlyName) ($([math]::Round($FixedDisk.Size / 1000000000))GB $($FixedDisk.PartitionStyle)) BusType=$($FixedDisk.BusType) Partitions=$($FixedDisk.NumberOfPartitions) BootDisk=$($FixedDisk.BootFromDisk)"
    }
    Write-Verbose "======================================================================================="
    if ($VerbosePreference -eq 'Continue') {
        [void](Read-Host "Press Enter to Continue with $Title")
        foreach ($FixedDisk in $FixedDisks) {$FixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null}
    } else {
        foreach ($FixedDisk in $FixedDisks) {$FixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction SilentlyContinue | Out-Null}
    }
    #======================================================================================================
    #	Get OSDDisks
    #======================================================================================================
    if ($VerbosePreference -eq 'Continue') {
        $OSDDisks = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.Size -gt 10GB) -and ($_.PartitionStyle -eq 'RAW')} | Sort-Object Number
    } else {
        $OSDDisks = Get-Disk -Number $DiskNumber
    }
    Write-Verbose "======================================================================================="
    foreach ($OSDDisk in $OSDDisks) {
        Write-Verbose "Disk $($OSDDisk.Number)    $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB $($OSDDisk.PartitionStyle)) BusType=$($OSDDisk.BusType) Partitions=$($OSDDisk.NumberOfPartitions) BootDisk=$($OSDDisk.BootFromDisk)"
    }
    Write-Verbose "To quit this script without Partitioning, type X (and press Enter)"
    Write-Verbose "======================================================================================="
    #======================================================================================================
    #	Wizard Select Partition
    #======================================================================================================
    do {
        $Selected = Read-Host "Type the Number of the Disk to Partition for Windows (and press Enter)"
    } until (($OSDDisks.Number -Contains $Selected) -or $Selected -eq 'X')
    if ($Selected -eq 'X') {Break}
    $OSDDisk = $OSDDisks | Where-Object {$_.Number -eq $Selected}
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    Initialize-OSDDisk -Number $($OSDDisk.Number)
    #======================================================================================================
    #	New-OSDPartitionSystem
    #======================================================================================================
    New-OSDPartitionSystem -Number $($OSDDisk.Number) -SizeSystemMbr $SizeSystemMbr -SizeSystemGpt $SizeSystemGpt -LabelSystem $LabelSystem -SizeMSR $SizeMSR -Verbose
    
    if ($NoRecovery.IsPresent) {
        New-OSDPartitionWindows -Number $($OSDDisk.Number) -LabelWindows $LabelWindows -NoRecovery -Verbose
    } else {
        New-OSDPartitionWindows -Number $($OSDDisk.Number) -LabelWindows $LabelWindows -LabelRecovery $LabelRecovery -SizeRecovery $SizeRecovery -Verbose
    }
}