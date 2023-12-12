function Set-SetupCompleteCreateFinish {

    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath "Write-Output 'Setting PowerPlan to Balanced'"
        Add-Content -Path $PSFilePath "Set-PowerSettingTurnMonitorOffAfter -PowerSource AC -Minutes 15"
        Add-Content -Path $PSFilePath "powercfg /setactive 381B4222-F694-41F0-9685-FF5BB260DF2E"
        Add-Content -Path $PSFilePath '$EndTime = Get-date; Write-Host "End Time: $($EndTime.ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath '$TotalTime = New-TimeSpan -Start $StartTime -End $EndTime; $RunTimeMinutes = [math]::round($TotalTime.TotalMinutes,0); Write-Host "Run Time: $RunTimeMinutes Minutes"'
        Add-Content -Path $PSFilePath "Stop-Transcript"
        Add-Content -Path $PSFilePath "Restart-Computer -Force"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }

}
