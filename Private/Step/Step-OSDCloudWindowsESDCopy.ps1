function Step-OSDCloudWindowsESDCopy {
    <#
    .SYNOPSIS
    Copies the selected Windows ESD from OSDCore cache to C:\OSDCloud\OS.

    .DESCRIPTION
    Validates the current operating system selection, checks for a matching file in
    the OSDCore cache, ensures the destination directory exists, and copies the ESD
    when needed. If a destination file already exists with the same size, the copy
    is skipped.

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
    $CacheDestinationPath = Join-Path -Path $DownloadPath -ChildPath $OperatingSystemObject.FileName
    #=================================================
    # Does the destination already exist?
    if (Test-Path -LiteralPath $CacheDestinationPath) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination already exists: $CacheDestinationPath"
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
    if (Test-Path -LiteralPath $CacheDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $CacheDestinationPath -ErrorAction SilentlyContinue
    }

    if ($DestinationFile -and $DestinationFile.Length -eq $CacheESD.Length) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached file already exists at destination with matching size"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying $($CacheESD.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $CacheDestinationPath"
        try {
            $null = Copy-Item -LiteralPath $CacheESD.FullName -Destination $CacheDestinationPath -Force -ErrorAction Stop
        }
        catch {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to copy cached ESD from $($CacheESD.FullName) to $CacheDestinationPath. $($_.Exception.Message)"
        }
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
