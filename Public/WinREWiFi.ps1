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
<#
.SYNOPSIS
Creates a WiFi Network Profile.  Requires WinRE

.Description
Creates a WiFi Network Profile.  Requires WinRE

.PARAMETER Passwd
Password for the Network Profile

.PARAMETER WLanName
Name of the WiFi Network Profile

.PARAMETER WPA
Creates a WPA WiFi Network Profile

.LINK
https://osdcloud.osdeploy.com

.LINK
https://www.powershellgallery.com/packages/WifiTools/1.2

.NOTES
Author: Ondrej Sebela
GitHub: https://github.com/ztrhgf
#>
function Set-WinREWiFi() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Please add Wireless network name")]
        [string]$WLanName,
        
        [string]$Passwd,
        
        [Parameter(Mandatory = $false, HelpMessage = "This switch will generate a WPA profile instead of WPA2")]
        [switch]$WPA = $false
    )

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
<#
.SYNOPSIS
Starts the WiFi Network Profile connection Wizard.  Requires WinRE

.Description
Starts the WiFi Network Profile connection Wizard.  Requires WinRE

.LINK
https://osdcloud.osdeploy.com

.NOTES
Author: Ondrej Sebela
GitHub: https://github.com/ztrhgf

Author: David Segura
GitHub: https://github.com/OSDeploy
#>
function Start-WinREWiFi {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Block
    #=======================================================================
    #Block-WinOS
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Test WinRE
    #=======================================================================
    if ($StartWireless) {
        if (!(Test-Path "$ENV:SystemRoot\System32\dmcmnutils.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\dmcmnutils.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\mdmpostprocessevaluator.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\mdmpostprocessevaluator.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\mdmregistration.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\mdmregistration.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\raschap.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\raschap.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\raschapext.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\raschapext.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\rastls.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\rastls.dll"
            $StartWireless = $false
        }
        if (!(Test-Path "$ENV:SystemRoot\System32\rastlsext.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\rastlsext.dll"
            $StartWireless = $false
        }
        if (!(Get-NetAdapter -Name 'Wi-Fi')) {
            Write-Warning "No wireless adapters are present"
            Write-Warning "Drivers may need to be added to WinPE"
            $StartWireless = $false
        }
    }
    #=======================================================================
    #	Test Wi-Fi Adapter
    #=======================================================================
    $WirelessNetworkAdapter = Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}
    #$WirelessNetworkAdapter = Get-SmbClientNetworkInterface | Where-Object {$_.FriendlyName -eq 'Wi-Fi'}
    if ($WirelessNetworkAdapter) {
        $StartWireless = $true
    }
    else {
        Write-Warning "No Wi-Fi Adapters are installed"
        Write-Warning "You may need to add Drivers"
        $StartWireless = $false
    }
    #=======================================================================
    #	Test Wi-Fi Connection
    #=======================================================================
    if ($StartWireless) {
        if ($WirelessNetworkAdapter.NetEnabled -eq $true) {
            Write-Verbose -Verbose "Wireless is already connected ... Disconnecting"
            (Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).disable() | Out-Null
            (Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).enable() | Out-Null
            $StartWireless = $true
        }
    }
    #=======================================================================
    #   Connect
    #=======================================================================
    if ($StartWireless) {
        while (((Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).NetEnabled) -eq $false) {
            $SSIDList = Get-WinREWiFi
            if ($SSIDList) {
                #show list of available SSID
                $SSIDList | Sort-Object Signal -Descending | Select-Object Signal, Index, SSID, Authentication, Encryption, NetworkType | Format-Table
    
                $SSIDListIndex = $SSIDList.index
                $SSIDIndex = ""
                while ($SSIDIndex -notin $SSIDListIndex) {
                    $SSIDIndex = Read-Host "Select the Index of Wi-Fi Network to connect or CTRL+C to quit"
                }
    
                $SSID = $SSIDList | Where-Object { $_.index -eq $SSIDIndex } | Select-Object -exp SSID
    
                # connect to selected Wi-Fi
                try {
                    "Connecting to $SSID"
                    Connect-WinREWiFi $SSID -ErrorAction Stop
                } catch {
                    Write-Warning $_
                    continue
                }
            } else {
                Write-Warning "No Wi-Fi network found. Move closer to AP or use ethernet cable instead."
            }

            Write-Host -ForegroundColor Cyan "Waiting for a connection ..."
            Start-Sleep -Seconds 10
        
            $i = 30
            while ((((Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).NetEnabled) -eq $false) -and $i -gt 0) { --$i; "Waiting for Wi-Fi Connection ($i)" ; Start-Sleep -Seconds 1 }

            # connection to network can take a while
            #$i = 30
            #while (!(Test-WebConnection -Uri 'github.com') -and $i -gt 0) { --$i; "Waiting for Internet connection ($i)" ; Start-Sleep -Seconds 1 }
        }
        Get-SmbClientNetworkInterface | Where-Object {$_.FriendlyName -eq 'Wi-Fi'} | Format-List
    }
    Start-Sleep -Seconds 5
}