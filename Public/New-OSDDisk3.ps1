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
        [int]$DiskNumber,

        #Clear-Disk Scope
        #All will Clear all non-RAW Fixed Disks
        #OSDDisk will Clear only the DiskNumber or SelectDisk
        #Default = All
        #Alias = Clear
        #[Alias('Clear')]
        #[ValidateSet('All','OSDDisk')]
        #[string]$ClearDisk = 'All',

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
        #[switch]$SelectDisk,

        #Skips the creation of the Recovery Partition
        [Alias('SkipRecovery')]
        [switch]$SkipRecoveryPartition,

        #Required for execution as a safety precaution
        [switch]$Force
    )
    
    #======================================================================================================
    #	Set Defaults
    #======================================================================================================
    $global:OSDDisk = $null
    $GetDisksFixed = $null
    $GetDisksDirty = $null
    $OSDDiskSingle = $false
    $OSDDiskMulti = $true
    $OSDDiskRaw = $false
    $OSDDiskAuto = $false


    $global:MultipleDisks = $false
    $global:OSDDiskSandbox = $false
    $global:SelectOSDDisk = $false
    $OSDDiskSkipDisplay = $false
    #======================================================================================================
    #	OSD Module Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Host "OSD $OSDVersion $Title" -ForegroundColor Cyan
    #======================================================================================================
    #	Get all Fixed Disks
    #======================================================================================================
    $GetDisksFixed = Get-Disk | Where-Object {($_.BusType -ne 'USB') -and ($_.BusType -notmatch 'Virtual') -and ($_.Size -gt 15GB)} | Sort-Object Number
    #======================================================================================================
    #	Get all Fixed Disks that are Dirty
    #======================================================================================================
    $GetDisksDirty = $GetDisksFixed | Where-Object {$_.PartitionStyle -ne 'RAW'}
    #======================================================================================================
    #	Failure: No Fixed Disks are present
    #======================================================================================================
    if ($null -eq $GetDisksFixed) {Write-Warning "$Title could not find any Fixed Disks"; Break}
    #======================================================================================================
    #	Single Disk
    #======================================================================================================
    if (($GetDisksFixed | Measure-Object).Count -eq 1) {
        $OSDDisk = $GetDisksFixed
        $OSDDiskSingle = $true
        $OSDDiskMulti = $false
        if ($OSDDisk.PartitionStyle -eq 'RAW') {
            $OSDDiskRaw = $true
            $OSDDiskAuto = $true
        }
    } else {
        $OSDDiskSingle = $false
        $OSDDiskMulti = $true
    }

    if ($DiskNumber -and ($GetDisksFixed | Where-Object {$_.DiskNumber -eq $DiskNumber})) {
        $OSDDisk = $GetDisksFixed | Where-Object {$_.DiskNumber -eq $DiskNumber}
        if ($OSDDisk.PartitionStyle -eq 'RAW') {
            $OSDDiskRaw = $true
            $OSDDiskAuto = $true
        }
    }
    #======================================================================================================
    #	Sandbox
    #======================================================================================================
    if (! $Force.IsPresent) {
        if (($OSDDiskSingle -eq $true) -and ($OSDDiskRaw -eq $false)) {
            $global:OSDDiskSandbox = $true
            Write-Warning "$Title is running Sandbox Mode due to existing Partitions or Data"
            Write-Warning "Use the -Force parameter to bypass Sandbox Mode"
        } elseif ($OSDDiskSingle -eq $false) {
            $global:OSDDiskSandbox = $true
            Write-Warning "$Title is running Sandbox Mode due to multiple Fixed Disks"
            Write-Warning "Use the -Force parameter to bypass Sandbox Mode"
        } else {
            $global:OSDDiskSandbox = $true
            Write-Warning "$Title is running Sandbox Mode"
            Write-Warning "Use the -Force parameter to bypass Sandbox Mode"
        }
    }











    if (($GetDisksFixed | Measure-Object).Count -eq 1) {
        $OSDDisk = $GetDisksFixed
        if ($OSDDisk.PartitionStyle -ne 'RAW') {
            if (! $Force.IsPresent) {
                $global:OSDDiskSandbox = $true
                Write-Warning "$Title is running in Sandbox Mode due to existing Partitions or Data"
                Write-Warning "Use the -Force parameter to bypass Sandbox Mode"
            }
        }
        if ($OSDDisk.PartitionStyle -eq 'RAW') {$OSDDiskSkipDisplay = $true}
    }






    if (($GetDisksFixed | Measure-Object).Count -gt 1) {
        if (! $Force.IsPresent) {
            $global:OSDDiskSandbox = $true
            Write-Warning "$Title is running in Sandbox Mode due to multiple Fixed Disks"
            Write-Warning "Use the -Force parameter to bypass Sandbox Mode"
        }
        if ($DiskNumber) {
            #OSDDisk was specified
            $OSDDisk = $GetDisksFixed | Where-Object {$_.DiskNumber -eq $DiskNumber}
        } else {
            #More than one Fixed Disk
            $global:SelectOSDDisk = $true
        }
    }
    #======================================================================================================
    #	Multiple Fixed Disks
    #======================================================================================================
    if (($GetDisksFixed | Measure-Object).Count -gt 1) {$global:MultipleDisks = $true}
    #======================================================================================================
    #	Force Validation
    #======================================================================================================
    if ($Force.IsPresent) {$global:OSDDiskSandbox = $false}
    #======================================================================================================
    #	Enable Sandbox
    #======================================================================================================
    #if ($global:OSDDiskSandbox -eq $true) {Write-Verbose "$Title is running in Sandbox.  Use the Force parameter for execution" -Verbose}
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (Get-OSDGather -Property IsWinPE) {Write-Host "$Title is running in WinPE" -ForegroundColor DarkGray}
    else {
        Write-Warning "$Title requires WinPE"
        if ($global:OSDDiskSandbox -eq $false) {Break}
    }
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (Get-OSDGather -Property IsAdmin) {Write-Host "$Title is running with Administrative Rights" -ForegroundColor DarkGray}
    else {
        Write-Warning "$Title requires Administrative Rights"
        if ($global:OSDDiskSandbox -eq $false) {Break}
    }








    #======================================================================================================
    #	DisplayGetDisksFixed
    #======================================================================================================
    if ($OSDDiskSkipDisplay -eq $false) {
        Write-Host "============================================================================================" -ForegroundColor Cyan
        foreach ($item in $GetDisksFixed) {Write-Host "Disk $($item.Number) - $($item.FriendlyName) ($([math]::Round($item.Size / 1000000000))GB $($item.PartitionStyle)) BusType=$($item.BusType) Partitions=$($item.NumberOfPartitions) IsBoot=$($item.BootFromDisk)" -ForegroundColor Cyan}
        Write-Host "============================================================================================" -ForegroundColor Cyan
    }
    #======================================================================================================
    #	SelectOSDDisk
    #======================================================================================================
    if ($global:SelectOSDDisk -eq $true) {
        do {$ConfirmOSDDisk = Read-Host "Multiple Disks: Type the DiskNumber to use as the OSDDisk, or press X to EXIT (and press Enter)"}
        until (($GetDisksFixed.Number -Contains $ConfirmOSDDisk) -or $ConfirmOSDDisk -eq 'X')
        if ($Selected -eq 'X') {Break}
        $OSDDisk = $GetDisksFixed | Where-Object {$_.Number -eq $ConfirmOSDDisk}
    }
    #======================================================================================================
    #	No GetOSDDisk
    #======================================================================================================
    if ($null -eq $OSDDisk) {Write-Warning "$Title is unable to find a suitable Disk"; Break}
    #======================================================================================================
    #	Clear GetOSDDisk
    #======================================================================================================
    if ($OSDDisk.PartitionStyle -ne 'RAW') {
        #Write-Host "Clear Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB $($OSDDisk.PartitionStyle)) BusType=$($OSDDisk.BusType) Partitions=$($OSDDisk.NumberOfPartitions)" -ForegroundColor Yellow
        
        if ($global:OSDDiskSandbox -eq $true) {
            Write-Host "SANDBOX: DISKPART select disk $($OSDDisk.Number)" -ForegroundColor DarkGray
            Write-Host "SANDBOX: DISKPART clean" -ForegroundColor DarkGray
        }

        if ($global:OSDDiskSandbox -eq $false) {
            do {$ConfirmInit = Read-Host "Press C to CLEAR this Disk, or X to EXIT (and press Enter)"}
            until ($ConfirmInit -eq 'C' -or $ConfirmInit -eq 'X')
            if ($ConfirmInit -eq 'X') {Break}
            #Virtual Machines have issues using PowerShell for Clear-Disk
            #$OSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null
            Write-Warning "DISKPART select disk $($OSDDisk.Number)"
            Write-Warning "DISKPART clean"
            
$null = @"
select disk $($OSDDisk.Number)
clean
exit 
"@ | diskpart.exe
        }
    }

    #======================================================================================================
    #	Clear additional Dirty Disks
    #======================================================================================================
    $GetDisksDirty = $GetDisksDirty | Where-Object {$_.Number -ne $OSDDisk.Number}

    foreach ($item in $GetDisksDirty) {
        Write-Host "Secondary Disk: Clear Disk $($item.Number) $($item.FriendlyName) ($([math]::Round($item.Size / 1000000000))GB $($item.PartitionStyle)) BusType=$($item.BusType) Partitions=$($item.NumberOfPartitions)" -ForegroundColor Yellow

        if ($global:OSDDiskSandbox -eq $false) {
            $null = $ConfirmClearDisk
            do {$ConfirmClearDisk = Read-Host "Press C to CLEAR this disk, or S to SKIP (and press Enter)"}
            until ($ConfirmClearDisk -eq 'C' -or $ConfirmClearDisk -eq 'S')

            #$DirtyFixedDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$false -PassThru -ErrorAction SilentlyContinue | Out-Null

$null = @"
select disk $($item.Number)
clean
exit 
"@ | diskpart.exe
        }
    }




<#     #======================================================================================================
    #	Simulation
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        Write-Verbose "Disk $($OSDDisk.Number) will be Initialized as GPT (UEFI)" -Verbose
        $PartitionStyle = 'GPT'
        Write-Verbose "Initialize Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB) $PartitionStyle" -Verbose
        Write-Verbose "Disk $($OSDDisk.Number) System Partition $($SizeSystemGpt / 1MB)MB FAT32 $LabelSystem" -Verbose
        Write-Verbose "Disk $($OSDDisk.Number) MSR Partition $($SizeMSR / 1MB)MB" -Verbose
        if ($SkipRecoveryPartition.IsPresent) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
            Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows" -Verbose
        } else {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemGpt - $SizeMSR - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
            Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows" -Verbose
            Write-Verbose "Disk $($OSDDisk.Number) Recovery Partition $($SizeRecovery / 1MB)MB NTFS $LabelRecovery" -Verbose
        }
    } else {
        Write-Verbose "Disk will be Initialized as MBR (BIOS)" -Verbose
        $PartitionStyle = 'MBR'
        Write-Verbose "Initialize Disk $($OSDDisk.Number) $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB) $PartitionStyle" -Verbose
        Write-Verbose "Disk $($OSDDisk.Number) System Partition $($SizeSystemMbr / 1MB)MB FAT32 $LabelSystem" -Verbose
        if ($SkipRecoveryPartition.IsPresent) {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr - $SizeMSR
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
            Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows" -Verbose
        } else {
            $SizeWindows = $($OSDDisk.Size) - $SizeSystemMbr - $SizeRecovery
            $SizeWindowsGB = [math]::Round($SizeWindows / 1GB,1)
            Write-Verbose "Disk $($OSDDisk.Number) Windows Partition $($SizeWindowsGB)GB NTFS $LabelWindows" -Verbose
            Write-Verbose "Disk $($OSDDisk.Number) Recovery Partition $($SizeRecovery / 1MB)MB NTFS $LabelRecovery" -Verbose
        }
    } #>
    #======================================================================================================
    #	Get OSDDisks
    #   Update the OSDDisk information
    #======================================================================================================
    $OSDDisk = Get-Disk -Number $OSDDisk.Number
    #======================================================================================================
    #	RAW
    #   Force: Make sure that the OSDDisk is RAW, if not we need to exit
    #   Simulation: No need to evaluate
    #======================================================================================================
    if (($global:OSDDiskSandbox -eq $false) -and ($OSDDisk.PartitionStyle -ne 'RAW')) {Write-Warning "OSDDisk does not have RAW PartitionStyle.  $Title cannot create additional Partitions.  Exiting"; Break}
    #======================================================================================================
    #	Display OSDDisk
    #   Show the current information about this Disk.  At this point, it should be RAW
    #======================================================================================================
    Write-Host "============================================================================================" -ForegroundColor Cyan
    Write-Host "Disk $($OSDDisk.Number) - $($OSDDisk.FriendlyName) ($([math]::Round($OSDDisk.Size / 1000000000))GB $($OSDDisk.PartitionStyle)) BusType=$($OSDDisk.BusType)" -ForegroundColor Cyan
    Write-Host "============================================================================================" -ForegroundColor Cyan
    #======================================================================================================
    #	AskPartition
    #   Ask if it is ok to Partition the Drive
    #   Simulation: No need to evaluate
    #   P to Partition
    #   X to exit
    #======================================================================================================
    if ($global:OSDDiskSandbox -eq $false) {
        do {$AskPartition = Read-Host "Press P to Partition this Disk, or X to quit (and press Enter)"}
        until ($AskPartition -eq 'P' -or $AskPartition -eq 'X')
        if ($AskPartition -eq 'X') {Break}
    }
    #======================================================================================================
    #	Initialize-OSDDisk
    #   OSDDisk is RAW so it needs to be Initialized
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
    #======================================================================================================
    #	Parameters
    #======================================================================================================
    if (-not ($Force.IsPresent)) {
        Write-Host "============================================================================================" -ForegroundColor Cyan
        Write-Host "Parameters" -ForegroundColor Cyan
        Write-Host "============================================================================================" -ForegroundColor Cyan
        Write-Host "-Title: $Title" -ForegroundColor Cyan
        Write-Host "-DiskNumber: $DiskNumber" -ForegroundColor Cyan
        Write-Host "-LabelSystem: $LabelSystem" -ForegroundColor Cyan
        Write-Host "-LabelWindows: $LabelWindows" -ForegroundColor Cyan
        if (Get-OSDGather -Property IsUEFI) {
            Write-Host "-LabelRecovery (GPT): $LabelRecovery" -ForegroundColor Cyan
            Write-Host "-SizeSystemGpt (GPT): $($SizeSystemGpt/ 1MB)MB" -ForegroundColor Cyan
            Write-Host "-SizeMSR (GPT): $($SizeMSR / 1MB)MB" -ForegroundColor Cyan
            Write-Host "-SizeRecovery (GPT): $($SizeRecovery/ 1MB)MB" -ForegroundColor Cyan
            Write-Host "-SkipRecoveryPartition (GPT): $SkipRecoveryPartition" -ForegroundColor Cyan
        } else {
            Write-Host "-SizeSystemMbr (MBR): $($SizeSystemMbr/ 1MB)MB" -ForegroundColor Cyan
        }
        Write-Host "-Force: $Force" -ForegroundColor Cyan
    }
}