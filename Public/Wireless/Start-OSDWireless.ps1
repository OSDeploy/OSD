function Start-OSDWireless {
    [CmdletBinding(DefaultParameterSetName = 'Module')]
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
        if (!(Test-Path "$ENV:SystemRoot\System32\mdmregistration.dll")) {
            Write-Warning "Missing required $ENV:SystemRoot\System32\mdmregistration.dll"
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
        while ((Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).NetConnectionStatus -ne 2) {
            $SSIDList = Get-AvailableWiFiNetwork
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
                    Connect-WiFiNetwork $SSID -ErrorAction Stop
                } catch {
                    Write-Warning $_
                    continue
                }
            } else {
                Write-Warning "No Wi-Fi network found. Move closer to AP or use ethernet cable instead."
            }
        
            $i = 30
            while (((Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object {$_.NetConnectionID -eq 'Wi-Fi'}).NetEnabled -eq $false) -and $i -gt 0) { --$i; "Waiting for Wi-Fi Connection ($i)" ; Start-Sleep -Seconds 1 }

            # connection to network can take a while
            #$i = 30
            #while (!(Test-WebConnection -Uri 'github.com') -and $i -gt 0) { --$i; "Waiting for Internet connection ($i)" ; Start-Sleep -Seconds 1 }
        }

        Get-SmbClientNetworkInterface | Where-Object {$_.FriendlyName -eq 'Wi-Fi'} | Format-List
    }
    Start-Sleep -Seconds 5
}