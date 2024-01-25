Function Start-WindowsUpdate{
    <# Control Windows Update via PowerShell
    Installing Updates using this Method does NOT notify the user, and does NOT let the user know that updates need to be applied at the next reboot.  It's 100% hidden.
    HResult Lookup: https://docs.microsoft.com/en-us/windows/win32/wua_sdk/wua-success-and-error-codes-
    #>

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
    ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search("IsInstalled=0 and Type='Software'")).Updates|%{
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
            foreach ($update in $WUInstaller.Updates){Write-Output "$($update.Title)"}
            $Download = $WUDownloader.Download()
        }
        $InstallUpdateCount = $WUInstaller.Updates.count
        if ($InstallUpdateCount -ge 1){
            Write-Output "Installing $InstallUpdateCount Updates"
            $Install = $WUInstaller.Install()
            $ResultMeaning = ($Results | Where-Object {$_.ResultCode -eq $Install.ResultCode}).Meaning
            Write-Output $ResultMeaning
        } 
    }
    else {Write-Output "No Updates Found"} 
}
