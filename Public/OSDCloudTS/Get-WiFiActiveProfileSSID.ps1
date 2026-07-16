function Get-WiFiActiveProfileSSID {
    $Interfaces = netsh wlan show interfaces
    try {
        $ActiveProfile = ($Interfaces | Select-String "Profile"| Where-Object {$_ -notmatch "Connection"}).ToString().Split(":") | Select-Object -Last 1 -ErrorAction SilentlyContinue
        }
    catch{}
    if ($ActiveProfile){
        $ActiveProfile = $ActiveProfile.Trim()
        return $ActiveProfile
    }
}
