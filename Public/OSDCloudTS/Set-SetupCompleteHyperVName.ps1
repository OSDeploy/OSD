function Set-SetupCompleteHyperVName {
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] SetupComplete - Set Hyper-V Name"
    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath "Write-Output 'Set HyperV Computer Name [Set-HyperVName]'"
        Add-Content -Path $PSFilePath "Set-HyperVName"
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
        Write-Output "$PSFilePath - Not Found"
    }
}