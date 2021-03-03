<#
.SYNOPSIS
Clear-Disk on ALL USB Disks in WinPE and Full OS

.DESCRIPTION
Clear-Disk on ALL USB Disks in WinPE and Full OS
-DiskNumber: Single Disk execution
-Force: Required for execution
-Initialize: Initializes RAW as MBR or GPT PartitionStyle
-PartitionStyle: Overrides the automatic selection of MBR or GPT

.PARAMETER InputObject
Get-OSDDisk or Get-USBDisk Object

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
Clear-USBDisk
Displays Get-Help Clear-USBDisk

.EXAMPLE
Clear-USBDisk -Force
Interactive.  Prompted to Confirm Clear-Disk for each USB Disk

.EXAMPLE
Clear-USBDisk -Force -Confirm:$false
Non-Interactive. Clears all USB Disks without being prompted to Confirm

.LINK
https://osd.osdeploy.com/module/functions/disk/clear-usbdisk

.NOTES
21.3.3      Added SizeGB
21.2.22     Initial Release
#>
function Clear-USBDisk {
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
    $GetUSBDisk = $null
    if ($InputObject) {
        $GetUSBDisk = $InputObject
    } else {
        $GetUSBDisk = Get-USBDisk | Sort-Object Number
    }
    #======================================================================================================
    #	Get DiskNumber
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetUSBDisk = $GetUSBDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
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
    #	Display Disk Information
    #======================================================================================================
    $GetUSBDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions, @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    
    if ($IsForcePresent -eq $false) {
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
    $ClearUSBDisk = @()
    foreach ($Item in $GetUSBDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
            )){
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Clear-Disk -Number $Item.Number -RemoveData -RemoveOEM -ErrorAction Stop
            
            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearUSBDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    $ClearUSBDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions, @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
    #======================================================================================================
}