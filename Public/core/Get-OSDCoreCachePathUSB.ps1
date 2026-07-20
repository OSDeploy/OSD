function Get-OSDCoreCachePathUSB {
    <#
    .SYNOPSIS
        Returns OSDCloud cache paths located on USB drives.

    .DESCRIPTION
        Uses Get-OSDCoreCacheDrive to enumerate OSDCloud cache drives and returns
        the OSDCloud directory path for each discovered cache drive where USB is true,
        the file system is NTFS or exFAT, and more than the specified free space is available.

    .PARAMETER Include
        Optional list of drive letters to include when searching for OSDCloud cache
        drives. Accepts values such as 'C', 'D:', or 'E:\'.

        When omitted, all mounted file system drive letters are considered.

    .PARAMETER Exclude
        Optional list of drive letters to exclude when searching for OSDCloud cache
        drives. Accepts values such as 'C', 'D:', or 'E:\'.

        Excluded drives are skipped even when they are also present in Include.

    .PARAMETER SizeRemaining
        Optional minimum free space required on the USB cache drive, in GB.

        The default is 10 GB.

    .OUTPUTS
        System.String[]. OSDCloud directory paths located on USB drives with more
        than the specified GB free and an NTFS or exFAT file system.

    .EXAMPLE
        Get-OSDCoreCachePathUSB

        Returns OSDCloud directory paths for all discovered USB cache drives with more than 10 GB free and an NTFS or exFAT file system.

    .EXAMPLE
        Get-OSDCoreCachePathUSB -Include D

        Returns the OSDCloud directory path when drive D contains an OSDCloud cache path, is a USB drive, has more than 10 GB free, and is formatted NTFS or exFAT.

    .EXAMPLE
        Get-OSDCoreCachePathUSB -SizeRemaining 20

        Returns OSDCloud directory paths for discovered USB cache drives with more than 20 GB free and an NTFS or exFAT file system.

    .LINK
        https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
        Author: David Segura - Recast Software
        2026-07-18 - Initial function created
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Include,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Exclude,

        [Parameter()]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$SizeRemaining = 10
    )

    $cacheDriveParameters = @{}
    if ($PSBoundParameters.ContainsKey('Include')) {
        $cacheDriveParameters.Include = $Include
    }
    if ($PSBoundParameters.ContainsKey('Exclude')) {
        $cacheDriveParameters.Exclude = $Exclude
    }

    $minimumSizeRemaining = [int64]$SizeRemaining * 1GB

    $cacheUsb = Get-OSDCoreCacheDrive @cacheDriveParameters |
        Where-Object {
            $volume = $null
            if ($_.USB -and $_.DriveRoot -match '^([A-Z]):\\$') {
                try {
                    $volume = Get-Volume -DriveLetter $Matches[1] -ErrorAction Stop
                } catch {
                    $volume = $null
                }
            }

            $volume -and
            ($volume.FileSystem -in @('NTFS', 'exFAT')) -and
            ([int64]$volume.SizeRemaining -gt $minimumSizeRemaining)
        } |
        ForEach-Object { Join-Path -Path $_.DriveRoot -ChildPath 'OSDCloud' }

    return @($cacheUsb | Sort-Object -Unique)
}
