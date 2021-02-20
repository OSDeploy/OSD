function New-BETA {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High')]
    param ()
    
    #======================================================================================================
    #	OSD Module Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	ShouldProcess
    #======================================================================================================
    $OSDDisk = Get-OSDDisk -Number 0
    if ($PSCmdlet.ShouldProcess(
        "Disk $($OSDDisk.Number) $($OSDDisk.BusType) $($OSDDisk.MediaType) $($OSDDisk.FriendlyName) [$($OSDDisk.NumberOfPartitions) $($OSDDisk.PartitionStyle) Partitions]",
        "Prepare OSDDisk (clears all data)"
        )){
        Write-Host -ForegroundColor Green -BackgroundColor Black "Cleaning Disk $($OSDDisk.Number)"
        Write-Host -ForegroundColor Green -BackgroundColor Black "Initializing Disk $($OSDDisk.Number) as $PartitionStyle"
    }
}

