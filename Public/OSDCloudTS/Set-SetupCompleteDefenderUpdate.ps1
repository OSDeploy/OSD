Function Set-SetupCompleteDefenderUpdate {
    
    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (!(Test-Path -Path $ScriptsPath)){
        Set-SetupCompleteInitialize
    }

    Write-Output "Appending $($RunScript.Script) Files"
    Add-Content -Path $PSFilePath 'Write-Output "Running Defender Update Stack Function [Update-DefenderStack] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
    Add-Content -Path $PSFilePath "Update-DefenderStack"
    Add-Content -Path $PSFilePath 'Write-Output "Completed Section [Update-DefenderStack] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
    Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
}