function Get-WiFiProfileKey {
    param (
    [String]$SSID
    )
    $ProfileInfo = netsh wlan show profile name=$SSID key=clear
    $Key = ($ProfileInfo | Select-String "Key Content").ToString().Split(":")  | Select-Object -Last 1
    $Key = $Key.Trim()
    return $Key
}
