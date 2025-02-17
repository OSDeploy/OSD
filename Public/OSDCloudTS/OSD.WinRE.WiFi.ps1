if ($env:SystemDrive -eq 'X:') {
    function Connect-WinREWiFi {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [string] $SSID
        )

        $network = Get-WinREWiFi | Where-Object { $_.SSID -eq $SSID }

        $password = ""

        if ($network.Authentication -ne "Open") {
            $cred = Get-Credential -Message "Enter password for WIFI network '$SSID'" -UserName $SSID
            $password = $cred.GetNetworkCredential().password
        }

        #TODO Add more modes like WEP or enterprise here:
        if ($network.Authentication -eq "WPA-Personal") {
            $authmode = "WPAPSK"
            $encmode = "AES"
        }

        # It's for WPA3 networks with WPA2 fallback. You still want to try WPA2 if your radio SOC is not able to use WPA3
        if (($network.Authentication -eq "WPA2-Personal") -or ($network.Authentication -eq "WPA3-Personal")) {
            $authmode = "WPA2PSK"
            $encmode = "AES"
        }
        
        # Checks if your card is able to do WPA3
        if (($network.Authentication -eq "WPA3-Personal") -and (netsh wlan show driver | Select-String -Pattern "WPA3-Personal")) {
            $authmode = "WPA3SAE"
            $encmode = "AES"
        }

        # just for sure
        $null = Netsh WLAN delete profile "$SSID"

        # create new network profile
        $param = @{
            WLanName = $SSID
        }
        if ($password) { $param.Passwd = $password }
        if ($authmode) { $param.WPA = $true }
        Set-WinREWiFi @param

        # connect to network
        $result = Netsh WLAN connect name="$SSID"
        if ($result -ne "Connection request was completed successfully.") {
            throw "Connection to WIFI wasn't successful. Error was $result"
        }
    }
    function Connect-WinREWiFiByXMLProfile {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "$_ doesn't exists"
                }
                if ($_ -notmatch "\.xml$") {
                    throw "$_ isn't xml file"
                }
                if (!(([xml](Get-Content $_ -Raw)).WLANProfile.Name) -or (([xml](Get-Content $_ -Raw)).WLANProfile.MSM.security.sharedKey.protected) -ne "false") {
                    throw "$_ isn't valid Wi-Fi XML profile (is the password correctly in plaintext?). Use command like this, to create it: netsh wlan export profile name=`"MyWifiSSID`" key=clear folder=C:\Wifi"
                }
            })]
            [string] $wifiProfile
        )
        
        $SSID = ([xml](Get-Content $wifiProfile)).WLANProfile.Name
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Connecting to $SSID"

        # just for sure
        $null = Netsh WLAN delete profile "$SSID"

        # import wifi profile
        $null = Netsh WLAN add profile filename="$wifiProfile"

        # connect to network
        $result = Netsh WLAN connect name="$SSID"
        if ($result -ne "Connection request was completed successfully.") {
            throw "Connection to WIFI wasn't successful. Error was $result"
        }
    }
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
    function Set-WinREWiFi() {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, HelpMessage = "Please add Wireless network name")]
            [System.String]
            $WLanName,
            
            [System.String]
            $Passwd,
            
            [Parameter(Mandatory = $false, HelpMessage = "This switch will generate a WPA profile instead of WPA2")]
            [System.Management.Automation.SwitchParameter]
            $WPA = $false,

            [Parameter(Mandatory = $false, HelpMessage = "This switch will generate XML Profile File")]
            [System.String]
            $OutFile = "$env:TEMP/WiFiProfile.xml"
        )

        if ($Passwd) {
            # escape XML special characters
            $Passwd = [System.Security.SecurityElement]::Escape($Passwd)
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
                 <authentication>$authmode</authentication>
                 <encryption>$encmode</encryption>
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
        if ($OutFile){
            Copy-Item $WlanConfig -Destination $OutFile
        }
        $result = Netsh WLAN add profile filename=$WlanConfig
        Remove-Item $WlanConfig -ErrorAction SilentlyContinue
        if ($result -notmatch "is added on interface") {
            throw "There was en error when setting up WIFI $WLanName connection profile. Error was $result"
        }
    }
    function Start-WinREWiFi {
        [CmdletBinding()]
        param (
            [System.String]
            $wifiProfile,
            
            [System.Management.Automation.SwitchParameter]
            $WirelessConnect
        )
        Block-PowerShellVersionLt5
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        #	Transcript
        #=================================================        
        $TranscriptPath = "$env:SystemDrive\OSDCloud\Logs"
        if (!(Test-Path -path $TranscriptPath)){
            New-Item -Path $TranscriptPath -ItemType Directory -Force | Out-Null
        }
        $null = Start-Transcript -Path "$TranscriptPath\WinREWiFi.txt" -ErrorAction Ignore
        #=================================================
        #	Test Internet Connection
        #=================================================
        if (Test-WebConnection -Uri 'google.com') {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Ping google.com success. Device is already connected to the Internet"
            $StartWinREWiFi = $false
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Ping google.com failed. Will attempt to connect to a Wireless Network"
            $StartWinREWiFi = $true
        }
        #=================================================
        #   Test WinRE
        #=================================================
        if ($StartWinREWiFi) {
            if (!(Test-Path "$ENV:SystemRoot\System32\dmcmnutils.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\mdmpostprocessevaluator.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\mdmregistration.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\raschap.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\raschapext.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\rastls.dll")) {
                $StartWinREWiFi = $false
            }
            if (!(Test-Path "$ENV:SystemRoot\System32\rastlsext.dll")) {
                $StartWinREWiFi = $false
            }
            if ($StartWinREWiFi) {
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Unable to enable Wireless Network due to missing components"
            }
        }
        #=================================================
        #	WlanSvc
        #=================================================
        if ($StartWinREWiFi) {
            if (Get-Service -Name WlanSvc) {
                if ((Get-Service -Name WlanSvc).Status -ne 'Running') {
                    Get-Service -Name WlanSvc | Start-Service
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Waiting for WlanSvc service to start"
                    (Get-Service WlanSvc).WaitForStatus('Running')
                }
            }
        }
        #=================================================
        #	Test Wi-Fi Adapter
        #=================================================
        if ($StartWinREWiFi) {
            # Do we have a Wireless Interface? We have to search for different names as this will vary depending on the WinPE Language
            $SmbClientNetworkInterface = Get-SmbClientNetworkInterface | Where-Object { ($_.'FriendlyName' -match 'WiFi|Wi-Fi|Wireless|WLAN') } | Sort-Object -Property InterfaceIndex | Select-Object -First 1
            
            # Pair a Wireless Network Adapter based on the InterfaceIndex
            $WirelessNetworkAdapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.InterfaceIndex -eq $SmbClientNetworkInterface.InterfaceIndex }

            if ($WirelessNetworkAdapter) {
                $StartWinREWiFi = $true
                $WirelessNetworkAdapter | Select-Object * -ExcludeProperty Availability, Status, StatusInfo, Caption, Description, InstallDate, *Error*, *Power*, CIM*, System*, PS*, AutoSense, MaxSpeed, Index, TimeOfLastReset, MaxNumberControlled, Installed, NetworkAddresses,ConfigManager* | Format-List
            }
            else {
                # Get Network Devices with Error Status
                $PnPEntity = Get-WmiObject -ClassName Win32_PnPEntity | Where-Object { $_.Status -eq 'Error' } |  Where-Object { $_.Name -match 'Net' }
                Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] No Wireless Network Adapters were detected"
                if ($PnPEntity) {
                    Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Drivers may need to be added to WinPE for the following hardware"
                    foreach ($Item in $PnPEntity) {
                        Write-Warning "$($Item.Name): $($Item.DeviceID)"
                    }
                    Start-Sleep -Seconds 10
                }
                else {
                    Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Drivers may need to be added to WinPE before Wireless Networking is available"
                }
                $StartWinREWiFi = $false
            }
        }
        #=================================================
        #   Test UEFI WiFi Profile
        #=================================================
        if ($StartWinREWiFi){
            $Module = Import-Module UEFIv2 -PassThru -ErrorAction SilentlyContinue
            if ($Module) {
                $UEFIWiFiProfile = Get-UEFIVariable -Namespace "{43B9C282-A6F5-4C36-B8DE-C8738F979C65}" -VariableName PrebootWiFiProfile
                if ($UEFIWiFiProfile) {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Found WiFi Profile in HP UEFI"
                    $UEFIWiFiProfile = $UEFIWiFiProfile -Replace "`0",""

                    $SSIDString = $UEFIWiFiProfile.Split(",") | Where-Object {$_ -match "SSID"}
                    $SSID = ($SSIDString.Split(":") | Where-Object {$_ -notmatch "SSID"}).Replace("`"","")

                    $KeyString = $UEFIWiFiProfile.Split(",") | Where-Object {$_ -match "Password"}
                    $Key = ($KeyString.Split(":") | Where-Object {$_ -notmatch "Password"}).Replace("`"","")
                    if ($SSID) {
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Found $SSID in UEFI, Attepting to Create Profile and Connect"
                        Set-WinREWiFi -WLanName $SSID -Passwd $Key -outfile "$env:TEMP\UEFIWiFiProfile.XML"
                        if (!($wifiProfile)) {
                            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Setting wifiprofile var to $env:TEMP\UEFIWiFiProfile.XML"
                            $wifiProfile = "$env:TEMP\UEFIWiFiProfile.XML"
                        }
                    }
                }
            }
        }
        #=================================================
        #	Test Wi-Fi Connection
        #=================================================
        #TODO Test on ARM64
        if ($StartWinREWiFi) {
            if ($WirelessNetworkAdapter.NetEnabled -eq $true) {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Wireless is already connected ... Disconnecting"
                (Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object { $_.InterfaceIndex -eq $WirelessNetworkAdapter.InterfaceIndex }).disable() | Out-Null
                Start-Sleep -Seconds 5
                (Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object { $_.InterfaceIndex -eq $WirelessNetworkAdapter.InterfaceIndex }).enable() | Out-Null
                Start-Sleep -Seconds 5
                $StartWinREWiFi = $true
            }
        }
        #=================================================
        #   Connect
        #=================================================
        if ($StartWinREWiFi) {
                if ($wifiProfile -and (Test-Path $wifiProfile)) {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Starting unattended Wi-Fi connection "
                }
                else {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Starting Wi-Fi Network Menu "
                }

                # Use the Win32_NetworkAdapterConfiguration to check if the Wi-Fi adapter is IPEnabled
                while (((Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.Index -eq $($WirelessNetworkAdapter.DeviceID) }).IPEnabled -eq $false)) {
                Start-Sleep -Seconds 3

                $StartWinREWiFi = 0
                # make checks on start of evert cycle because in case of failure, profile will be deleted
                if ($wifiProfile -and (Test-Path $wifiProfile)) { ++$StartWinREWiFi }
        
                if ($StartWinREWiFi) {
                    # use saved wi-fi profile to make the unattended connection
                    try {
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Establishing a connection using $wifiProfile"
                        Connect-WinREWiFiByXMLProfile $wifiProfile -ErrorAction Stop
                        Start-Sleep -Seconds 10
                    }
                    catch {
                        Write-Warning $_
                        # to avoid infinite loop of tries
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Removing invalid Wi-Fi profile '$wifiProfile'"
                        Remove-Item $wifiProfile -Force
                        continue
                    }
                }
                else {
                    # show list of available SSID to make interactive connection
                    if (($WirelessConnect) -and (Test-Path -path $ENV:SystemRoot\WirelessConnect.exe)) {
                        Start-Process -FilePath  $ENV:SystemRoot\WirelessConnect.exe -Wait
                    }
                    else {
                        $SSIDList = Get-WinREWiFi
                        if ($SSIDList) {
                            #show list of available SSID
                            $SSIDList | Sort-Object Index | Select-Object Signal, Index, SSID, Authentication, Encryption, NetworkType | Format-Table
                
                            $SSIDListIndex = $SSIDList.index
                            $SSIDIndex = ""
                            while ($SSIDIndex -notin $SSIDListIndex) {
                                $SSIDIndex = Read-Host "Select the Index of Wi-Fi Network to connect or CTRL+C to quit"
                            }
                
                            $SSID = $SSIDList | Where-Object { $_.index -eq $SSIDIndex } | Select-Object -exp SSID
                
                            # connect to selected Wi-Fi
                            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Establishing a connection to SSID $SSID"
                            try {
                                Connect-WinREWiFi $SSID -ErrorAction Stop
                            } catch {
                                Write-Warning $_
                                continue
                            }
                        } else {
                            Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] No Wi-Fi network found. Move closer to AP or use ethernet cable instead."
                        }
                    }
                }

                if ($StartWinREWiFi) {
                    $text = "to Wi-Fi using $wifiProfile"
                } else {
                    $text = "to SSID $SSID"
                }
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Waiting for a connection $text"
                Start-Sleep -Seconds 15
            
                $i = 30
                #TODO Resolve issue with WirelessNetworkAdapter
                while (((Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.Index -eq $($WirelessNetworkAdapter.DeviceID) }).IPEnabled -eq $false) -and $i -gt 0) {
                    --$i
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))][$($MyInvocation.MyCommand.Name)] Waiting for Wi-Fi Connection ($i)"
                    Start-Sleep -Seconds 1
                }
            }
            Get-SmbClientNetworkInterface | Where-Object { ($_.FriendlyName -match 'WiFi|Wi-Fi|Wireless|WLAN') } | Format-List
        }
        $null = Stop-Transcript -ErrorAction Ignore
        if ($StartWinREWiFi) {
            Start-Sleep -Seconds 5
        }
    }
}