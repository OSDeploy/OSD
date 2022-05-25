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
    https://osd.osdeploy.com/module/osddisk/new-osdisk

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
        $GetDisk = Get-Disk.fixed | Sort-Object Number
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

        $OSDisk = Select-Disk.fixed -Input $GetDisk
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
    Get-Disk.osd | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName, Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
}