function Step-OSDCloudConfirmDriverPackOffline {
    <#
    .SYNOPSIS
    Confirms the selected driver pack is available in OSDCore cache storage.

    .DESCRIPTION
    Validates driver pack selection inputs, refreshes cache inventory, and checks for an exact
    cached file match outside the system drive. When hash metadata is available, it verifies the
    cached source integrity before marking offline driver pack confirmation as successful.

    .PARAMETER DriverPackName
    Name of the selected driver pack. Values such as None and Microsoft Update Catalog are treated
    as no offline package requirement.

    .PARAMETER DriverPackObject
    Driver pack metadata object used to locate and validate the cached package file.

    .EXAMPLE
    Step-OSDCloudConfirmDriverPackOffline
    Uses the global driver pack object to validate that the selected package exists and passes hash
    checks in OSDCore cache.

    .EXAMPLE
    Step-OSDCloudConfirmDriverPackOffline -DriverPackName $global:OSDCoreDriverPackObject.Name -DriverPackObject $global:OSDCoreDriverPackObject
    Validates a provided driver pack selection against cached package content.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param (
        [System.String]
        $DriverPackName = $global:OSDCoreDriverPackObject.Name,

        $DriverPackObject = $global:OSDCoreDriverPackObject
    )
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm DriverPackObject Offline:"
    #=================================================
    # Is there a DriverPack Object?
    if (-not ($DriverPackObject)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackObject is not set. OK."
        return
    }
    #=================================================
    # Is DriverPackName set to None?
    if ($DriverPackName -eq 'None') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackName is set to None. OK."
        return
    }
    #=================================================
    # Is DriverPackName set to Microsoft Update Catalog?
    if ($DriverPackName -eq 'Microsoft Update Catalog') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackName is set to Microsoft Update Catalog. OK."
        return
    }
    #=================================================
    # Is there a DriverPack Object FileName?
    if (-not $DriverPackObject.FileName) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackObject.FileName is not set"
        return
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
    # Match the exact filename requested by the selected DriverPack metadata.
    # First match is intentional because filenames should be unique in cache.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - $($DriverPackObject.FileName)"
    $CacheDriverPack = $global:OSDCoreCache | Where-Object { $_.Name -eq $DriverPackObject.FileName } | Where-Object { $_.DriveRoot -ne 'C:\' } | Select-Object -First 1
    #=================================================
    # Stop quietly when the requested payload is not cached.
    if (-not $CacheDriverPack) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackObject is not in the OSDCoreCache. OK."
        return
    }
    #=================================================
    # Ensure the cache entry points to a real file before we hash or copy.
    if (-not (Test-Path -LiteralPath $CacheDriverPack.FullName)) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached source file not found: $($CacheDriverPack.FullName)"
        return
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - $($CacheDriverPack.FullName)"
    #=================================================
    # Validate the cached source against metadata first.
    # This prevents copying a stale or tampered cache file.
    if ($DriverPackObject.HashMD5) {
        # Validate cached payload before copy so we never replicate bad content.
        $SourceFileHash = Get-FileHash -Path $CacheDriverPack.FullName -Algorithm MD5
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - Microsoft Verified DriverPack MD5: $($DriverPackObject.HashMD5)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - OSDCoreCache MD5: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $DriverPackObject.HashMD5) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] - MD5 hash mismatch for cached source file: $($CacheDriverPack.FullName)"
            return
        }
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] - DriverPackObject is available in the OSDCoreCache. OK."
    $global:RecastOSDeploy.ConfirmDriverPackOffline = $true
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
