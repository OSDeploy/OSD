Function Get-WindowsUpdateDrivers{

    $WUDownloader=(New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
    $WUInstaller=(New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
    $WUUpdates=New-Object -ComObject Microsoft.Update.UpdateColl
    ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search("IsInstalled=0 and Type='Driver'")).Updates|%{
        if(!$_.EulaAccepted){$_.EulaAccepted=$true}
        if ($_.Title -notmatch "Preview"){[void]$WUUpdates.Add($_)}
    }
    if ($WUUpdates.Count -ge 1){
        $WUInstaller.ForceQuiet=$true
        $WUInstaller.Updates=$WUUpdates
        $WUDownloader.Updates=$WUUpdates
        $UpdateCount = $WUDownloader.Updates.count
        if ($UpdateCount -ge 1){
            Write-Output "Found $UpdateCount Updates"
            foreach ($update in $WUInstaller.Updates){Write-Output "$($update.Title)"}
            #$Download = $WUDownloader.Download()
        }
        #$InstallUpdateCount = $WUInstaller.Updates.count
    }
}
Function Start-WindowsUpdateDriver{
    <# Control Windows Update via PowerShell
    Installing Updates using this Method does NOT notify the user, and does NOT let the user know that updates need to be applied at the next reboot.  It's 100% hidden.
    HResult Lookup: https://docs.microsoft.com/en-us/windows/win32/wua_sdk/wua-success-and-error-codes-
    #>

    $AvailableDriverUpdates = Get-WindowsUpdateDrivers
    if (($AvailableDriverUpdates).count -ge 1){
        Write-Output ""
        Write-Output $AvailableDriverUpdates
        Write-Output ""
        Write-Output "Starting Job to Download & Install Updates"
        Write-Output "Setting Timeout to 20 Minutes"
        Write-Output ""
        $timeoutSeconds = 1200 # 20 Minite Timeout for Drivers
        $code = {
            $Results = @(
            @{ ResultCode = '0'; Meaning = "Not Started"}
            @{ ResultCode = '1'; Meaning = "In Progress"}
            @{ ResultCode = '2'; Meaning = "Succeeded"}
            @{ ResultCode = '3'; Meaning = "Succeeded With Errors"}
            @{ ResultCode = '4'; Meaning = "Failed"}
            @{ ResultCode = '5'; Meaning = "Aborted"}
            @{ ResultCode = '6'; Meaning = "No Updates Found"}
            )


            $WUDownloader=(New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
            $WUInstaller=(New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
            $WUUpdates=New-Object -ComObject Microsoft.Update.UpdateColl
            ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search("IsInstalled=0 and Type='Driver'")).Updates|%{
                if(!$_.EulaAccepted){$_.EulaAccepted=$true}
                if ($_.Title -notmatch "Preview"){[void]$WUUpdates.Add($_)}
            }

            if ($WUUpdates.Count -ge 1){
                $WUInstaller.ForceQuiet=$true
                $WUInstaller.Updates=$WUUpdates
                $WUDownloader.Updates=$WUUpdates
                $UpdateCount = $WUDownloader.Updates.count
                if ($UpdateCount -ge 1){
                    Write-Output "Downloading $UpdateCount Updates"
                    #foreach ($update in $WUInstaller.Updates){Write-Output "$($update.Title)"}
                    #$Download = $WUDownloader.Download()
                    $WUDownloader.Download() | Out-Null
                }
                $InstallUpdateCount = $WUInstaller.Updates.count
                
                #Run the Install of detected Drivers.
                if ($InstallUpdateCount -ge 1){
                    Write-Output "Installing $InstallUpdateCount Updates | Time: $($(Get-Date).ToString("hh:mm:ss"))"        
                    $script:Install = $WUInstaller.Install()
                    $ResultMeaning = ($Results | Where-Object {$_.ResultCode -eq $script:Install.ResultCode}).Meaning
                    Write-Output "WU Return Code ($($script:Install.ResultCode)) Meaning: $ResultMeaning"
                } 
            }
            else {Write-Output "No Updates Found"}
        }
        #Start the Job
        $Installing = Start-Job -ScriptBlock $code
        # Report the job ID (for diagnostic purposes)
        "Job ID: $($Installing.Id)"
        
        # Wait for the job to complete or time out
        Wait-Job $Installing -Timeout $timeoutSeconds | Out-Null
        Receive-Job -Job $Installing
        # Check the job state
        if ($Installing.State -eq "Completed") {
            # Job completed successfully
            "Done!"
        } elseif ($Installing.State -eq "Running") {
            # Job was interrupted due to timeout
            "Interrupted"
        } else {
            # Unexpected job state
            "???"
        }

        # Clean up the job
        Remove-Job -Force $Installing
    }
}
