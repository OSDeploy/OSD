function Set-SetupCompleteSetWiFi {
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SetupComplete - Adding WiFi Profile"
    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
    $ConfigPath = "c:\osdcloud\configs"
    if (Test-Path $ConfigPath){
        $JSONConfigs = Get-ChildItem -path $ConfigPath -Filter "*.json"
        if ($JSONConfigs.name -contains "WiFi.JSON"){
            Add-Content -Path $PSFilePath 'Write-Host "Found WiFi JSON files"'
            $Json = Get-Content -Path "$ConfigPath\WiFi.JSON" | ConvertFrom-Json
            $SSID = $Json.Addons.SSID
            $PSK = $Json.Addons.PSK
            if (Test-Path -Path $PSFilePath){
                Add-Content -Path $PSFilePath ' Write-Host "Creating WiFi Profile"'
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-WiFi -SSID `"$SSID`" -PSK `"***********`""
                Add-Content -Path $PSFilePath "Set-WiFi -SSID `"$SSID`" -PSK `"$PSK`""
                Add-Content -Path $PSFilePath "Remove-Item -Path $ConfigPath\WiFi.JSON -Force -Verbose"
                Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
            }
            else {
            Write-Output "$PSFilePath - Not Found"
            }
        }
    }
}
