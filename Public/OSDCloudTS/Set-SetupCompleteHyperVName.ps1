function Set-SetupCompleteHyperVName {

    Write-Host -ForegroundColor Cyan "Running SetupComplete HyperVName"

    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (!(Test-Path -Path $ScriptsPath)){
        Set-SetupCompleteInitialize
    }

    Write-Output "Appending $($RunScript.Script) Files"
    Add-Content -Path $PSFilePath "Write-Output 'Set HyperV Computer Name [Set-HyperVName]'"
    Add-Content -Path $PSFilePath "Set-HyperVName"
    Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
}