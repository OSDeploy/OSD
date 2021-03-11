<#
.SYNOPSIS
Clear-Disk on ALL Local Disks (non-USB) to RAW in WinPE only

.DESCRIPTION
Clear-Disk on ALL Local Disks (non-USB) to RAW in WinPE only
-DiskNumber: Single Disk execution
-Force: Required for execution
-Initialize: Initializes RAW as MBR or GPT PartitionStyle
-PartitionStyle: Overrides the automatic selection of MBR or GPT

.PARAMETER InputObject
Get-OSDDisk or Get-LocalDisk Object

.PARAMETER DiskNumber
Specifies the disk number for which to get the associated Disk object
Alias = Disk, Number

.PARAMETER Force
Required for execution
Alias = F

.PARAMETER Initialize
Initializes the cleared disk as MBR or GPT
Alias = I

.PARAMETER PartitionStyle
Override the automatic Partition Style of the Initialized Disk
EFI Default = GPT
BIOS Default = MBR
Alias = PS

.EXAMPLE
Clear-LocalDisk
Informational.  Executes Get-Help Clear-LocalDisk
Always displayed if the -Force parameter is not used

.EXAMPLE
Clear-LocalDisk -Force
Interactive.  Prompted to Confirm Clear-Disk for each Local Disk

.EXAMPLE
Clear-LocalDisk -Force -Confirm:$false
Non-Interactive. Clears all Local Disks without being prompted to Confirm

.LINK
https://osd.osdeploy.com/module/functions/disk/clear-localdisk

.NOTES
21.3.3      Added SizeGB
21.2.22     Initial Release
#>
function Clear-LocalDisk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('I')]
        [switch]$Initialize,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [switch]$Force,

        [Alias('W','Warn','Warning')]
        [switch]$ShowWarning
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
    #	Module and Command Information
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
        $GetLocalDisk = Get-LocalDisk -IsBoot:$false | Sort-Object Number
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
    <# $GetLocalDisk = $GetLocalDisk | Where-Object {$_.Size -gt 15GB} #>
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
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #======================================================================================================
    #	Display Warning
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('ShowWarning')) {
        Write-Warning "All Local Hard Drives will be cleared and all data will be lost"
        pause
    }
    #======================================================================================================
    #	Display Disk Information
    #======================================================================================================
    $GetLocalDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions, @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
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
    $ClearLocalDisk = @()
    foreach ($Item in $GetLocalDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
            )){
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Diskpart-Clean -DiskNumber $Item.Number

            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearLocalDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    $ClearLocalDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions, @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    #======================================================================================================
}