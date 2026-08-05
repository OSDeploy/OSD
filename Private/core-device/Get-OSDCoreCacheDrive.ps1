function Get-OSDCoreCacheDrive {
    <#
    .SYNOPSIS
        Returns OSDCloud cache drive metadata from local file system drives.

    .DESCRIPTION
        Enumerates mounted file system drives that contain an OSDCloud cache path
        and returns only USB, DriveRoot, VolumeLabel, and VolumeUniqueId properties.

    .PARAMETER Include
        Optional list of drive letters to include when searching for OSDCloud cache
        paths. Accepts values such as 'C', 'D:', or 'E:\'.

        When omitted, all mounted file system drive letters are considered.

    .PARAMETER Exclude
        Optional list of drive letters to exclude when searching for OSDCloud cache
        paths. Accepts values such as 'C', 'D:', or 'E:\'.

        Excluded drives are skipped even when they are also present in Include.

    .OUTPUTS
        System.Object[]. Objects with USB, DriveRoot, VolumeLabel, and VolumeUniqueId.

    .EXAMPLE
        Get-OSDCoreCacheDrive

        Returns OSDCloud cache drive metadata for all mounted file system drives.

    .EXAMPLE
        Get-OSDCoreCacheDrive -Include C,D -Exclude D

        Returns OSDCloud cache drive metadata only for drive C.

    .LINK
        https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
        Author: David Segura - Recast Software
        2026-07-18 - Initial function created
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Include,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Exclude
    )

    function Get-DriveVolumeMetadata {
        param(
            [Parameter(Mandatory)]
            [string]$DriveRoot
        )

        $volume = $null
        $usb = $false
        if ($DriveRoot -match '^[A-Z]:\\$') {
            try {
                $driveLetter = $DriveRoot.Substring(0, 1)
                $volume = Get-Volume -DriveLetter $driveLetter -ErrorAction Stop
                $usb = [bool](Get-Disk -ErrorAction SilentlyContinue |
                    Where-Object { $_.BusType -eq 'USB' } |
                    Get-Partition -ErrorAction SilentlyContinue |
                    Where-Object { $_.DriveLetter -eq $driveLetter })
            } catch {
                $volume = $null
                $usb = $false
            }
        }

        [PSCustomObject]@{
            USB            = [bool]$usb
            DriveRoot      = $DriveRoot
            VolumeLabel    = if ($volume) { [string]$volume.FileSystemLabel } else { $null }
            VolumeUniqueId = if ($volume) { [string]$volume.UniqueId } else { $null }
        }
    }

    function ConvertTo-DriveLetterList {
        param(
            [Parameter()]
            [string[]]$DriveLetters
        )

        $normalized = foreach ($driveLetter in $DriveLetters) {
            if ([string]::IsNullOrWhiteSpace($driveLetter)) {
                continue
            }

            $value = $driveLetter.Trim().TrimEnd('\\')
            if ($value.Length -lt 1) {
                continue
            }

            $letter = $value.Substring(0, 1).ToUpperInvariant()
            if ($letter -match '^[A-Z]$') {
                $letter
            }
        }

        @($normalized | Sort-Object -Unique)
    }

    $includedDriveLetters = ConvertTo-DriveLetterList -DriveLetters $Include
    $excludedDriveLetters = ConvertTo-DriveLetterList -DriveLetters $Exclude

    $result = Get-PSDrive -PSProvider FileSystem |
        Where-Object { $_.Root -match '^[A-Z]:\\$' } |
        Where-Object {
            $driveLetter = ([string]$_.Root).Substring(0, 1).ToUpperInvariant()
            (($includedDriveLetters.Count -eq 0) -or ($driveLetter -in $includedDriveLetters)) -and
            ($driveLetter -notin $excludedDriveLetters)
        } |
        ForEach-Object {
            $driveRoot = [string]$_.Root
            $osdCloudPath = Join-Path -Path $driveRoot -ChildPath 'OSDCloud'

            if (Test-Path -LiteralPath $osdCloudPath) {
                Get-DriveVolumeMetadata -DriveRoot $driveRoot
            }
        }

    return @($result | Sort-Object -Property DriveRoot -Unique)
}
