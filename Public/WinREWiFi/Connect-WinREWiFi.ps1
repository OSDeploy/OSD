<#
.SYNOPSIS
Connects to the selected WiFi Network SSID.  Requires WinRE

.Description
Connects to the selected WiFi Network SSID.  Requires WinRE

.PARAMETER SSID
WiFi Network SSID to connect to

.LINK
https://osdcloud.osdeploy.com

.NOTES
Author: Ondrej Sebela
GitHub: https://github.com/ztrhgf
#>
function Connect-WinREWiFi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $SSID
    )

    $network = Get-WinREWiFi | ? { $_.SSID -eq $SSID }

    $password = ""
    $notWPA2 = ""
    if ($network.Authentication -ne "Open") {
        $cred = Get-Credential -Message "Enter password for WIFI network '$SSID'" -UserName $SSID
        $password = $cred.GetNetworkCredential().password

        #TODO it can be WEP or enterprise ...but I don't know how Authentication value look like for them
        $notWPA2 = $network | Where-Object { $_.Authentication -ne "WPA2-Personal" }
    }

    # just for sure
    $null = Netsh WLAN delete profile "$SSID"

    # create new network profile
    $param = @{
        WLanName = $SSID
    }
    if ($password) { $param.Passwd = $password }
    if ($notWPA2) { $param.WPA = $true }
    Set-WinREWiFi @param

    # connect to network
    $result = Netsh WLAN connect name="$SSID"
    if ($result -ne "Connection request was completed successfully.") {
        throw "Connection to WIFI wasn't successful. Error was $result"
    }
}