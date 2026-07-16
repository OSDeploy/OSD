function Step-OSDCloudSaveWindowsESD {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject,

        [Parameter()]
        [ValidateRange(0, 1)]
        [int]$HashRetryCount = 0
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
    # Destination settings for the local deployment workspace.
    # This is the final on-disk path expected by downstream deployment steps.
    $DownloadPath = 'C:\OSDCloud\OS'
    $LocalDestinationPath = Join-Path -Path $DownloadPath -ChildPath $OperatingSystemObject.FileName
    #=================================================
    # Does the destination already exist? If so, validate hash before returning.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination already exists: $LocalDestinationPath"

        # Track whether existing content is reusable or must be removed/re-downloaded.
        $HashMismatch = $false
        if ($OperatingSystemObject.SHA1) {
            # Legacy metadata path: compare destination hash to Microsoft-published SHA1.
            $ExistingFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA1
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Existing ESD SHA1: $($ExistingFileHash.Hash)"
            if ($ExistingFileHash.Hash -ne $OperatingSystemObject.SHA1) {
                $HashMismatch = $true
            }
            else {
                Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Existing ESD SHA1 matches the verified Microsoft ESD SHA1. OK."
            }
        }
        elseif ($OperatingSystemObject.SHA256) {
            # Preferred metadata path: compare destination hash to Microsoft SHA256.
            $ExistingFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA256
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Existing ESD SHA256: $($ExistingFileHash.Hash)"
            if ($ExistingFileHash.Hash -ne $OperatingSystemObject.SHA256) {
                $HashMismatch = $true
            }
            else {
                Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Existing ESD SHA256 matches the verified Microsoft ESD SHA256. OK."
            }
        }

        if ($HashMismatch) {
            # Remove bad content before retry so the next attempt starts clean.
            try {
                Remove-Item -LiteralPath $LocalDestinationPath -Force -ErrorAction Stop
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Existing file hash mismatch. Removed: $LocalDestinationPath"
            }
            catch {
                throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to remove hash-mismatched destination file: $LocalDestinationPath. $($_.Exception.Message)"
            }

            if ($HashRetryCount -lt 1) {
                # Single retry guard prevents unbounded recursion on persistent failures.
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Retrying download after removing hash-mismatched file"
                Step-OSDCloudSaveWindowsESD -OperatingSystemObject $OperatingSystemObject -HashRetryCount ($HashRetryCount + 1)
                return
            }

            # If retry already occurred, fail fast so caller can decide next action.
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Hash mismatch persists after retry for destination file: $LocalDestinationPath"
        }

        return
    }
    #=================================================
    # Is there a Url?
    if (-not ($OperatingSystemObject.Url)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject does not have a Url"
    }
    #=================================================
    # Is the Url reachable?
    # Use a one-byte ranged GET as a lightweight reachability/content check.
    $OnlineCheckUri = if ($OperatingSystemObject.Url) { $OperatingSystemObject.Url } else { $OperatingSystemObject.FilePath }

    if ($OnlineCheckUri) {
        try {
            $WebRequest = Invoke-WebRequest -Uri $OnlineCheckUri -UseBasicParsing -Method Get -Headers @{ Range = 'bytes=0-0' } -ErrorAction Stop
            if ($WebRequest.StatusCode -in 200, 206) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreOperatingSystemObject URI is reachable (GET $($WebRequest.StatusCode)). OK."
            }
        }
        catch {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject URI is not reachable."
        }
    }
    else {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject URI is not set."
    }
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
    # Is there a USB drive available to cache?
    # Prefer removable media cache when available to reduce repeated WAN downloads.
    $USBDrive = $null
    if ($OSDCoreDevice.USBVolumes) {
        $USBDrive = $OSDCoreDevice.USBVolumes | Where-Object { ($_.FileSystemLabel -match "OSDCloud|USB-DATA") } | `
                    Where-Object { $_.SizeGB -ge 16 } | Where-Object { $_.SizeRemainingGB -ge 10 } | Select-Object -First 1
    }

    if ($USBDrive) {
        # USB path groups content by operating system family for reuse.
        $USBDownloadPath = "$($USBDrive.DriveLetter):\OSDCloud\OS\$($OperatingSystemObject.OperatingSystem)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DownloadPath: $USBDownloadPath"

        if (-not (Test-Path -LiteralPath $USBDownloadPath -ErrorAction SilentlyContinue)) {
            $null = New-Item -Path $USBDownloadPath -ItemType Directory -Force
        }
        # Download once to USB cache, then copy local for active deployment usage.
        $SaveWebFile = Invoke-OSDCoreDownloadFile -SourceUrl $OperatingSystemObject.Url -DestinationDirectory "$USBDownloadPath" -DestinationName $FileName

        if ($SaveWebFile) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copy Offline OS to $DownloadPath"
            $null = Copy-Item -Path $SaveWebFile.FullName -Destination $DownloadPath -Force
            $DestinationFile = Get-Item "$DownloadPath\$($SaveWebFile.Name)"
        }
    }
    else {
        # $SaveWebFile is a DestinationFile Object, not a path
        # Direct-to-local fallback when no suitable USB cache is present.
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DownloadPath: $DownloadPath"
        $SaveWebFile = Invoke-OSDCoreDownloadFile -SourceUrl $OperatingSystemObject.Url -DestinationDirectory $DownloadPath -ErrorAction Stop
        $DestinationFile = $SaveWebFile
    }
    #=================================================
    # Confirm destination exists and cache file info for downstream workflow.
    if (-not ($DestinationFile)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to download the WindowsImage from the Url"
    }
    # Re-reading FileInfo ensures size/path metadata reflects the actual destination.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination file exists: $($DestinationFile.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Size: $($DestinationFile.Length) bytes"
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
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA1: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA1) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA1 hash mismatch for destination file: $LocalDestinationPath"
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA1 matches the verified Microsoft ESD SHA1. OK."
            # Persist verified destination for subsequent steps that consume this file.
            $global:OSDCloudDeploy.OperatingSystemItem = $DestinationFile
        }
    }
    if ($OperatingSystemObject.SHA256) {
        # SHA256 path mirrors SHA1 behavior for consistency across metadata versions.
        $DestinationFileHash = Get-FileHash -Path $LocalDestinationPath -Algorithm SHA256
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA256: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $OperatingSystemObject.SHA256) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SHA256 hash mismatch for destination file: $LocalDestinationPath"
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA256 matches the verified Microsoft ESD SHA256. OK."
            # Persist verified destination for subsequent steps that consume this file.
            $global:OSDCloudDeploy.OperatingSystemItem = $DestinationFile
        }
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
