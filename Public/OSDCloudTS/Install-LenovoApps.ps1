function Install-LenovoSystemUpdater {
    # Define the URL and temporary file path
    $url = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.02.25.exe"
    $tempFilePath = "C:\Windows\Temp\system_update.exe"

    # Create a new BITS transfer job
    $bitsJob = Start-BitsTransfer -Source $url -Destination $tempFilePath

    # Wait for the BITS transfer job to complete
    while ($bitsJob.JobState -eq "Transferring") {
        Start-Sleep -Seconds 2
    }

    # Check if the transfer was successful
    if (Test-Path -Path $tempFilePath) {
        # Start the installation process
        Write-Host -ForegroundColor Green "Installation file downloaded successfully. Starting installation..."
        $ArgumentList = "/VERYSILENT /NORESTART"
        $InstallProcess = Start-Process -FilePath $tempFilePath -ArgumentList $ArgumentList -Wait -PassThru
        if ($InstallProcess.ExitCode -eq 0) {
            Write-Host -ForegroundColor Green "Installation completed successfully."
        } else {
            Write-Host -ForegroundColor Red "Installation failed with exit code $($InstallProcess.ExitCode)."
        }
    } else {
        Write-Host "Failed to download the file."
    }
}

function Invoke-LenovoSystemUpdater
{
    # Check if Lenovo System Updater is already installed
    if (Test-Path "C:\Program Files (x86)\Lenovo\System Update\TVSU.exe") {
        Write-Host "Lenovo System Updater is already installed."
    } else {
        Write-Host "Lenovo System Updater is not installed. Installing..."
        Install-LenovoSystemUpdater
    }
    $ArgList = '/CM -search A -action INSTALL -includerebootpackages 3 -nolicense -exporttowmi -noreboot -noicon'
    $Updater = Start-Process -FilePath "C:\Program Files (x86)\Lenovo\System Update\TVSU.exe" -ArgumentList $ArgList  -Wait -PassThru

    if ($Updater.ExitCode -eq 0) {
        Write-Host -ForegroundColor Green "Lenovo System Updater completed successfully."
    } else {
        Write-Host -ForegroundColor Red "Lenovo System Updater failed with exit code $($Updater.ExitCode)."
    }
}

function Install-LenovoVantage {
    # Define the URL and temporary file path
    $url = "https://download.lenovo.com/pccbbs/thinkvantage_en/metroapps/Vantage/LenovoCommercialVantage_10.2401.29.0.zip"
    $tempFilePath = "C:\Windows\Temp\lenovo_vantage.exe"
    $tempExtractPath = "C:\Windows\Temp\LenovoVantage"
    # Create a new BITS transfer job
    $bitsJob = Start-BitsTransfer -Source $url -Destination $tempFilePath

    # Wait for the BITS transfer job to complete
    while ($bitsJob.JobState -eq "Transferring") {
        Start-Sleep -Seconds 2
    }

    # Check if the transfer was successful
    if (Test-Path -Path $tempFilePath) {
        # Start the installation process
        Write-Host -ForegroundColor Green "Installation file downloaded successfully. Starting installation..."
        Expand-Archive -Path $tempFilePath -Destination $tempExtractPath

    } else {
        Write-Host "Failed to download the file."
    }
    #Lenovo System Interface Foundation (LSIF)
    if (Test-Path -Path "$tempExtractPath\System-Interface-Foundation-Update-64.exe"){
        $ArgumentList = "/VERYSILENT /NORESTART"
        $InstallProcess = Start-Process -FilePath "$tempExtractPath\System-Interface-Foundation-Update-64.exe" -ArgumentList $ArgumentList -Wait -PassThru
        if ($InstallProcess.ExitCode -eq 0) {
            Write-Host -ForegroundColor Green "Installation completed successfully."
        } else {
            Write-Host -ForegroundColor Red "Installation failed with exit code $($InstallProcess.ExitCode)."
        }
    } else {
        Write-Host "Failed to find $tempExtractPath\System-Interface-Foundation-Update-64.exe"
    }
    #Lenovo Vantage Service
    Invoke-Expression -command "$tempExtractPath\VantageService\Install-VantageService.ps1"
}