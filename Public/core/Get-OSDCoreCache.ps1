function Get-OSDCoreCache {
    <#
    .SYNOPSIS
        Returns OSDCloud cache paths or cached content found on local file system drives.

    .DESCRIPTION
        Enumerates mounted file system drives and discovers OSDCloud cache content.
        Returns objects with Type, FullName, SizeMB,
        DriveRoot, VolumeLabel, and VolumeUniqueId properties.

        If Type is omitted, returns discovered '<DriveLetter>:\OSDCloud' cache root
        folders as Type 'Cache'.

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

    .OUTPUTS
        System.Object[]. Objects with Type, FullName, SizeMB,
        DriveRoot, VolumeLabel, and VolumeUniqueId.

    .EXAMPLE
        Get-OSDCoreCache

        Returns paths such as 'C:\OSDCloud' and 'D:\OSDCloud' when present.

    .EXAMPLE
        Get-OSDCoreCache -Type ESD

        Returns all .esd files under each discovered cache OS folder.

    .EXAMPLE
        Get-OSDCoreCache -Type ESD,DriverPacks

        Returns all .esd files and driver pack files from each discovered cache.

    .EXAMPLE
        Get-OSDCoreCache -Type *

        Returns all supported cache content types.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter()]
        [ValidateSet('ESD', 'ISO', 'DriverPacks', 'Drivers', 'Profiles', 'WIM', '*')]
        [string[]]$Type
    )

    $Error.Clear()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"

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
        if ($DriveRoot -match '^[A-Z]:\\$') {
            try {
                $volume = Get-Volume -DriveLetter $DriveRoot.Substring(0, 1) -ErrorAction Stop
            } catch {
                $volume = $null
            }
        }

        return [PSCustomObject]@{
            DriveRoot      = $DriveRoot
            VolumeLabel    = if ($volume) { [string]$volume.FileSystemLabel } else { $null }
            VolumeUniqueId = if ($volume) { [string]$volume.UniqueId } else { $null }
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
            Type           = $ResultType
            FullName       = $ResultFullName
            SizeMB         = Get-FileOnlySizeMB -Path $ResultFullName
            DriveRoot      = [string]$VolumeMetadata.DriveRoot
            VolumeLabel    = [string]$VolumeMetadata.VolumeLabel
            VolumeUniqueId = [string]$VolumeMetadata.VolumeUniqueId
        }
    }

    $cachePaths = Get-PSDrive -PSProvider FileSystem |
        Where-Object { $_.Root -match '^[A-Z]:\\$' } |
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

    if (-not $PSBoundParameters.ContainsKey('Type')) {
        $result = foreach ($cacheEntry in $cachePaths) {
            New-CacheResultObject -ResultType 'Cache' -ResultFullName ([string]$cacheEntry.CachePath) -VolumeMetadata $cacheEntry.VolumeMetadata
        }

        $result = @($result | Sort-Object -Property FullName, Type -Unique | Sort-Object -Property FullName)
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($result.Count) path(s)"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return $result
    }

    $selectedTypes = @($Type | Sort-Object -Unique)
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
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($result.Count) path(s)"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"

    return $result
}
