function Test-WindowsUpdateEnvironment {
    [CmdletBinding()]
    param (
        [int]$TimeoutSeconds = 30
    )

    # Check if network is available (max $TimeoutSeconds)
    $networkReady = $false
    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        if (Test-WebConnection -Uri 'www.microsoft.com') {
            $networkReady = $true
            break
        }
        Start-Sleep -Seconds 1
    }
    if (-not $networkReady) {
        Write-Warning "Network is not available after waiting. Skipping Windows Update."
        return $false
    }

    # Ensure Windows Update service is running (max $TimeoutSeconds)
    # This is important to avoid COMException 0x80240438 when calling Microsoft.Update.Session
    $serviceReady = $false
    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        $service = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -eq 'Running') {
                $serviceReady = $true
                break
            }
            elseif ($service.Status -eq 'Stopped') {
                try {
                    Start-Service -Name wuauserv -ErrorAction Stop
                    Write-Output "Windows Update service was stopped. Attempting to start it..."
                } catch {
                    Write-Warning "Failed to start Windows Update service: $($_.Exception.Message)"
                }
            }
        }
        Start-Sleep -Seconds 1
    }

    if (-not $serviceReady) {
        Write-Warning "Windows Update service is not running. Skipping Windows Update."
        return $false
    }

    return $true
}