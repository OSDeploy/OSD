function Step-OSDCloudWindowsESDDownload {
    [CmdletBinding()]
    param (
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
    # Is there a Url?
    if (-not ($OperatingSystemObject.Url)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject does not have a Url"
    }
    #=================================================
    # Is the Url reachable?
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
    # Create Download Directory
    $DownloadPath = "C:\OSDCloud\OS"
    $ItemParams = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        ItemType    = 'Directory'
        Path        = $DownloadPath
    }
    if (!(Test-Path $ItemParams.Path -ErrorAction SilentlyContinue)) {
        New-Item @ItemParams | Out-Null
    }
    #=================================================
    # Is there a USB drive available?
    $USBDrive = $null
    if ($OSDCoreDevice.USBVolumes) {
        $USBDrive = $OSDCoreDevice.USBVolumes | Where-Object { ($_.FileSystemLabel -match "OSDCloud|USB-DATA") } | `
                    Where-Object { $_.SizeGB -ge 16 } | Where-Object { $_.SizeRemainingGB -ge 10 } | Select-Object -First 1
    }

    if ($USBDrive) {
        $USBDownloadPath = "$($USBDrive.DriveLetter):\OSDCloud\OS\$($OperatingSystemObject.OperatingSystem)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DownloadPath: $USBDownloadPath"

        if (-not (Test-Path $USBDownloadPath)) {
            $null = New-Item -Path $USBDownloadPath -ItemType Directory -Force
        }
        $SaveWebFile = Invoke-OSDCloudDownloadFile -SourceUrl $OperatingSystemObject.FilePath -DestinationDirectory "$USBDownloadPath" -DestinationName $FileName

        if ($SaveWebFile) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copy Offline OS to $DownloadPath"
            $null = Copy-Item -Path $SaveWebFile.FullName -Destination $DownloadPath -Force
            $FileInfo = Get-Item "$DownloadPath\$($SaveWebFile.Name)"
        }
    }
    else {
        # $SaveWebFile is a FileInfo Object, not a path
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DownloadPath: $DownloadPath"
        $SaveWebFile = Invoke-OSDCloudDownloadFile -SourceUrl $OperatingSystemObject.FilePath -DestinationDirectory $DownloadPath -ErrorAction Stop
        $FileInfo = $SaveWebFile
    }
    #=================================================
    # Do we have FileInfo for the downloaded file?
    if (-not ($FileInfo)) {
        Write-Warning "[$(Get-Date -format s)] Unable to download the WindowsImage from the Internet."
        Write-Warning 'Press Ctrl+C to exit OSDCloud'
        Start-Sleep -Seconds 86400
        exit
    }
    #=================================================
    # Store this as a FileInfo Object
    $global:OSDCloudWorkflowInvoke.FileInfoWindowsImage = $FileInfo
    $global:OSDCloudWorkflowInvoke.WindowsImagePath = $global:OSDCloudWorkflowInvoke.FileInfoWindowsImage.FullName
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] WindowsImagePath:  $($global:OSDCloudWorkflowInvoke.WindowsImagePath)"
    #=================================================
    # Check the File Hash
    if ($OperatingSystemObject.Sha1) {
        $FileHash = (Get-FileHash -Path $FileInfo.FullName -Algorithm SHA1).Hash
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA1: $($OperatingSystemObject.Sha1)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA1: $FileHash"

        if ($OperatingSystemObject.Sha1 -notmatch $FileHash) {
            Write-Warning "[$(Get-Date -format s)] Unable to deploy this Operating System."
            Write-Warning "[$(Get-Date -format s)] Downloaded ESD SHA1 does not match the verified Microsoft ESD SHA1."
            Write-Warning 'Press Ctrl+C to exit OSDCloud'
            Start-Sleep -Seconds 86400
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA1 matches the verified Microsoft ESD SHA1. OK."
        }
    }
    if ($OperatingSystemObject.Sha256) {
        $FileHash = (Get-FileHash -Path $FileInfo.FullName -Algorithm SHA256).Hash
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Microsoft Verified ESD SHA256: $($OperatingSystemObject.Sha256)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloaded ESD SHA256: $FileHash"

        if ($OperatingSystemObject.Sha256 -notmatch $FileHash) {
            Write-Warning "[$(Get-Date -format s)] Unable to deploy this Operating System."
            Write-Warning "[$(Get-Date -format s)] Downloaded ESD SHA256 does not match the verified Microsoft ESD SHA256."
            Write-Warning 'Press Ctrl+C to exit OSDCloud'
            Start-Sleep -Seconds 86400
        }
        else {
            Write-Host -ForegroundColor Green "[$(Get-Date -format s)] Downloaded ESD SHA256 matches the verified Microsoft ESD SHA256. OK."
        }
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
