function Step-OSDCloudConfirmWindowsESDOffline {
    <#
    .SYNOPSIS
    Confirms the selected Windows ESD is available in OSDCore cache storage.

    .DESCRIPTION
    Validates that the selected operating system metadata and file name are present, refreshes the
    OSDCore cache inventory, finds the matching cached ESD outside the system drive, and verifies
    file integrity against published SHA1 or SHA256 values when available. If all checks pass, it
    marks offline ESD confirmation as successful in the deployment state.

    .PARAMETER OperatingSystemObject
    Operating system metadata object used to identify and validate the expected ESD payload.
    Defaults to the global OSDCore operating system object.

    .EXAMPLE
    Step-OSDCloudConfirmWindowsESDOffline
    Uses the global operating system object to validate that a matching cached ESD is present and
    trusted.

    .EXAMPLE
    Step-OSDCloudConfirmWindowsESDOffline -OperatingSystemObject $OS
    Validates the provided operating system object against cache contents and integrity hashes.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject
    )
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm OperatingSystemObject Offline:"
    #=================================================
    # Is there an OperatingSystem Object?
    if (-not ($OperatingSystemObject)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OperatingSystemObject is not set"
    }
    #=================================================
    # Is there an OperatingSystem Object FileName?
    if (-not $OperatingSystemObject.FileName) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OperatingSystemObject.FileName is not set"
    }
    #=================================================
    # Refresh cache inventory so we work with current cache state.
    # Cache can be updated by earlier steps, so do not rely on stale global data.
    $global:OSDCoreCache = Get-OSDCoreCache
    if (-not $global:OSDCoreCache) {
        Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreCache is empty"
        return
    }
    #=================================================
    # Match the exact filename requested by the selected OS metadata.
    # First match is intentional because filenames should be unique in cache.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - $($OperatingSystemObject.FileName)"
    $CacheWindowsESD = $global:OSDCoreCache | Where-Object { $_.Name -eq $OperatingSystemObject.FileName } | Where-Object { $_.DriveRoot -ne 'C:\' } | Select-Object -First 1
    #=================================================
    # Stop quietly when the requested payload is not cached.
    if (-not $CacheWindowsESD) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - OperatingSystemObject is not in the OSDCoreCache. OK."
        return
    }
    #=================================================
    # Ensure the cache entry points to a real file before we hash or copy.
    if (-not (Test-Path -LiteralPath $CacheWindowsESD.FullName)) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached source file not found: $($CacheWindowsESD.FullName)"
        return
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - $($CacheWindowsESD.FullName)"
    #=================================================
    # Validate the cached source against Microsoft metadata first.
    # This prevents copying a stale or tampered cache file.
    if ($OperatingSystemObject.SHA1) {
        # Validate cached payload before copy so we never replicate bad content.
        $SourceFileHash = Get-FileHash -Path $CacheWindowsESD.FullName -Algorithm SHA1
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - Microsoft Verified ESD SHA1: $($OperatingSystemObject.SHA1)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - OSDCoreCache SHA1: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] - SHA1 hash mismatch for cached source file: $($CacheWindowsESD.FullName)"
            return
        }
    }
    if ($OperatingSystemObject.SHA256) {
        # Same source validation path for newer metadata that provides SHA256.
        $SourceFileHash = Get-FileHash -Path $CacheWindowsESD.FullName -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - Microsoft Verified ESD SHA256: $($OperatingSystemObject.SHA256)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - OSDCoreCache SHA256: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] - SHA256 hash mismatch for cached source file: $($CacheWindowsESD.FullName)"
            return
        }
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - OperatingSystemObject is available in the OSDCoreCache. OK."
    $global:RecastOSDeploy.ConfirmWindowsESDOffline = $true
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
