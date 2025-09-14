function Step-OSDCloudSetupCompleteSetWiFi {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding WinPE WiFi Profile to SetupComplete.cmd"

    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $SetupCompleteCmd = "$ScriptsPath\SetupComplete.cmd"
    $SetupCompletePs = "$ScriptsPath\SetupComplete.ps1"
    $LogsPath = "C:\Windows\Temp\osdcloud-logs"
    $WifiJson = "$LogsPath\wifi.json"

    if (Test-Path $WifiJson) {
        $Json = Get-Content -Path $WifiJson | ConvertFrom-Json
        $SSID = $Json.Addons.SSID
        $PSK = $Json.Addons.PSK

        if (Test-Path -Path $SetupCompletePs){
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-WiFi -SSID `"$SSID`" -PSK `"***********`""
            Add-Content -Path $SetupCompletePs ' Write-Host "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating WiFi Profile"'
            Add-Content -Path $SetupCompletePs "Set-WiFi -SSID `"$SSID`" -PSK `"$PSK`""
            Add-Content -Path $SetupCompletePs "Remove-Item -Path $WifiJson -Force -Verbose"
            Add-Content -Path $SetupCompletePs "Write-Output '-------------------------------------------------------------'"
        }
    }
}