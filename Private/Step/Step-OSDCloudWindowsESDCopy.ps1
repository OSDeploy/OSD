function Step-OSDCloudWindowsESDCopy {
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

    .EXAMPLE
    Step-OSDCloudWindowsESDCopy
    Uses the global OSDCore operating system object and copies the matching cached
    ESD into C:\OSDCloud\OS when required.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Refined cache copy validation, path handling, and logging
    2026-07-16 - Added cached source hash validation and removed hash retry behavior
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject
    )
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    # Is there an OperatingSystem Object?
    if (-not ($OperatingSystemObject)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject is not set"
    }

    if (-not $OperatingSystemObject.FileName) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject.FileName is not set"
    }
    #=================================================
    # Destination settings
    $DownloadPath = 'C:\OSDCloud\OS'
    $LocalDestinationPath = Join-Path -Path $DownloadPath -ChildPath $OperatingSystemObject.FileName
    #=================================================
    # Does the destination already exist?
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination already exists: $LocalDestinationPath"
        return
    }
    #=================================================
    # Update OSDCoreCache
    $global:OSDCoreCache = Get-OSDCoreCache
    if (-not $global:OSDCoreCache) {
        Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreCache is empty"
        return
    }
    $CacheESD = $global:OSDCoreCache | Where-Object { $_.Name -eq $OperatingSystemObject.FileName } | Select-Object -First 1
    #=================================================
    # Is there a copy in the OSDCoreCache
    if (-not $CacheESD) {
        Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No cache match found for $($OperatingSystemObject.FileName)"
        return
    }

    if (-not (Test-Path -LiteralPath $CacheESD.FullName)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached source file not found: $($CacheESD.FullName)"
    }

    # Validate source hash before copy to ensure the cached ESD is trusted.
    if ($OperatingSystemObject.SHA1) {
        $SourceFileHash = Get-FileHash -Path $CacheESD.FullName -Algorithm SHA1
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA1: $($OperatingSystemObject.SHA1)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached source ESD SHA1: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA1 hash mismatch for cached source file: $($CacheESD.FullName)"
            return
        }
    }
    elseif ($OperatingSystemObject.SHA256) {
        $SourceFileHash = Get-FileHash -Path $CacheESD.FullName -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA256: $($OperatingSystemObject.SHA256)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached source ESD SHA256: $($SourceFileHash.Hash)"
        if ($SourceFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA256 hash mismatch for cached source file: $($CacheESD.FullName)"
            return
        }
    }
    #=================================================
    # Create destination directory if needed
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
    # Copy the cached ESD to the destination if it exists
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCache: $($CacheESD.FullName)"

    $DestinationFile = $null
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
    }

    if ($DestinationFile -and $DestinationFile.Length -eq $CacheESD.Length) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached file already exists at destination with matching size"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying $($CacheESD.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $LocalDestinationPath"
        try {
            $null = Copy-Item -LiteralPath $CacheESD.FullName -Destination $LocalDestinationPath -Force -ErrorAction Stop
        }
        catch {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to copy cached ESD from $($CacheESD.FullName) to $LocalDestinationPath. $($_.Exception.Message)"
        }
    }
    #=================================================
    # Test the file exists and return FileInfo object
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination file exists: $($DestinationFile.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Size: $($DestinationFile.Length) bytes"
    }
    else {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Destination file does not exist after copy: $LocalDestinationPath"
    }
    #=================================================
    # OperatingSystemObject will have either an SHA1 or SHA256 hash. Validate destination hash after copy.
    if ($OperatingSystemObject.SHA1) {
        $DestinationFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA1
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA1: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA1 hash mismatch for destination file: $LocalDestinationPath"
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA1 matches the verified Microsoft ESD SHA1. OK."
        }
    }
    elseif ($OperatingSystemObject.SHA256) {
        $DestinationFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA256: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA256 hash mismatch for destination file: $LocalDestinationPath"
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA256 matches the verified Microsoft ESD SHA256. OK."
        }
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
