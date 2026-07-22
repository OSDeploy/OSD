function Step-OSDCloudCopyOperatingSystemCacheObject {
    <#
    .SYNOPSIS
    Copies the selected Windows ESD from OSDCore cache to C:\OSDCloud\OS.

    .DESCRIPTION
    Validates the current operating system selection, checks for a matching file in
    the OSDCore cache, ensures the destination directory exists, and copies the ESD
    when needed. If a destination file already exists with the same size, the copy
    is skipped. The cached source file hash is validated before copy, and hash
    validation failures throw.

    .PARAMETER OperatingSystemObject
    Operating system metadata object that contains at least the FileName property.
    Defaults to the global OSDCore operating system object.

    .PARAMETER DownloadPath
    Destination directory where the ESD is copied.
    Defaults to C:\OSDCloud\OS.

    .EXAMPLE
    Step-OSDCloudCopyOperatingSystemCacheObject
    Uses the global OSDCore operating system object and copies the matching cached
    ESD into C:\OSDCloud\OS when required.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Refined cache copy validation, path handling, and logging
    2026-07-16 - Added cached source hash validation and removed hash retry behavior
    2026-07-16 - Promoted DownloadPath to a parameter with a default value
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject,

        [Parameter()]
        [string]$DownloadPath = 'C:\OSDCloud\OS'
    )
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Honor the upstream execution mode gate.
    # This step only runs when offline media usage has already been confirmed.
    # Returning here is expected behavior in online flows and is not an error.
    if (-not ($global:RecastOSDCloud.OperatingSystemCacheObject)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Windows ESD was not confirmed for offline usage. Skipping this step."
        return
    }
    #=================================================
    # Validate required OS metadata object before any file/cache operations.
    # Throwing here is intentional because downstream logic depends on this object.
    if (-not ($OperatingSystemObject)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OperatingSystemObject is not set"
    }
    #=================================================
    # Validate the filename key used to locate the exact cache entry.
    # Without FileName, cache matching and destination path construction are unsafe.
    if (-not $OperatingSystemObject.FileName) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OperatingSystemObject.FileName is not set"
    }
    #=================================================
    # Destination settings for the local deployment workspace.
    # This is the final on-disk path expected by downstream deployment steps.
    $LocalDestinationPath = Join-Path -Path $DownloadPath -ChildPath $OperatingSystemObject.FileName
    #=================================================
    # If the destination file already exists, this step is a no-op.
    # Downstream steps can still use the existing file.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination already exists: $LocalDestinationPath"
        # return
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
    # Match the exact filename requested by the selected OS metadata.
    # First match is intentional because filenames should be unique in cache.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($OperatingSystemObject.FileName)"
    $CacheWindowsESD = $global:OSDCoreCacheContent | Where-Object { $_.Name -eq $OperatingSystemObject.FileName } | Where-Object { $_.DriveRoot -ne 'C:\' } | Select-Object -First 1
    #=================================================
    # Stop quietly when the requested payload is not cached.
    if (-not $CacheWindowsESD) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystemObject is not in the OSDCoreCacheContent. OK."
        return
    }
    #=================================================
    # Ensure the cache entry points to a real file before we hash or copy.
    if (-not (Test-Path -LiteralPath $CacheWindowsESD.FullName)) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached source file not found: $($CacheWindowsESD.FullName)"
        return
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($CacheWindowsESD.FullName)"
    #=================================================
    # Validate the cached source against Microsoft metadata first.
    # This prevents copying a stale or tampered cache file.
    if ($OperatingSystemObject.SHA1) {
        # Validate cached payload before copy so we never replicate bad content.
        $SourceFileHash = Get-FileHash -Path $CacheWindowsESD.FullName -Algorithm SHA1
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA1: $($OperatingSystemObject.SHA1)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent SHA1: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] SHA1 hash mismatch for cached source file: $($CacheWindowsESD.FullName)"
            return
        }
    }
    if ($OperatingSystemObject.SHA256) {
        # Same source validation path for newer metadata that provides SHA256.
        $SourceFileHash = Get-FileHash -Path $CacheWindowsESD.FullName -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA256: $($OperatingSystemObject.SHA256)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent SHA256: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            # Hash mismatch means the source cannot be trusted; skip copy.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] SHA256 hash mismatch for cached source file: $($CacheWindowsESD.FullName)"
            return
        }
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystemObject is available in the OSDCoreCacheContent. OK."
    $global:RecastOSDCloud.OperatingSystemCacheObject = $true
    #=================================================
    # Create destination directory if needed
    # Directory creation is idempotent and safe to call repeatedly.
    $ItemParams = @{
        ErrorAction = 'Stop'
        Force       = $true
        ItemType    = 'Directory'
        Path        = $DownloadPath
    }
    if (-not (Test-Path -LiteralPath $ItemParams.Path -ErrorAction SilentlyContinue)) {
        New-Item @ItemParams | Out-Null
    }
    #=================================================
    # Log selected cache file for traceability.
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent: $($CacheWindowsESD.FullName)"

    $DestinationFile = $null
    # Re-check destination (defensive) in case another step created it.
    # This avoids unnecessary copy work in race conditions.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
    }

    # If destination exists and byte length matches cache, skip recopy.
    if ($DestinationFile -and $DestinationFile.Length -eq $CacheWindowsESD.Length) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached file already exists at destination with matching size"
    }
    else {
        # Copy with -Force so partial/older files are replaced atomically by Copy-Item.
        # Any copy failure is terminal for this step because no valid destination exists.
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying $($CacheWindowsESD.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying to $LocalDestinationPath"
        try {
            $null = Copy-Item -LiteralPath $CacheWindowsESD.FullName -Destination $LocalDestinationPath -Force -ErrorAction Stop
        }
        catch {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to copy cached ESD from $($CacheWindowsESD.FullName) to $LocalDestinationPath. $($_.Exception.Message)"
        }
    }
    #=================================================
    # Confirm destination exists and cache file info for downstream workflow.
    # Re-reading FileInfo ensures size/path metadata reflects the actual destination.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination file exists: $($DestinationFile.FullName)"
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Size: $($DestinationFile.Length) bytes"
    }
    else {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Destination file does not exist after copy: $LocalDestinationPath"
    }
    #=================================================
    # Final integrity check on the destination file.
    # Metadata includes either SHA1 or SHA256, never both.
    if ($OperatingSystemObject.SHA1) {
        # Destination hash is the final trust gate before deployment can continue.
        $DestinationFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA1
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copied SHA1: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            # On mismatch, remove the suspect destination and stop this step cleanly.
            # Later orchestration can decide whether/when to attempt another source.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] - SHA1 hash mismatch for destination file, deleting: $LocalDestinationPath"
            Remove-Item -LiteralPath $LocalDestinationPath -Force -ErrorAction SilentlyContinue
            return
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Copied SHA1 matches the verified Microsoft ESD SHA1. OK."
            # Persist verified destination for subsequent steps that consume this file.
            $global:RecastOSDCloud.OperatingSystemItem = $DestinationFile
            $global:RecastOSDCloud.OperatingSystemUrlTest = $false
        }
    }
    elseif ($OperatingSystemObject.SHA256) {
        # SHA256 path mirrors SHA1 behavior for consistency across metadata versions.
        $DestinationFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copied SHA256: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            # Remove failed output to prevent accidental reuse of a bad payload.
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] - SHA256 hash mismatch for destination file, deleting: $LocalDestinationPath"
            Remove-Item -LiteralPath $LocalDestinationPath -Force -ErrorAction SilentlyContinue
            return
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Copied SHA256 matches the verified Microsoft ESD SHA256. OK."
            # Persist verified destination for subsequent steps that consume this file.
            $global:RecastOSDCloud.OperatingSystemItem = $DestinationFile
            $global:RecastOSDCloud.OperatingSystemUrlTest = $false
        }
    }
    else {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OperatingSystemObject does not have SHA1 or SHA256 metadata to validate the cached source or copied destination"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
