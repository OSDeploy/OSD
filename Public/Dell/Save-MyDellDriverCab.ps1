function Save-MyDellDriverCab {
    [CmdletBinding()]
    param ()
    #===================================================================================================
    #   Require Dell Computer
    #===================================================================================================
    if (Get-MyComputerManufacturer -Brief -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Break
    }

    Write-Verbose "Save-MyDellDriverCab: This function is currently in development" -Verbose

    Write-Verbose "Save-MyDellDriverCab: Gathering information from Dell ... please wait" -Verbose
    $GetMyDellDriverCab = Get-MyDellDriverCab

    if ($GetMyDellDriverCab) {

        $GetMyDellDriverCab

        $DriverName = $GetMyDellDriverCab.DriverName
        $DriverVersion = $GetMyDellDriverCab.DriverVersion
        $DriverReleaseId = $GetMyDellDriverCab.DriverReleaseId
        $OsVersion = $GetMyDellDriverCab.OsVersion
        $OsArch = $GetMyDellDriverCab.OsArch
        $DownloadFile = $GetMyDellDriverCab.DownloadFile
        $SizeMB = $GetMyDellDriverCab.SizeMB
        $DriverUrl = $GetMyDellDriverCab.DriverUrl
        $DriverInfo = $GetMyDellDriverCab.DriverInfo
        $Hash = $GetMyDellDriverCab.Hash

        $OutFile = Join-Path 'C:\Drivers' $DownloadFile

        #Download the Driver
        if (-NOT (Test-Path $OutFile)) {
            Write-Verbose "Downloading using BITS $DriverUrl" -Verbose
            Write-Verbose "This will take a while to download this $SizeMB MB file" -Verbose
            Save-OSDDownload -BitsTransfer -SourceUrl $DriverUrl -DownloadFolder 'C:\Drivers' -ErrorAction SilentlyContinue | Out-Null
        }
        if (-NOT (Test-Path $OutFile)) {
            Write-Verbose "BITS didn't work ..."
            Write-Verbose "Downloading using WebClient $DriverUrl" -Verbose
            Write-Verbose "This will take a while to download this $SizeMB MB file" -Verbose
            Save-OSDDownload -SourceUrl $DriverUrl -DownloadFolder 'C:\Drivers' -ErrorAction SilentlyContinue | Out-Null
        }

        if (-NOT (Test-Path $OutFile)) {Write-Warning "Unable to download the Driver Cab"; Break}

        $MyDellDriverFile = Get-Item $OutFile
        $ExpandPath = Join-Path 'C:\Drivers' $DriverName
        if (-not (Test-Path "$ExpandPath")) {
            New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Verbose "Expanding $DownloadFile to $ExpandPath ... please wait" -Verbose
        Expand -R "$($MyDellDriverFile.FullName)" -F:* "$ExpandPath" | Out-Null
        Return (Get-Item $ExpandPath).FullName
    }
}