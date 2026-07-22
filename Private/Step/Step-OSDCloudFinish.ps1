function Step-OSDCloudFinish {
    <#
    .SYNOPSIS
    Finalizes an OSDCloud deployment and performs the configured post-deployment action.

    .DESCRIPTION
    Records the deployment completion time and duration, prepares the shared OSDCloud log
    directory, copies the WinPE DISM log and other WinPE logs when available, stops the
    active transcript, and applies the configured WinPE post action. Restart and shutdown
    actions are performed only when running in WinPE.

    .PARAMETER None
    This function does not define input parameters. It uses deployment state stored in
    $global:RecastOSDCloud and the current system environment.

    .EXAMPLE
    Step-OSDCloudFinish
    Finalizes the current OSDCloud deployment and applies the value of
    $global:RecastOSDCloud.WinPEPostAction.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Capture the final deployment duration before any finish action is performed.
    if ($null -eq $global:RecastOSDCloud.TimeStart) {
        # Keep direct calls safe when the caller did not initialize the start timestamp.
        $global:RecastOSDCloud.TimeStart = [datetime](Get-Date)
    }
    $global:RecastOSDCloud.TimeEnd = [datetime](Get-Date)
    $global:RecastOSDCloud.TimeSpan = New-TimeSpan -Start $global:RecastOSDCloud.TimeStart -End $global:RecastOSDCloud.TimeEnd
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Recast OSDCloud completed in $($global:RecastOSDCloud.TimeSpan.ToString("mm' minutes 'ss' seconds'"))"

    # Ensure the shared log directory exists before writing final deployment logs.
    $logDirectory = 'C:\Windows\Temp\osdcloud-logs'
    if (-not (Test-Path -LiteralPath $logDirectory)) {
        New-Item -Path $logDirectory -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # Save the RecastOSDCloud object to a JSON file for post-deployment analysis.
    # $null = $global:RecastOSDCloud | ConvertTo-Json -Depth 2 | Out-File -FilePath (Join-Path $logDirectory 'RecastOSDCloud.json') -Encoding utf8 -Width 2000 -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    # Capture the DISM Log
    if (Test-Path -LiteralPath 'X:\windows\logs\DISM\dism.log') {
        Copy-Item -Path 'X:\windows\logs\DISM\dism.log' -Destination (Join-Path $logDirectory 'dism.log') -Force
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Stopping transcript and saving logs to $logDirectory"
    $null = Stop-Transcript -ErrorAction SilentlyContinue

    # Copy existing WinPE Logs to C:\Windows\Temp\osdcloud-logs
    if ($env:SystemDrive -eq 'X:') {
        $null = robocopy "X:\Windows\Temp\osdcloud-logs" "C:\Windows\Temp\osdcloud-logs" *.* /e /ndl /r:0 /w:0
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Finish Action $($global:RecastOSDCloud.WinPEPostAction)"
    # Apply the requested end-of-deployment action after final logs are saved.
    switch ($global:RecastOSDCloud.WinPEPostAction) {
        'Quit' {
            # Exit without restarting or shutting down the operating system.
            try {
                # Stop-Transcript can fail when no transcript is active; do not mask completion.
                Stop-Transcript | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Stop-Transcript skipped: $($_.Exception.Message)"
            }
        }
        'Restart' {
            # Give the operator time to cancel before restarting WinPE.
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] WinPE is restarting in 30 seconds"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press CTRL + C to cancel"
            Start-Sleep -Seconds 30
            try {
                # Close the transcript before handing control back to the firmware/OS.
                Stop-Transcript | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Stop-Transcript skipped: $($_.Exception.Message)"
            }
            if ($env:SystemDrive -eq 'X:') {
                # Restart only from WinPE; full Windows should remain running.
                Restart-Computer
            }
        }
        'Shutdown' {
            # Give the operator time to cancel before shutting down WinPE.
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] WinPE will shutdown in 30 seconds"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press CTRL + C to cancel"
            Start-Sleep -Seconds 30
            try {
                # Close the transcript before powering off the system.
                Stop-Transcript | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Stop-Transcript skipped: $($_.Exception.Message)"
            }
            if ($env:SystemDrive -eq 'X:') {
                # Shut down only from WinPE; full Windows should remain running.
                Stop-Computer
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
