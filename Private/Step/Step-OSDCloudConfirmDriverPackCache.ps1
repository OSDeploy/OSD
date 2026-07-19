function Step-OSDCloudConfirmDriverPackCache {
    <#
    .SYNOPSIS
    Confirms the selected driver pack is available in OSDCore cache storage.

    .DESCRIPTION
    Validates driver pack selection inputs, refreshes cache inventory, and checks for an exact
    cached file match outside the system drive. When hash metadata is available, it verifies the
    cached source integrity before marking offline driver pack confirmation as successful.

    .PARAMETER DriverPackObject
    Driver pack metadata object used to locate and validate the cached package file.

    .EXAMPLE
    Step-OSDCloudConfirmDriverPackCache
    Uses the global driver pack object to validate that the selected package exists and passes hash
    checks in OSDCore cache.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $DriverPackObject = $global:OSDCoreDriverPackObject
    )
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Is there a DriverPack Object?
    if (-not ($DriverPackObject)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DriverPackObject is not set"
        return
    }
    #=================================================
    # Is there a DriverPack Object FileName?
    if (-not $DriverPackObject.FileName) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DriverPackObject.FileName is not set"
        return
    }
    #=================================================
    # Refresh cache inventory so we work with current cache state.
    # Cache can be updated by earlier steps, so do not rely on stale global data.
    $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
    if (-not $global:OSDCoreCacheContent) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreCacheContent is empty"
        return
    }
    #=================================================
    # Match the exact filename requested by the selected DriverPack metadata.
    # First match is intentional because filenames should be unique in cache.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] FileName: $($DriverPackObject.FileName)"
    $CacheDriverPack = $global:OSDCoreCacheContent | Where-Object { $_.Name -eq $DriverPackObject.FileName } | Where-Object { $_.DriveRoot -ne 'C:\' } | Select-Object -First 1
    #=================================================
    # Stop quietly when the requested payload is not cached.
    if (-not $CacheDriverPack) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject is not in the OSDCoreCacheContent. OK."
        return
    }
    #=================================================
    # Ensure the cache entry points to a real file before we hash or copy.
    if (-not (Test-Path -LiteralPath $CacheDriverPack.FullName)) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached source file not found: $($CacheDriverPack.FullName)"
        return
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] FullName: $($CacheDriverPack.FullName)"
    #=================================================
    # Validate the cached source against metadata first.
    # This prevents copying a stale or tampered cache file.
    if ($DriverPackObject.HashMD5) {
        # Validate cached payload before copy so we never replicate bad content.
        $SourceFileHash = Get-FileHash -Path $CacheDriverPack.FullName -Algorithm MD5
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack MD5: $($DriverPackObject.HashMD5)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent MD5: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $DriverPackObject.HashMD5) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OSDCoreCacheContent MD5 is not valid: $($CacheDriverPack.FullName)"
            return
        }
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject is in OSDCoreCacheContent. OK."
    $global:RecastOSDeploy.ConfirmDriverPackOffline = $true
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
