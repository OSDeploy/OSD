function Test-Alpha {
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
    #>
    [CmdletBinding(ConfirmImpact = 'High')]
    #[CmdletBinding(SupportsShouldProcess = $true)]
    #[CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]

    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

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
    $VerbosePreference = 'Continue'
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
    #	Process
    #======================================================================================================
    $ClearOSDDisk = @()
    foreach ($Item in $GetOSDDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]",
            "Clear-Disk"
            )){
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.NumberOfPartitions) $($Item.PartitionStyle) Partitions]"
            Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName)"
            $ClearOSDDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    $ClearOSDDisk | Select-Object -Property Number, BusType, MediaType, FriendlyName, PartitionStyle, NumberOfPartitions | Format-Table
}

