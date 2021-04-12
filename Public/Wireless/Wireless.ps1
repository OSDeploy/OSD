function Get-AvailableWiFiNetwork {
    <#
    .LINK
    inspired by https://github.com/si-kotic/Manage-WirelessNetworks
    #>
    Param (
        [Parameter(ValueFromPipeline = $true)] $SSID
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
function New-WiFiNetworkProfile() {
    <#
    .LINK
    inspired by https://www.powershellgallery.com/packages/WifiTools/1.2
    #>
    param([Parameter(Mandatory = $true, HelpMessage = "Please add Wireless network name")]
        [string]$WLanName, 
        [string]$Passwd,
        [Parameter(Mandatory = $false, HelpMessage = "This switch will generate a WPA profile instead of WPA2")]
        [switch]$WPA = $false)

    if ($Passwd) {
        # escape XML special characters
        $Passwd = [System.Security.SecurityElement]::Escape($Passwd)
    }

    if ($WPA -eq $false) {
        $WpaState = "WPA2PSK"
        $EasState = "AES"
    } else {
        $WpaState = "WPAPSK"
        $EasState = "AES"
    }

    $XMLProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
      <name>$WlanName</name>
      <SSIDConfig>
         <SSID>
              <name>$WLanName</name>
          </SSID>
     </SSIDConfig>
     <connectionType>ESS</connectionType>
     <connectionMode>auto</connectionMode>
     <MSM>
         <security>
             <authEncryption>
                 <authentication>$WpaState</authentication>
                 <encryption>$EasState</encryption>
                 <useOneX>false</useOneX>
             </authEncryption>
             <sharedKey>
                 <keyType>passPhrase</keyType>
                 <protected>false</protected>
				<keyMaterial>$Passwd</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
</WLANProfile>
"@

    if ($Passwd -eq "") {
        $XMLProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>$WLanName</name>
	<SSIDConfig>
		<SSID>
			<name>$WLanName</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>manual</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>open</authentication>
				<encryption>none</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
		</security>
	</MSM>
	<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
		<enableRandomization>false</enableRandomization>
	</MacRandomization>
</WLANProfile>
"@
    }

    $WLanName = $WLanName -replace "\s+"
    $WlanConfig = "$env:TEMP\$WLanName.xml"
    $XMLProfile | Set-Content $WlanConfig
    $result = Netsh WLAN add profile filename=$WlanConfig
    Remove-Item $WlanConfig -ErrorAction SilentlyContinue
    if ($result -notmatch "is added on interface") {
        throw "There was en error when setting up WIFI $WLanName connection profile. Error was $result"
    }
}
function Connect-WiFiNetwork {
    <#
    .SYNOPSIS
    Invokes connection to selected SSID network.
    Asks for credentails (if protected network), creates necessary profile and connects.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string] $SSID
    )

    $network = Get-AvailableWiFiNetwork | ? { $_.SSID -eq $SSID }

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
    New-WiFiNetworkProfile @param

    # connect to network
    $result = Netsh WLAN connect name="$SSID"
    if ($result -ne "Connection request was completed successfully.") {
        throw "Connection to WIFI wasn't successful. Error was $result"
    }
}