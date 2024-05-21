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

