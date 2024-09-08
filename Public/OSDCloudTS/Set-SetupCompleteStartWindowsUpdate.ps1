Function Set-SetupCompleteStartWindowsUpdate {
    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath 'Write-Output "Running Windows Update Function [Start-WindowsUpdate] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath "Start-WindowsUpdate"
        Add-Content -Path $PSFilePath 'Write-Output "Completed Section [Start-WindowsUpdate] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }
}
