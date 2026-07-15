function Step-OSDCloudClearDisk {
    <#
    .SYNOPSIS
    Clears fixed disks before creating new operating system partitions.

    .DESCRIPTION
    Runs the OSDCloud Clear-Disk logic when disk clearing is enabled. If multiple fixed
    disks are detected, ClearDiskConfirm is forced to true before invoking Clear-LocalDisk.

    .EXAMPLE
    Step-OSDCloudClearDisk
    Executes Clear-Disk validation and clears fixed disks using the configured confirmation behavior.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Fixed Disks must be cleared before new partitions can be created
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Clear-Disk"
    if ($Global:OSDCloud.SkipClearDisk -eq $false) {
        if (($Global:OSDCloud.GetDiskFixed | Measure-Object).Count -ge 2) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] More than 1 Fixed Disk is present, Clear-Disk Confirm is required"
            $Global:OSDCloud.ClearDiskConfirm = $true
        }
        if ($Global:OSDCloud.ClearDiskConfirm -eq $true) {
            Clear-LocalDisk -Force -NoResults -ErrorAction Stop
        }
        else {
            Clear-LocalDisk -Force -NoResults -Confirm:$false -ErrorAction Stop
        }
    }
    #=================================================
}
