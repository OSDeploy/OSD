function Test-OSDCoreCacheUSB {
    <#
    .SYNOPSIS
        Tests whether any OSDCloud cache drive is a USB drive.

    .DESCRIPTION
        Uses Get-OSDCoreCacheDrive to enumerate OSDCloud cache drives and returns
        true when at least one discovered cache drive has USB set to true.

    .PARAMETER Include
        Optional list of drive letters to include when searching for OSDCloud cache
        drives. Accepts values such as 'C', 'D:', or 'E:\'.

        When omitted, all mounted file system drive letters are considered.

    .PARAMETER Exclude
        Optional list of drive letters to exclude when searching for OSDCloud cache
        drives. Accepts values such as 'C', 'D:', or 'E:\'.

        Excluded drives are skipped even when they are also present in Include.

    .OUTPUTS
        System.Boolean. True when an OSDCloud cache drive is on USB; otherwise false.

    .EXAMPLE
        Test-OSDCoreCacheUSB

        Returns true if any discovered OSDCloud cache drive is a USB drive.

    .EXAMPLE
        Test-OSDCoreCacheUSB -Include D

        Returns true if drive D contains an OSDCloud cache path and is a USB drive.

    .LINK
        https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
        Author: David Segura - Recast Software
        2026-07-18 - Initial function created
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Include,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Exclude
    )

    $cacheDrive = @(Get-OSDCoreCacheDrive @PSBoundParameters | Where-Object { $_.USB })

    return [bool]($cacheDrive.Count -gt 0)
}
