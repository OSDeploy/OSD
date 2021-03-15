function Save-MyDellDriverCab {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DownloadPath,
        [string]$Expand
    )
    #===================================================================================================
    #   Require Dell Computer
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -ne 'Dell') {
        Write-Warning "Dell computer is required for this function"
        Break
    }
    #===================================================================================================
    #   Get-MyDellDriverCab
    #===================================================================================================
    $GetMyDellDriverCab = Get-MyDellDriverCab | Select-Object LastUpdate,DriverName,Make,Generation,Model,SystemSku,DriverVersion,DriverReleaseId,OSVersion,OSArch,DownloadFile,SizeMB,DriverUrl,DriverInfo,Hash

    if ($GetMyDellDriverCab) {
        $GetMyDellDriverCab

        $DriverName = $GetMyDellDriverCab.DriverName
        $DownloadFile = $GetMyDellDriverCab.DownloadFile
        $SizeMB = $GetMyDellDriverCab.SizeMB
        $DriverUrl = $GetMyDellDriverCab.DriverUrl
        $Hash = $GetMyDellDriverCab.Hash

        $Source = $DriverUrl
        $Destination = 'C:\Drivers'
        $OutFile = Join-Path $Destination $DownloadFile

        if (-NOT (Test-Path "$Destination")) {
            New-Item $Destination -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Host "Source: $Source" -ForegroundColor Cyan
        Write-Host "Destination: $Destination" -ForegroundColor Cyan
        Write-Host "OutFile: $OutFile" -ForegroundColor Cyan
        Write-Host "Be patient ... this is a $SizeMB MB file" -ForegroundColor Cyan
        #===================================================================================================
        #   Download Driver CAB
        #===================================================================================================
        if (Get-Command 'curl.exe') {
            if (-NOT (Test-Path $OutFile)) {
                Write-Host "Downloading using cURL" -ForegroundColor Cyan
                & curl.exe --location --output "$OutFile" --progress-bar --url $Source
            }
        } else {
            Write-Warning "If you had cURL, this download would be much faster ..."
        }
        if (-NOT (Test-Path $OutFile)) {
            Write-Host "Downloading using BITS" -ForegroundColor Cyan
            Save-OSDDownload -BitsTransfer -SourceUrl $Source -DownloadFolder $Destination -ErrorAction SilentlyContinue | Out-Null
        }
        if (-NOT (Test-Path $OutFile)) {
            Write-Host "Downloading using WebClient" -ForegroundColor Cyan
            Save-OSDDownload -SourceUrl $Source -DownloadFolder $Destination -ErrorAction SilentlyContinue | Out-Null
        }
        
        if (Test-Path $OutFile) {
            $MyDellDriverFile = Get-Item $OutFile
            $ExpandPath = Join-Path $Destination $DriverName

            if (-NOT (Test-Path "$ExpandPath")) {
                New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
    
            Write-Host "Expanding $DownloadFile to $ExpandPath" -ForegroundColor Cyan
            Expand -R "$($MyDellDriverFile.FullName)" -F:* "$ExpandPath" | Out-Null
            Return (Get-Item $ExpandPath).FullName
        } else {
            Write-Warning "Unable to download the Driver Cab"
            Return $null
        }

    }
}