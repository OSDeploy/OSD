function Clear-USBDisk {
    <#
    .SYNOPSIS
    Clears USB Disks
    Disks are Initialized in MBR or GPT PartitionStyle

    .DESCRIPTION
    Clears USB Disks
    Disks are Initialized in MBR or GPT PartitionStyle

    .PARAMETER InputObject
    Get-OSDDisk or Get-USBDisk Object

    .PARAMETER DiskNumber
    Specifies the disk number for which to get the associated Disk object
    Alias = Disk, Number

    .PARAMETER Force
    Required for execution
    Alias = F

    .PARAMETER PartitionStyle
    Override the automatic Partition Style of the Initialized Disk
    EFI Default = GPT
    BIOS Default = MBR
    Alias = PS

    .EXAMPLE
    Clear-USBDisk
    Displays Get-Help Clear-USBDisk -Examples

    .EXAMPLE
    Clear-USBDisk -Force
    Interactive.  Prompted to Confirm Clear-Disk for each USB Disk

    .EXAMPLE
    Clear-USBDisk -Force -Confirm:$false
    Non-Interactive. Clears all USB Disks without being prompted to Confirm

    .LINK
    https://osd.osdeploy.com/module/disk/clear-usbdisk

    .NOTES
    21.2.22     Initial Release
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

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
        Get-Help $($MyInvocation.MyCommand.Name) -Examples
    }
    #======================================================================================================
    #	Display Disk Information
    #======================================================================================================
    $GetUSBDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
    
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
            
            #if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            #}
            
            $ClearUSBDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    $ClearUSBDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
    #======================================================================================================
}