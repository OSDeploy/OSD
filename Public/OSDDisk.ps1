function Clear-OSDDisk {
    <#
    .SYNOPSIS
    Clears Local Disks (non-USB) for OS Deployment.  Disks are Initialized in MBR or GPT PartitionStyle

    .DESCRIPTION
    Clears all Local Disks for OS Deployment
    Before deploying an Operating System, it is important to clear all local disks
    If this function is running from Windows, it will ALWAYS be in Sandbox mode, regardless of the -Force parameter\

    .PARAMETER Confirm
    Required to confirm Clear-Disk

    .PARAMETER Force
    Sandbox mode is enabled by default to be non-destructive
    This parameter will bypass Sandbox mode
    Alias = F

    .EXAMPLE
    PS> Clear-OSDDisk
    Displays Get-Help Clear-OSDDisk -Examples

    .EXAMPLE
    Clear-OSDDisk -Force
    Prompted to Confirm Clear-Disk for each Local Disk.  Interactive

    .EXAMPLE
    Clear-OSDDisk -Force -Confirm:$false
    Clears all Local Disks without being prompted to Confirm.  Non-interactive

    .LINK
    https://osd.osdeploy.com/module/osddisk/clear-osddisk

    .NOTES
    21.2.14     Initial Release
    21.2.21     Updated
    #>
    [CmdletBinding(ConfirmImpact = 'High')]
    #[CmdletBinding(SupportsShouldProcess = $true)]
    #[CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        #[Parameter(ValueFromPipelineByPropertyName = $true)]
        #[Alias('I')]
        #[switch]$Initialize,

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
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #======================================================================================================
    #	OSD Module Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	Get-OSDDisk
    #======================================================================================================
    $GetOSDDisk = $null
    if ($InputObject) {
        $GetOSDDisk = $InputObject
    } else {
        $GetOSDDisk = Get-OSDDisk -BusTypeNot USB,Virtual | `
        #Where-Object {($_.Size -gt 15GB)} | `
        Sort-Object Number
    }
    #======================================================================================================
    #	PartitionStyle
    #======================================================================================================
    if (Get-OSDGather -Property IsUEFI) {
        Write-Verbose "IsUEFI = $true"
        $PartitionStyle = 'GPT'
    } else {
        Write-Verbose "IsUEFI = $false"
        $PartitionStyle = 'MBR'
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
    $GetOSDDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
    
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
    #	Clear-Disk
    #======================================================================================================
    $ClearOSDDisk = @()
    foreach ($Item in $GetOSDDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]",
            "Clear-Disk"
            )){
            $ClearOSDDisk += Get-OSDDisk -Number $Item.Number
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
            Diskpart-Clean -DiskNumber $Item.Number
            Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName)"
            $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            
            if ($Initialize -eq $true) {
            }
        }
    }
    $ClearOSDDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
    #======================================================================================================
}
function Get-OSDDisk {
    <#
    .SYNOPSIS
    Similar to Get-Disk, but includes the MediaType

    .DESCRIPTION
    Similar to Get-Disk, but includes the MediaType

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
    Values = 'ATA','NVMe','SAS','SCSI','USB','Virtual'
    PS> Get-OSDDisk -BusType NVMe
    PS> Get-OSDDisk -BusType NVMe,SAS

    .PARAMETER BusTypeNot
    Returns Disk results notin BusType values
    Values = 'ATA','NVMe','SAS','SCSI','USB','Virtual'
    PS> Get-OSDDisk -BusTypeNot USB
    PS> Get-OSDDisk -BusTypeNot USB,Virtual

    .PARAMETER MediaType
    Returns Disk results in MediaType values
    Values = 'HDD','SSD','Unspecified'
    PS> Get-OSDDisk -MediaType SSD

    .PARAMETER MediaTypeNot
    Returns Disk results notin MediaType values
    Values = 'HDD','SSD','Unspecified'
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
    https://osd.osdeploy.com/module/osddisk/get-osddisk

    .NOTES
    19.10.10    Created by David Segura @SeguraOSD
    21.2.19     Complete redesign
    #>
    [CmdletBinding()]
    param (
        [Alias('Disk','DiskNumber')]
        [uint32]$Number,

        [bool]$BootFromDisk,
        [bool]$IsBoot,
        [bool]$IsReadOnly,
        [bool]$IsSystem,

        [ValidateSet('ATA','NVMe','SAS','SCSI','USB','Virtual')]
        [string[]]$BusType,
        [ValidateSet('ATA','NVMe','SAS','SCSI','USB','Virtual')]
        [string[]]$BusTypeNot,
        
        [ValidateSet('HDD','SSD','Unspecified')]
        [string[]]$MediaType,
        [ValidateSet('HDD','SSD','Unspecified')]
        [string[]]$MediaTypeNot,

        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyle,
        [ValidateSet('GPT','MBR','RAW')]
        [string[]]$PartitionStyleNot
    )

    $GetDisk = Get-Disk | Sort-Object DiskNumber | Select-Object -Property *
    $GetPhysicalDisk = Get-PhysicalDisk | Sort-Object DeviceId

    if ($PSBoundParameters.ContainsKey('Number')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $Number}
    }

    foreach ($Disk in $GetDisk) {
        foreach ($PhysicalDisk in $GetPhysicalDisk | Where-Object {$_.DeviceId -eq $Disk.Number}) {
            $Disk | Add-Member -NotePropertyName 'MediaType' -NotePropertyValue $PhysicalDisk.MediaType
        }
    }
<#     if ($GetDisk) {
        Write-Verbose "The following Disks are present"
        foreach ($item in $GetDisk) {
            Write-Verbose "Disk $($item.Number) $($item.BusType) $($item.MediaType) $($item.FriendlyName) [$($item.PartitionStyle) $($item.NumberOfPartitions) Partitions]"
        }
    } #>

    if ($BootFromDisk)          {$GetDisk = $GetDisk | Where-Object {$_.BootFromDisk -in $BootFromDisk}}
    if ($BusType)               {$GetDisk = $GetDisk | Where-Object {$_.BusType -in $BusType}}
    if ($BusTypeNot)            {$GetDisk = $GetDisk | Where-Object {$_.BusType -notin $BusTypeNot}}
    if ($IsBoot)                {$GetDisk = $GetDisk | Where-Object {$_.IsBoot -in $IsBoot}}
    if ($IsReadOnly)            {$GetDisk = $GetDisk | Where-Object {$_.IsReadOnly -in $IsReadOnly}}
    if ($IsSystem)              {$GetDisk = $GetDisk | Where-Object {$_.IsSystem -in $IsSystem}}
    if ($MediaType)             {$GetDisk = $GetDisk | Where-Object {$_.MediaType -in $MediaType}}
    if ($MediaTypeNot)          {$GetDisk = $GetDisk | Where-Object {$_.MediaType -notin $MediaTypeNot}}
    if ($PartitionStyle)        {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -in $PartitionStyle}}
    if ($PartitionStyleNot)     {$GetDisk = $GetDisk | Where-Object {$_.PartitionStyle -notin $PartitionStyleNot}}
    Return $GetDisk
}
function New-OSDDisk {
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
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
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
    if (($GetOSDDisk | Measure-Object).Count -eq 1) {
        $OSDDisk = $GetOSDDisk
    } else {
        Write-Host ""
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
    }
}