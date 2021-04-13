<#
.SYNOPSIS
Returns WiFi Network SSID's.  Requires WinRE

.Description
Returns WiFi Network SSID's.  Requires WinRE

.PARAMETER SSID
Returns detailed information about the SSID

.LINK
https://osdcloud.osdeploy.com

.LINK
https://github.com/si-kotic/Manage-WirelessNetworks

.NOTES
Author: Ondrej Sebela
GitHub: https://github.com/ztrhgf
#>
function Get-WinREWiFi {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $SSID
    )
    $response = netsh wlan show networks mode=bssid
    $wLANs = $response | Where-Object { $_ -match "^SSID" } | ForEach-Object {
        $report = "" | Select-Object SSID, Index, NetworkType, Authentication, Encryption, Signal
        $i = $response.IndexOf($_)
        $report.SSID = $_ -replace "^SSID\s\d+\s:\s", ""
        $report.Index = $i
        $report.NetworkType = $response[$i + 1].Split(":")[1].Trim()
        $report.Authentication = $response[$i + 2].Split(":")[1].Trim()
        $report.Encryption = $response[$i + 3].Split(":")[1].Trim()
        $report.Signal = $response[$i + 5].Split(":")[1].Trim()
        $report
    }
    if ($SSID) {
        $wLANs | Where-Object { $_.SSID -eq $SSID }
    } else {
        $wLANs
    }
}