function Set-SetupCompleteSetWiFi {

    Write-Host -ForegroundColor Cyan "Running SetupComplete Set-WiFi"

    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
    
    $ConfigPath = "C:\OSDCloud\configs"

    if (Test-Path $ConfigPath){
        $JSONConfigs = Get-ChildItem -path $ConfigPath -Filter "*.json"
        if ($JSONConfigs.name -contains "WiFi.JSON"){
            if (!(Test-Path -Path $ScriptsPath)){
                Set-SetupCompleteInitialize
            }
            Add-Content -Path $PSFilePath 'Write-Host "Found WiFi JSON files"'
            $Json = Get-Content -Path "$ConfigPath\WiFi.JSON" | ConvertFrom-Json
            $SSID = $Json.Addons.SSID
            $PSK = $Json.Addons.PSK
            Add-Content -Path $PSFilePath ' Write-Host "Creating WiFi Profile"'
            Write-Host "Set-WiFi -SSID $SSID -PSK ***********"
            Add-Content -Path $PSFilePath "Set-WiFi -SSID $SSID -PSK $PSK"
            Add-Content -Path $PSFilePath "Remove-Item -Path $ConfigPath\WiFi.JSON -Force -Verbose"
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        }
    }
    else {
    Write-Output "$ConfigPath - Not Found"
    }
 }