function Set-SetupCompleteCreateStart {
    $ScriptsPath = "C:\Windows\Setup\Scripts"

    if (!(Test-Path -Path $ScriptsPath)) {
        New-Item -Path $ScriptsPath
    }

    $SetupCompleteCmd = "$ScriptsPath\SetupComplete.cmd"
    $SetupCompletePs = "$ScriptsPath\SetupComplete.ps1"

    if (-NOT (Test-Path $SetupCompleteCmd)) {
        New-Item -Path $SetupCompleteCmd -ItemType File -Force
    }
    $Content = New-Object System.Text.StringBuilder
    [void]$Content.Append('%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File')
    [void]$Content.Append(" $SetupCompletePs")
    Add-Content -Path $SetupCompleteCmd -Value $Content.ToString()

    if (-NOT (Test-Path $SetupCompletePs)) {
        New-Item -Path $SetupCompletePs -ItemType File -Force
    }
    Add-Content -Path $SetupCompletePs "Write-Output 'Starting SetupComplete Script Process'"
    Add-Content -Path $SetupCompletePs "Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser"
    Add-Content -Path $SetupCompletePs '$StartTime = Get-Date; Write-Host "Start Time: $($StartTime.ToString("hh:mm:ss"))"'
    Add-Content -Path $SetupCompletePs '$ModulePath = (Get-ChildItem -Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname'
    Add-Content -Path $SetupCompletePs 'import-module "$ModulePath\OSD.psd1" -Force'
    Add-Content -Path $SetupCompletePs "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')"
    # Add-Content -Path $SetupCompletePs "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpe.psm1')"
    Add-Content -Path $SetupCompletePs "Start-Sleep -Seconds 10"
    Add-Content -Path $SetupCompletePs "Start-Transcript -Path 'C:\Windows\Temp\osdcloud-logs\SetupComplete.log' -ErrorAction Ignore"
    Add-Content -Path $SetupCompletePs "Write-Output 'Setting PowerPlan to High Performance'"
    Add-Content -Path $SetupCompletePs "powercfg /setactive DED574B5-45A0-4F42-8737-46345C09C238"
    Add-Content -Path $SetupCompletePs "Write-Output 'Confirming PowerPlan [powercfg /getactivescheme]'"
    Add-Content -Path $SetupCompletePs "powercfg /getactivescheme"
    Add-Content -Path $SetupCompletePs "powercfg -x -standby-timeout-ac 0"
    Add-Content -Path $SetupCompletePs "powercfg -x -standby-timeout-dc 0"
    Add-Content -Path $SetupCompletePs "powercfg -x -hibernate-timeout-ac 0"
    Add-Content -Path $SetupCompletePs "powercfg -x -hibernate-timeout-dc 0"
    Add-Content -Path $SetupCompletePs "Set-PowerSettingSleepAfter -PowerSource AC -Minutes 0"
    Add-Content -Path $SetupCompletePs "Set-PowerSettingTurnMonitorOffAfter -PowerSource AC -Minutes 0"
    # Add-Content -Path $SetupCompletePs "Stop-Transcript"
    # Add-Content -Path $SetupCompletePs "Restart-Computer -Force"
}