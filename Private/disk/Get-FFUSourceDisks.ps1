function Get-FFUSourceDisks {
    <#
    .SYNOPSIS
    Returns eligible source disks for FFU capture.

    .DESCRIPTION
    Filters local disks to include online, non-offline, non-boot disks with at
    least one partition and a nonzero size.

    .EXAMPLE
    Get-FFUSourceDisks
    Returns disks that can be selected as FFU source disks.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Added initial in-function help block
    #>
    [CmdletBinding()]
    param ()
    Get-LocalDisk | Where-Object {$_.NumberOfPartitions -ge '1'} | Where-Object {$_.OperationalStatus -eq 'Online'} | Where-Object {$_.Size -gt 0} | Where-Object {$_.IsOffline -eq $false} | Where-Object {$_.IsBoot -eq $false}
}
