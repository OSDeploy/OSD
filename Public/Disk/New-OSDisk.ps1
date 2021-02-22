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
    New-OSDDisk
    Displays Get-Help New-OSDDisk -Examples

    .EXAMPLE
    New-OSDDisk -Force
    Interactive.  Prompted to Confirm Clear-Disk for each Local Disk

    .LINK
    https://osd.osdeploy.com/module/osddisk/new-osddisk

    .NOTES
    19.10.10    Created by David Segura @SeguraOSD
    21.2.19     Complete redesign
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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
        [uint64]$SizeRecovery = 990MB,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [switch]$Force
    )
    #======================================================================================================
    #	PSBoundParameters
    #======================================================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #======================================================================================================
    #	Enable Verbose if Force parameter is not $true
    #======================================================================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #======================================================================================================
    #	OSD Module and Command Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	Get Local Disks (not USB and not Virtual)
    #======================================================================================================
    $GetLocalDisk = $null
    if ($InputObject) {
        $GetLocalDisk = $InputObject
    } else {
        $GetLocalDisk = Get-LocalDisk | Sort-Object Number
    }
    #======================================================================================================
    #	Get DiskNumber
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetLocalDisk = $GetLocalDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #======================================================================================================
    #	OSDisks must be large enough for a Windows installation
    #======================================================================================================
    $GetLocalDisk = $GetLocalDisk | Where-Object {$_.Size -gt 15GB}
    #======================================================================================================
    #	-PartitionStyle
    #======================================================================================================
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
    #======================================================================================================
    #	Get-Help
    #======================================================================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name) -Examples
    }
    #======================================================================================================
    #	Display Disk Information
    #======================================================================================================
    $GetLocalDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
    
    if ($IsForcePresent -eq $false) {
        Break
    }
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
    #	Failure: No Fixed Disks are present
    #======================================================================================================
    if ($null -eq $GetLocalDisk) {
        Write-Warning "No Fixed Disks were found"
        Break
    }
    #======================================================================================================
    #	Set Defaults
    #======================================================================================================
    $OSDDisk = $null
    $DataDisks = $null
    #======================================================================================================
    #	Identify OSDDisk
    #======================================================================================================
    if (($GetLocalDisk | Measure-Object).Count -eq 1) {
        $OSDDisk = $GetLocalDisk
    } else {
        Write-Host ""
        foreach ($Item in $GetLocalDisk) {
            Write-Host "[$($Item.Number)]" -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
        }
        Write-Host "[X]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
        Write-Host " Exit"

        do {
            $SelectOSDDisk = Read-Host -Prompt "Type the Disk Number to use as the OSDDisk, or X to Exit"
        }
        until (
            ((($SelectOSDDisk -ge 0) -and ($SelectOSDDisk -in $GetLocalDisk.Number)) -or ($SelectOSDDisk -eq 'X')) 
        )
        if ($SelectOSDDisk -eq 'X') {
            Write-Warning "Exit"
            Break
        }
        $OSDDisk = $GetLocalDisk | Where-Object {$_.Number -eq $SelectOSDDisk}
        $DataDisks = $GetLocalDisk | Where-Object {$_.Number -ne $OSDDisk.Number}
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
        #Get-Partition -DriveLetter 'S' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
        Get-Volume -DriveLetter S | Get-Partition | Remove-PartitionAccessPath -AccessPath 'S:\' -ErrorAction SilentlyContinue
    }
    #======================================================================================================
    #	System Partition
    #======================================================================================================
    $SystemPartition = @{
        DiskNumber          = $OSDDisk.Number
        LabelSystem         = $LabelSystem
        PartitionStyle      = $PartitionStyle
        SizeMSR             = $SizeMSR
        SizeSystemMbr       = $SizeSystemMbr
        SizeSystemGpt       = $SizeSystemGpt
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
        #Get-Partition -DriveLetter 'R' | Set-Partition -NewDriveLetter (Get-LastAvailableDriveLetter)
        Get-Volume -DriveLetter R | Get-Partition | Remove-PartitionAccessPath -AccessPath 'R:\' -ErrorAction SilentlyContinue
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
<#     if ($DataDisks) {
        Write-Host ""
        foreach ($Item in $DataDisks) {
            Write-Host "[C]"  -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
            Write-Host "[S]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            Write-Host " Skip this Disk"
            Write-Host "[X]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            Write-Host " Exit"
            Write-Host "This drive is a DATA disk and it should be cleaned"

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
    } #>
    Get-OSDDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
}