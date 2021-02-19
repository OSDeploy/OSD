<#
.SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

.DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

.PARAMETER DiskNumber
Specifies the disk number for which to get the associated Disk object
Alias = Disk, Number

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
Partition Style of the new partitions
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

.LINK
https://osd.osdeploy.com/module/osddisk/new-osddisk

.NOTES
19.10.10    Created by David Segura @SeguraOSD
21.2.19     Complete redesign
#>
function New-OSDDisk {
    [CmdletBinding()]
    param (
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
        [switch]$NoRecoveryPartition,

        [Alias('LR','LabelR')]
        [string]$LabelRecovery = 'Recovery',

        [Alias('SR','Recovery')]
        [ValidateRange(350MB,80000MB)]
        [uint64]$SizeRecovery = 990MB
    )
    
    #======================================================================================================
    #	OSD Module Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (-NOT (Get-OSDGather -Property IsWinPE)) {
        Write-Warning "WinPE is required for execution"
        Break
    }
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (-NOT (Get-OSDGather -Property IsAdmin)) {
        Write-Warning "Administrative Rights are required for execution"
        Break
    }
    #======================================================================================================
    #	Set Defaults
    #======================================================================================================
    $OSDDisk = $null
    $DataDisks = $null
    #======================================================================================================
    #	PartitionStyle
    #======================================================================================================
    if (-NOT ($PartitionStyle)) {
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle is set to $PartitionStyle"
    #======================================================================================================
    #	Get-OSDDisk
    #======================================================================================================
    if ($DiskNumber) {
        $GetOSDDisk = Get-OSDDisk -Number $DiskNumber
    } else {
        $GetOSDDisk = Get-OSDDisk -BusTypeNot USB,Virtual | `
        Where-Object {($_.Size -gt 15GB)} | `
        Sort-Object Number
    }
    #======================================================================================================
    #	Failure: No Fixed Disks are present
    #======================================================================================================
    if ($null -eq $GetOSDDisk) {
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #======================================================================================================
    #	Identify OSDDisk
    #======================================================================================================
    Write-Host ""
    if (($GetOSDDisk | Measure-Object).Count -eq 1) {
        $OSDDisk = $GetOSDDisk
    } else {
        foreach ($Item in $GetOSDDisk) {
            Write-Host "[$($Item.Number)]" -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
        }
        Write-Host "[X]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
        Write-Host " Exit"

        do {
            $SelectOSDDisk = Read-Host -Prompt "Type the Disk Number to use as the OSDDisk, or X to Exit"
        }
        until (
            ((($SelectOSDDisk -ge 0) -and ($SelectOSDDisk -in $GetOSDDisk.Number)) -or ($SelectOSDDisk -eq 'X')) 
        )
        if ($SelectOSDDisk -eq 'X') {
            Write-Warning "Exit"
            Break
        }
        $OSDDisk = $GetOSDDisk | Where-Object {$_.Number -eq $SelectOSDDisk}
        $DataDisks = $GetOSDDisk | Where-Object {$_.Number -ne $OSDDisk.Number}
    }
    Write-Host ""
    #======================================================================================================
    #	Make sure there is only one OSDDisk
    #======================================================================================================
    if (($OSDDisk | Measure-Object).Count -gt 1) {
        Write-Warning "Something went wrong"
        Break
    }
    #======================================================================================================
    #   Create OSDDisk
    #======================================================================================================
    #Create from RAW Disk
    if (($OSDDisk.NumberOfPartitions -eq 0) -and ($OSDDisk.PartitionStyle -eq 'RAW')) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Initializing Disk $($OSDDisk.Number) as $PartitionStyle"
        $OSDDisk | Initialize-Disk -PartitionStyle $PartitionStyle

    }
    #Create from unpartitioned Disk
    elseif (($OSDDisk.NumberOfPartitions -eq 0) -and ($OSDDisk.PartitionStyle -ne $PartitionStyle)) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Cleaning Disk $($OSDDisk.Number)"
        Diskpart-Clean -DiskNumber $OSDDisk.Number

        Write-Host -ForegroundColor Green -BackgroundColor Black "Initializing Disk $($OSDDisk.Number) as $PartitionStyle"
        $OSDDisk | Initialize-Disk -PartitionStyle $PartitionStyle
    }
    #Prompt for confirmation to clear the existing disk
    else {
        Write-Host "[C]"  -ForegroundColor Green -BackgroundColor Black -NoNewline
        Write-Host " Disk $($OSDDisk.Number) $($OSDDisk.BusType) $($OSDDisk.MediaType) $($OSDDisk.FriendlyName) [$($OSDDisk.NumberOfPartitions) $($OSDDisk.PartitionStyle) Partitions]"
        Write-Host "[X]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
        Write-Host " Exit"

        do {$ConfirmClearDisk = Read-Host "Press C to create OSDDisk from the specified Disk, or X to Exit"}
        until (($ConfirmClearDisk -eq 'C') -or ($ConfirmClearDisk -eq 'X'))

        #Clear and Initialize Disk
        if ($ConfirmClearDisk -eq 'C') {
            Write-Host -ForegroundColor Green -BackgroundColor Black "Cleaning Disk $($OSDDisk.Number)"
            Diskpart-Clean -DiskNumber $OSDDisk.Number
            Write-Host -ForegroundColor Green -BackgroundColor Black "Initializing Disk $($OSDDisk.Number) as $PartitionStyle"
            $OSDDisk | Initialize-Disk -PartitionStyle $PartitionStyle
        }

        #Exit
        if ($ConfirmClearDisk -eq 'X') {
            Write-Warning "Exit"
            Break
        }
    }
    #======================================================================================================
    #	Reassign Volume S
    #======================================================================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'S'}

    if ($GetVolume) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Reassigning Drive Letter S"
        Get-Partition -DriveLetter 'S' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
    }
    #======================================================================================================
    #	System Partition
    #======================================================================================================
    $SystemPartition = @{
        DiskNumber          = $OSDDisk.Number
        Label               = $LabelSystem
        PartitionStyle      = $PartitionStyle
        SizeSystemMbr       = $SizeSystemMbr
        SizeSystemGpt       = $SizeSystemGpt
        SizeMSR             = $SizeMSR
    }
    New-OSDPartitionSystem @SystemPartition
    #======================================================================================================
    #	Reassign Volume C
    #======================================================================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'C'}

    if ($GetVolume) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Reassigning Drive Letter C"
        Get-Partition -DriveLetter 'C' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
    }
    #======================================================================================================
    #	Reassign Volume R
    #======================================================================================================
    $GetVolume = Get-Volume | Where-Object {$_.DriveLetter -eq 'R'}

    if ($GetVolume) {
        Write-Host -ForegroundColor Green -BackgroundColor Black "Reassigning Drive Letter R"
        Get-Partition -DriveLetter 'R' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
    }
    #======================================================================================================
    #	Windows Partition
    #======================================================================================================
    $WindowsPartition = @{
        DiskNumber              = $OSDDisk.Number
        LabelRecovery           = $LabelRecovery
        LabelWindows            = $LabelWindows
        PartitionStyle          = $PartitionStyle
        SizeRecovery            = $SizeRecovery
        NoRecoveryPartition   = $NoRecoveryPartition
    }
    New-OSDPartitionWindows @WindowsPartition
    #======================================================================================================
    #	DataDisks
    #======================================================================================================
    if ($DataDisks) {
        Write-Host ""
<#         foreach ($Item in $DataDisks) {
            Write-Host "[$($Item.Number)]" -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
        }
        Write-Host "" #>

        foreach ($Item in $DataDisks) {
            Write-Host "[C]"  -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
            Write-Host "[S]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            Write-Host " Skip this Disk"
            Write-Host "[X]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            Write-Host " Exit"
            Write-Host "This drive is a DATA disk and it should be cleaned and initialized"

            do {$ConfirmClearDisk = Read-Host "Press C to CLEAR this Disk, S to Skip, or X to Exit"}
            until (($ConfirmClearDisk -eq 'C') -or ($ConfirmClearDisk -eq 'S') -or ($ConfirmClearDisk -eq 'X'))
            if ($ConfirmClearDisk -eq 'C') {
                Write-Host -ForegroundColor Green -BackgroundColor Black "Cleaning Disk $($Item.Number)"
                Diskpart-Clean -DiskNumber $Item.Number

                Write-Host -ForegroundColor Green -BackgroundColor Black "Initializing Disk $($Item.Number) as $PartitionStyle"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            if ($ConfirmClearDisk -eq 'S') {
                Write-Warning "Skip DiskNumber $($Item.Number) "
            }
            if ($ConfirmClearDisk -eq 'X') {
                Write-Warning "Exit"
                Break
            }
            Write-Host ""
        }
    }
}