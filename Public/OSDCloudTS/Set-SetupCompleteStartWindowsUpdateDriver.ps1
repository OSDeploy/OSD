Function Set-SetupCompleteStartWindowsUpdateDriver {
    $ScriptsPath = "C:\Windows\Setup\scripts"
    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath 'Write-Output "Running Windows Update Drivers Function [Start-WindowsUpdateDriver] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath "Start-WindowsUpdateDriver"
        Add-Content -Path $PSFilePath 'Write-Output "Completed Section [Start-WindowsUpdateDriver] | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }
}
