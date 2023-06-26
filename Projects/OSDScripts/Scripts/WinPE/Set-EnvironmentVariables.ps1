function osdcloud-WinpeSetEnvironmentVariables {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if (Get-Item env:LocalAppData -ErrorAction Ignore) {
            Write-Host -ForegroundColor Green "[+] Set LocalAppData in System Environment"
        }
        else {
            Write-Host -ForegroundColor Green "[+] Set LocalAppData in System Environment"
            Write-Verbose 'WinPE does not have the LocalAppData System Environment Variable'
            Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
            Write-Verbose 'Set System Environment Variable LocalAppData for this PowerShell session'
            #[System.Environment]::SetEnvironmentVariable('LocalAppData',"$env:UserProfile\AppData\Local")
            [System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
            [System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
            [System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
            [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
        }
    }
}
osdcloud-WinpeSetEnvironmentVariables