function Step-OSDCloudRestoreUSBDrives {
    <#
    .SYNOPSIS
    Restores drive letter access for USB partitions used during OSDCloud.

    .DESCRIPTION
    Step-OSDCloudRestoreUSBDrives processes USB partitions discovered in
    OSD core device state and requests a drive letter assignment for each
    partition. The restore action is only attempted in WinPE (system drive X:)
    and is skipped with verbose logging in other environments.

    .EXAMPLE
    Step-OSDCloudRestoreUSBDrives
    Restores drive letters for detected USB partitions in WinPE after earlier
    workflow steps removed partition access paths.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Updated help and improved restore behavior
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if (-not $global:OSDCoreDevice.USBPartitions) {
        # Nothing to restore when no USB partitions were captured earlier.
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No USB partitions detected"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    # This step is intentionally limited to WinPE to avoid changing drive
    # letters on a live/full OS session.
    if ($env:SystemDrive -ne 'C:') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Skipped USB restore because system drive is $env:SystemDrive"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    $usbVolumesByDriveLetter = @{}
    foreach ($volume in @($global:OSDCoreDevice.USBVolumes)) {
        if (-not [string]::IsNullOrWhiteSpace($volume.DriveLetter)) {
            $usbVolumesByDriveLetter[[string]$volume.DriveLetter] = $volume
        }
    }

    foreach ($Item in $global:OSDCoreDevice.USBPartitions) {
        $driveLetter = $null
        foreach ($path in @($Item.AccessPaths)) {
            if ($path -match '^(?<DriveLetter>[A-Z]):\\$') {
                $driveLetter = $Matches.DriveLetter
                break
            }
        }

        $fileSystemLabel = $null
        if ($driveLetter -and $usbVolumesByDriveLetter.ContainsKey($driveLetter)) {
            $fileSystemLabel = $usbVolumesByDriveLetter[$driveLetter].FileSystemLabel
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Restoring USB Volume $fileSystemLabel"

        # Ask Windows to assign a drive letter for this USB partition again.
        try {
            Add-PartitionAccessPath -AssignDriveLetter -DiskNumber $Item.DiskNumber -PartitionNumber $Item.PartitionNumber -ErrorAction Stop
        }
        catch {
            # Continue restoring other partitions even if one restore fails.
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to restore access path (Disk $($Item.DiskNumber), Partition $($Item.PartitionNumber)): $($_.Exception.Message)"
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
