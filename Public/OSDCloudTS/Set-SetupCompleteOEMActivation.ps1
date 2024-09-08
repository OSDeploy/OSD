﻿function Set-SetupCompleteOEMActivation {
    Write-Host -ForegroundColor Cyan "Running SetupComplete OEM Activiation"
    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath "Write-Output 'Setting Windows OEM Activation [Set-WindowsOEMActivation]'"
        Add-Content -Path $PSFilePath "Set-WindowsOEMActivation"
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }
}
