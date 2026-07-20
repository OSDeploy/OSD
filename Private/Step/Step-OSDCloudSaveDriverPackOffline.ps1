function Step-OSDCloudSaveDriverPackOffline {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DriverPackObject = $global:OSDCoreDriverPackObject,

        [Parameter()]
        [string]$DownloadPath = 'C:\Windows\Temp\osdcloud-driverpack-download'
    )
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Honor the upstream execution mode gate.
    # This step only runs when offline media usage has already been confirmed.
    # Returning here is expected behavior in online flows and is not an error.
    if (-not ($global:RecastOSDeploy.CacheDriverPackObject)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DriverPackObject was not confirmed for offline usage. Skipping this step."
        return
    }
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
    # Destination settings for the local deployment workspace.
    # This is the final on-disk path expected by downstream deployment steps.
    $LocalDestinationPath = Join-Path -Path $DownloadPath -ChildPath $DriverPackObject.FileName
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
    $global:RecastOSDeploy.CacheDriverPackObject = $true
    #=================================================
    # Variables
    $LogPath = "C:\Windows\Temp\osdcloud-logs"
    $Manufacturer = $DriverPackObject.Manufacturer
    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $SetupCompleteCmd = "$ScriptsPath\SetupComplete.cmd"
    $SetupSpecializeCmd = "C:\Windows\Temp\osdcloud\SetupSpecialize.cmd"
    $Url = $DriverPackObject.Url
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
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCacheContent: $($CacheDriverPack.FullName)"
    $DestinationFile = $null
    # Re-check destination (defensive) in case another step created it.
    # This avoids unnecessary copy work in race conditions.
    if (Test-Path -LiteralPath $LocalDestinationPath) {
        $DestinationFile = Get-Item -LiteralPath $LocalDestinationPath -ErrorAction SilentlyContinue
    }

    # If destination exists and byte length matches cache, skip recopy.
    if ($DestinationFile -and $DestinationFile.Length -eq $CacheDriverPack.Length) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Cached file already exists at destination with matching size"
    }
    else {
        # Copy with -Force so partial/older files are replaced atomically by Copy-Item.
        # Any copy failure is terminal for this step because no valid destination exists.
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying $($CacheDriverPack.FullName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying to $LocalDestinationPath"
        try {
            $null = Copy-Item -LiteralPath $CacheDriverPack.FullName -Destination $LocalDestinationPath -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to copy cached ESD from $($CacheDriverPack.FullName) to $LocalDestinationPath. $($_.Exception.Message)"
            return
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
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Destination file does not exist after copy: $LocalDestinationPath"
        return
    }
    #=================================================
    # Verify Cache file hash matches metadata after copy to ensure integrity.
    if ($DriverPackObject.HashMD5) {
        $DestinationFileHash = Get-FileHash -Path $DestinationFile.FullName -Algorithm MD5
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination MD5: $($DestinationFileHash.Hash)"
        if ($DestinationFileHash.Hash -ne $DriverPackObject.HashMD5) {
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] - MD5 hash mismatch for destination file, deleting: $LocalDestinationPath"
            Remove-Item -LiteralPath $LocalDestinationPath -Force -ErrorAction SilentlyContinue
            return
        }
    }
    $global:RecastOSDeploy.DriverPackItem = $DestinationFile
    $global:RecastOSDeploy.TestDriverPackUrl = $false
    #=================================================
    # Store this as a FileInfo Object
    $DriverPackObject | ConvertTo-Json | Out-File "$($DestinationFile.FullName).json" -Encoding ascii -Width 2000 -Force
    #=================================================
    # Expand the DriverPack
    $DownloadedFile = $DestinationFile.FullName
    $ExpandPath = 'C:\Windows\Temp\osdcloud-driverpack-expand'
    if (-not (Test-Path "$ExpandPath")) {
        New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack: $DownloadedFile"
    #=================================================
    #   Cab
    #=================================================
    if ($DestinationFile.Extension -eq '.cab') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand CAB DriverPack to $ExpandPath"
        Expand -R "$DownloadedFile" -F:* "$ExpandPath" | Out-Null

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Apply drivers in $ExpandPath"

        if ($env:SystemDrive -eq 'X:') {
            Add-WindowsDriver -Path "C:\" -Driver $ExpandPath -Recurse -ForceUnsigned -LogPath "$LogPath\dism-add-windowsdriver-driverpack.log" -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Windows\Temp\osdcloud-driverpack-download"
        Remove-Item -Path "C:\Windows\Temp\osdcloud-driverpack-download" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing $ExpandPath"
        Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Drivers"
        Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    #=================================================
    #   Zip
    #=================================================
    if ($DestinationFile.Extension -eq '.zip') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand ZIP DriverPack to $ExpandPath"
        Expand-Archive -Path $DownloadedFile -DestinationPath $ExpandPath -Force

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Apply drivers in $ExpandPath"
        if ($env:SystemDrive -eq 'X:') {
            Add-WindowsDriver -Path "C:\" -Driver $ExpandPath -Recurse -ForceUnsigned -LogPath "$LogPath\dism-add-windowsdriver-driverpack.log" -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Windows\Temp\osdcloud-driverpack-download"
        Remove-Item -Path "C:\Windows\Temp\osdcloud-driverpack-download" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing $ExpandPath"
        Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Drivers"
        Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    #=================================================
    #   Dell
    #=================================================
    if (($DestinationFile.Extension -eq '.exe') -and ($DestinationFile.VersionInfo.FileDescription -match 'Dell')) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] FileDescription: $($DestinationFile.VersionInfo.FileDescription)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] ProductVersion: $($DestinationFile.VersionInfo.ProductVersion)"

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand Dell DriverPack to $ExpandPath"
        $null = New-Item -Path $ExpandPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        Start-Process -FilePath $DownloadedFile -ArgumentList "/s /e=`"$ExpandPath`"" -Wait

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Apply drivers in $ExpandPath"
        if ($env:SystemDrive -eq 'X:') {
            Add-WindowsDriver -Path "C:\" -Driver $ExpandPath -Recurse -ForceUnsigned -LogPath "$LogPath\dism-add-windowsdriver-driverpack.log" -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Windows\Temp\osdcloud-driverpack-download"
        Remove-Item -Path "C:\Windows\Temp\osdcloud-driverpack-download" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing $ExpandPath"
        Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Drivers"
        Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    #=================================================
    #   HP
    #=================================================
    if (($DestinationFile.Extension -eq '.exe') -and ($DestinationFile.VersionInfo.InternalName -match 'hpsoftpaqwrapper')) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] FileDescription: $($DestinationFile.VersionInfo.FileDescription)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] InternalName: $($DestinationFile.VersionInfo.InternalName)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] ProductVersion: $($DestinationFile.VersionInfo.ProductVersion)"

        if (Test-Path -Path $env:windir\System32\7za.exe) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand HP DriverPack to $ExpandPath"
            # Start-Process -FilePath $DownloadedFile -ArgumentList "/s /e /f `"$ExpandPath`"" -Wait
            & 7za x "$DownloadedFile" -o"C:\Windows\Temp\osdcloud-driverpack-expand"

            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Apply drivers in $ExpandPath"
            if ($env:SystemDrive -eq 'X:') {
                Add-WindowsDriver -Path "C:\" -Driver $ExpandPath -Recurse -ForceUnsigned -LogPath "$LogPath\dism-add-windowsdriver-driverpack.log" -ErrorAction SilentlyContinue | Out-Null
            }

            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Windows\Temp\osdcloud-driverpack-download"
            Remove-Item -Path "C:\Windows\Temp\osdcloud-driverpack-download" -Recurse -Force -ErrorAction SilentlyContinue

            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing $ExpandPath"
            Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue

            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\Drivers"
            Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Warning "[$(Get-Date -format s)] 7zip 7za.exe needs to be added to WinPE to expand HP DriverPacks"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] HP DriverPack is saved at $DownloadedFile"

            Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        }
        return
    }
    #=================================================
    #   Lenovo
    #=================================================
    if (($DestinationFile.Extension -eq '.exe') -and ($DriverPackObject.Manufacturer -match 'Lenovo')) {
        if (-not (Test-Path $ScriptsPath)) {
            New-Item -Path $ScriptsPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Adding Lenovo DriverPack to $SetupCompleteCmd"

$Content = @"
:: ========================================================
:: OSDCloud DriverPack Installation for Lenovo
:: ========================================================
$DownloadedFile /SILENT /SUPPRESSMSGBOXES
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" /v Path /t REG_SZ /d "C:\Drivers" /f
pnpunattend.exe AuditSystem /L
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" /v Path /f
rd /s /q C:\Drivers
rd /s /q C:\Windows\Temp\osdcloud-driverpack-download
:: ========================================================
"@
        $Content | Out-File -FilePath $SetupCompleteCmd -Append -Encoding ascii -Width 2000 -Force
        Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    #=================================================
    #   Surface
    #=================================================
    if (($DestinationFile.Extension -eq '.msi') -and ($DestinationFile.Name -match 'surface')) {
        if (-not (Test-Path $ScriptsPath)) {
            New-Item -Path $ScriptsPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Adding Surface DriverPack to $SetupCompleteCmd"

$Content = @"
:: ========================================================
:: OSDCloud DriverPack Installation for Microsoft Surface
:: ========================================================
msiexec /i $DownloadedFile /qn /norestart /l*v C:\Windows\Temp\osdcloud-logs\drivers-driverpack-microsoft.log
rd /s /q C:\Windows\Temp\osdcloud-driverpack-download
:: ========================================================
"@
        $Content | Out-File -FilePath $SetupCompleteCmd -Append -Encoding ascii -Width 2000 -Force
        Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
