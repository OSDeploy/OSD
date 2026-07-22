function Get-OSDCoreCacheContent {
    <#
    .SYNOPSIS
        Returns cached OSDCloud content found on local file system drives.

    .DESCRIPTION
        Enumerates mounted file system drives and discovers OSDCloud cache content.
        Returns objects with Type, Name, FullName, SizeMB,
        DriveRoot, VolumeLabel, VolumeUniqueId, and USB properties.
        Exports the returned object to $env:Temp\OSDCoreCacheContent.xml each time the function runs.

        If Type is omitted, retur ns all supported cache content types.

        Type values:
        - ESD: All .esd files under '<DriveLetter>:\OSDCloud\OS' recursively.
        - ISO: All .iso files under '<DriveLetter>:\OSDCloud\ISO' recursively.
        - DriverPacks: All .cab, .exe, .msi, and .zip files under
          '<DriveLetter>:\OSDCloud\DriverPacks' recursively.
        - Drivers: Immediate folders under '<DriveLetter>:\OSDCloud\Drivers' that
          contain at least one .inf file in any child folder.
                - Profiles: Immediate folders under '<DriveLetter>:\OSDCloud\Profiles'.
        - WIM: All .wim files under '<DriveLetter>:\OSDCloud\WIM' recursively.
        - *: Includes all supported Type values.

    .PARAMETER Type
        Optional cache content selector.

        Supports one or more values. Use '*' to return all supported
        cache content types.

    .PARAMETER Include
        Optional list of drive letters to include when searching for OSDCloud cache
        content. Accepts values such as 'C', 'D:', or 'E:\'.

        When omitted, all mounted file system drive letters are considered.

    .PARAMETER Exclude
        Optional list of drive letters to exclude when searching for OSDCloud cache
        content. Accepts values such as 'C', 'D:', or 'E:\'.

        Excluded drives are skipped even when they are also present in Include.

    .OUTPUTS
        System.Object[]. Objects with Type, Name, FullName, SizeMB,
        DriveRoot, VolumeLabel, VolumeUniqueId, and USB.

    .EXAMPLE
        Get-OSDCoreCacheContent

        Returns all supported cache content types.

    .EXAMPLE
        Get-OSDCoreCacheContent -Type ESD

        Returns all .esd files under each discovered cache OS folder.

    .EXAMPLE
        Get-OSDCoreCacheContent -Type ESD,DriverPacks

        Returns all .esd files and driver pack files from each discovered cache.

    .EXAMPLE
        Get-OSDCoreCacheContent -Type *

        Returns all supported cache content types.

    .EXAMPLE
        Get-OSDCoreCacheContent -Include C,D -Exclude D

        Searches only drive C for supported cache content types.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter()]
        [ValidateSet('ESD', 'ISO', 'DriverPacks', 'Drivers', 'Profiles', 'WIM', '*')]
        [string[]]$Type,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Include,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z](:\\)?$|^[a-zA-Z]$')]
        [string[]]$Exclude
    )

    $Error.Clear()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent is updating"

    function Get-FileOnlySizeMB {
        param(
            [Parameter(Mandatory)]
            [string]$Path
        )

        if (-not (Test-Path -LiteralPath $Path)) {
            return 0
        }

        $item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
        if (-not $item) {
            return 0
        }

        if ($item.PSIsContainer) {
            $totalBytes = (Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum
            if ($null -eq $totalBytes) {
                $totalBytes = 0
            }
            return [math]::Round(($totalBytes / 1MB), 2)
        }

        return [math]::Round((([int64]$item.Length) / 1MB), 2)
    }

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

        return [PSCustomObject]@{
            DriveRoot      = $DriveRoot
            VolumeLabel    = if ($volume) { [string]$volume.FileSystemLabel } else { $null }
            VolumeUniqueId = if ($volume) { [string]$volume.UniqueId } else { $null }
            USB            = [bool]$usb
        }
    }

    function New-CacheResultObject {
        param(
            [Parameter(Mandatory)]
            [string]$ResultType,

            [Parameter(Mandatory)]
            [string]$ResultFullName,

            [Parameter(Mandatory)]
            $VolumeMetadata
        )

        [PSCustomObject]@{
            Name           = Split-Path -Path $ResultFullName -Leaf
            FullName       = $ResultFullName
            SizeMB         = Get-FileOnlySizeMB -Path $ResultFullName
            Type           = $ResultType
            USB            = [bool]$VolumeMetadata.USB
            DriveRoot      = [string]$VolumeMetadata.DriveRoot
            VolumeLabel    = [string]$VolumeMetadata.VolumeLabel
            VolumeUniqueId = [string]$VolumeMetadata.VolumeUniqueId
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

    $cachePaths = Get-PSDrive -PSProvider FileSystem |
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
                $volumeMetadata = Get-DriveVolumeMetadata -DriveRoot $driveRoot
                [PSCustomObject]@{
                    CachePath      = $osdCloudPath
                    VolumeMetadata = $volumeMetadata
                }
            }
        }

    $cachePaths = @($cachePaths | Sort-Object -Property CachePath -Unique)

    $selectedTypes = if ($PSBoundParameters.ContainsKey('Type')) {
        @($Type | Sort-Object -Unique)
    } else {
        @('ESD', 'ISO', 'DriverPacks', 'Drivers', 'Profiles', 'WIM')
    }
    if ($selectedTypes -contains '*') {
        $selectedTypes = @('ESD', 'ISO', 'DriverPacks', 'Drivers', 'Profiles', 'WIM')
    }

    $result = foreach ($selectedType in $selectedTypes) {
        switch ($selectedType) {
            'ESD' {
                foreach ($cacheEntry in $cachePaths) {
                    $osPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'OS'
                    if (Test-Path -LiteralPath $osPath) {
                        Get-ChildItem -LiteralPath $osPath -Recurse -File -Filter '*.esd' -ErrorAction SilentlyContinue |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'ESD' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
            'ISO' {
                foreach ($cacheEntry in $cachePaths) {
                    $isoPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'ISO'
                    if (Test-Path -LiteralPath $isoPath) {
                        Get-ChildItem -LiteralPath $isoPath -Recurse -File -Filter '*.iso' -ErrorAction SilentlyContinue |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'ISO' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
            'DriverPacks' {
                foreach ($cacheEntry in $cachePaths) {
                    $driverPacksPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'DriverPacks'
                    if (Test-Path -LiteralPath $driverPacksPath) {
                        Get-ChildItem -LiteralPath $driverPacksPath -Recurse -File -ErrorAction SilentlyContinue |
                            Where-Object { $_.Extension -in @('.cab', '.exe', '.msi', '.zip') } |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'DriverPacks' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
            'Drivers' {
                foreach ($cacheEntry in $cachePaths) {
                    $driversPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'Drivers'
                    if (Test-Path -LiteralPath $driversPath) {
                        Get-ChildItem -LiteralPath $driversPath -Directory -ErrorAction SilentlyContinue |
                            Where-Object {
                                @(Get-ChildItem -LiteralPath $_.FullName -Recurse -File -Filter '*.inf' -ErrorAction SilentlyContinue).Count -gt 0
                            } |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'Drivers' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
            'Profiles' {
                foreach ($cacheEntry in $cachePaths) {
                    $profilesPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'Profiles'
                    if (Test-Path -LiteralPath $profilesPath) {
                        Get-ChildItem -LiteralPath $profilesPath -Directory -ErrorAction SilentlyContinue |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'Profiles' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
            'WIM' {
                foreach ($cacheEntry in $cachePaths) {
                    $wimPath = Join-Path -Path $cacheEntry.CachePath -ChildPath 'WIM'
                    if (Test-Path -LiteralPath $wimPath) {
                        Get-ChildItem -LiteralPath $wimPath -Recurse -File -Filter '*.wim' -ErrorAction SilentlyContinue |
                            ForEach-Object {
                                New-CacheResultObject -ResultType 'WIM' -ResultFullName ([string]$_.FullName) -VolumeMetadata $cacheEntry.VolumeMetadata
                            }
                    }
                }
                break
            }
        }
    }

    $result = @($result | Sort-Object -Property FullName, Type -Unique | Sort-Object -Property FullName)
    $result | Export-Clixml -Path (Join-Path -Path $env:Temp -ChildPath 'OSDCoreCacheContent.xml') -Force
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($result.Count) path(s)"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"

    return $result
}
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
function Get-OSDCoreCacheUSBPath {
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
        Get-OSDCoreCacheUSBPath

        Returns OSDCloud directory paths for all discovered USB cache drives with more than 10 GB free and an NTFS or exFAT file system.

    .EXAMPLE
        Get-OSDCoreCacheUSBPath -Include D

        Returns the OSDCloud directory path when drive D contains an OSDCloud cache path, is a USB drive, has more than 10 GB free, and is formatted NTFS or exFAT.

    .EXAMPLE
        Get-OSDCoreCacheUSBPath -SizeRemaining 20

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
