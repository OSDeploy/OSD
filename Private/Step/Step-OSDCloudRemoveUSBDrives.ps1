function Step-OSDCloudRemoveUSBDrives {
    <#
    .SYNOPSIS
    Removes access paths for detected USB partitions during OSDCloud workflow steps.

    .DESCRIPTION
    Step-OSDCloudRemoveUSBDrives iterates USB partitions collected in OSD core
    device state and attempts to remove each partition access path. Removal is
    only performed when running in WinPE (system drive X:) and is skipped with
    verbose logging in other environments.

    .EXAMPLE
    Step-OSDCloudRemoveUSBDrives
    Removes access paths for USB partitions in WinPE to avoid drive letter
    conflicts during OSDCloud deployment steps.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Added comment-based help block
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if (-not $global:OSDCoreDevice.USBPartitions) {
        # If no USB partitions were discovered earlier, there is nothing to remove.
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No USB partitions detected"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    # Build a quick lookup table so we can find volume labels by drive letter.
    $usbVolumesByDriveLetter = @{}
    foreach ($volume in @($global:OSDCoreDevice.USBVolumes)) {
        if (-not [string]::IsNullOrWhiteSpace($volume.DriveLetter)) {
            $usbVolumesByDriveLetter[[string]$volume.DriveLetter] = $volume
        }
    }

    foreach ($Item in $global:OSDCoreDevice.USBPartitions) {
        # A partition can have one or more access paths (drive letter or mount path).
        $accessPaths = @($Item.AccessPaths) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        if (-not $accessPaths) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Skipping USB partition without access paths (Disk $($Item.DiskNumber), Partition $($Item.PartitionNumber))"
            continue
        }

        # Capture the drive letter (when present) so logs can include a friendly label.
        $driveLetter = $null
        foreach ($path in $accessPaths) {
            if ($path -match '^(?<DriveLetter>[A-Z]):\\$') {
                $driveLetter = $Matches.DriveLetter
                break
            }
        }

        $fileSystemLabel = $null
        if ($driveLetter -and $usbVolumesByDriveLetter.ContainsKey($driveLetter)) {
            $fileSystemLabel = $usbVolumesByDriveLetter[$driveLetter].FileSystemLabel
        }

        foreach ($accessPath in $accessPaths) {
            # Do not attempt to remove canonical volume GUID paths.
            if ($accessPath -match '^\\\\\?\\Volume\{[0-9a-fA-F\-]+\}\\$') {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Skipped GUID access path '$accessPath'"
                continue
            }

            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing USB Volume $fileSystemLabel on AccessPath $accessPath"
            try {
                # Remove this path so USB media does not interfere with deployment steps.
                Remove-PartitionAccessPath -AccessPath $accessPath -DiskNumber $Item.DiskNumber -PartitionNumber $Item.PartitionNumber -ErrorAction Stop
            }
            catch {
                # Keep going if one partition fails so others can still be processed.
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to remove access path '$accessPath' (Disk $($Item.DiskNumber), Partition $($Item.PartitionNumber)): $($_.Exception.Message)"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
