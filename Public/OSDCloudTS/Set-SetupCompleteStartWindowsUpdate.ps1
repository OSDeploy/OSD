Function Set-SetupCompleteStartWindowsUpdate {

    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (!(Test-Path -Path $ScriptsPath)){
        Set-SetupCompleteInitialize
    }

    Write-Output "Appending $($RunScript.Script) Files"
    Add-Content -Path $PSFilePath 'Write-Output "Running Windows Update Function [Start-WindowsUpdate] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
    Add-Content -Path $PSFilePath "Start-WindowsUpdate"
    Add-Content -Path $PSFilePath 'Write-Output "Completed Section [Start-WindowsUpdate] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
    Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
}