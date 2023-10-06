function Invoke-OSDSpecializeDev {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Apply
    )
    #=================================================
    #   Specialize
    #=================================================
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {
        $Apply = $true
        reg delete HKLM\System\Setup /v UnattendFile /f
    }
    
    #=================================================
    #region Transcript
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving PowerShell Transcript to C:\OSDCloud\Logs"
    Write-Verbose -Message "https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript"

    if (-NOT (Test-Path 'C:\OSDCloud\Logs')) {
        New-Item -Path 'C:\OSDCloud\Logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    
    $Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud-Specialize.log"
    Start-Transcript -Path (Join-Path 'C:\OSDCloud\Logs' $Global:Transcript) -ErrorAction Ignore
    #endregion

    #=================================================
    #   Specialize DriverPacks - REMOVED 23.10.04 - Using PPKG file or DISM in WinPE - Gary B
    #=================================================

    #=================================================
    #   Specialize Config HP & Dell JSON
    #=================================================
    $WirelessAdapters = Get-NetAdapter | Where-Object {($_.PhysicalMediaType -eq 'Native 802.11') -or ($_.PhysicalMediaType -eq 'Wireless LAN')}
    $ConfigPath = "c:\osdcloud\configs"
    if (Test-Path $ConfigPath){
        $JSONConfigs = Get-ChildItem -path $ConfigPath -Filter "*.json"
        if ($JSONConfigs.name -contains "HP.JSON"){
            $HPJson = Get-Content -Path "$ConfigPath\HP.JSON" |ConvertFrom-Json
        }
        if ($JSONConfigs.name -contains "Dell.JSON"){
            $DellJSON = Get-Content -Path "$ConfigPath\DELL.JSON" |ConvertFrom-Json
        }
        if ($JSONConfigs.name -contains "Extras.JSON"){
            $ExtrasJSON = Get-Content -Path "$ConfigPath\Extras.JSON" |ConvertFrom-Json
        }
        if ($WirelessAdapters){
            if ($JSONConfigs.name -contains "WiFi.JSON"){
                $WiFiJSON = Get-Content -Path "$ConfigPath\WiFi.JSON" |ConvertFrom-Json
                $SSID = $WiFiJSON.Addons.SSID
                $PSK = $WiFiJSON.Addons.PSK
                Write-Host "Setting WiFi Profile in Specialize"
                Set-WiFi -SSID $SSID -PSK $PSK
            }
        }
    }

    #TESTING WIFI!!!!
    if (Test-WebConnection -Uri google.com){Write-Output "Device is online via Ethernet Connection"}
    else {
        $WirelessAdapters = Get-NetAdapter | Where-Object {($_.PhysicalMediaType -eq 'Native 802.11') -or ($_.PhysicalMediaType -eq 'Wireless LAN')}
        if ($WirelessAdapters){
            Write-Output "Found Wireless Adapters on Device, attempting to Enable"
            Get-Service -Name WlanSvc | Start-Service
            Start-Sleep -Seconds 10
            if (Test-WebConnection google.com){ Write-Output "Device detected to be online from intial WiFi setup"}
            else {
                function Get-WifiNetwork {
                    end {
                    netsh wlan sh net mode=bssid | % -process {
                        if ($_ -match '^SSID (\d+) : (.*)$') {
                            $current = @{}
                            $networks += $current
                            $current.Index = $matches[1].trim()
                            $current.SSID = $matches[2].trim()
                        } 
                        else {
                            if ($_ -match '^\s+(.*)\s+:\s+(.*)\s*$') {
                                $current[$matches[1].trim()] = $matches[2].trim()
                            }
                        }
                        } -begin { $networks = @() } -end { $networks|% { new-object psobject -property $_ } }
                    }
                }
                $SSIDS = Get-WifiNetwork | select ssid

                <#
                $SSID = Get-WifiNetwork | Select-Object ssid | Out-GridView -Title "Select Wireless Network To Connect to" -PassThru
                $SSID = $SSID.SSID
                $PSK = Read-Host -Prompt "Enter WiFi Password" -AsSecureString
                $PSKText = [System.Net.NetworkCredential]::new("", $PSK).Password
                #>
                # Original example posted at http://technet.microsoft.com/en-us/library/ff730949.aspx

                Add-Type -AssemblyName System.Windows.Forms
                Add-Type -AssemblyName System.Drawing

                $form = New-Object System.Windows.Forms.Form 
                $form.Text = "Select a Computer"
                $form.Size = New-Object System.Drawing.Size(300,300) 
                $form.StartPosition = "CenterScreen"

                $OKButton = New-Object System.Windows.Forms.Button
                $OKButton.Location = New-Object System.Drawing.Point(75,220)
                $OKButton.Size = New-Object System.Drawing.Size(75,23)
                $OKButton.Text = "OK"
                $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $form.AcceptButton = $OKButton
                $form.Controls.Add($OKButton)

                $CancelButton = New-Object System.Windows.Forms.Button
                $CancelButton.Location = New-Object System.Drawing.Point(150,220)
                $CancelButton.Size = New-Object System.Drawing.Size(75,23)
                $CancelButton.Text = "Cancel"
                $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                $form.CancelButton = $CancelButton
                $form.Controls.Add($CancelButton)

                $label = New-Object System.Windows.Forms.Label
                $label.Location = New-Object System.Drawing.Point(10,20) 
                $label.Size = New-Object System.Drawing.Size(280,20) 
                $label.Text = "Please select a wireless network:"
                $form.Controls.Add($label) 

                $listBox = New-Object System.Windows.Forms.ListBox 
                $listBox.Location = New-Object System.Drawing.Point(10,40) 
                $listBox.Size = New-Object System.Drawing.Size(260,20) 
                $listBox.Height = 80


                ForEach ($SSID in $SSIDS) {
                [void] $listBox.Items.Add("$($SSID.SSID)")
                }
                $form.Controls.Add($listBox) 

                $label = New-Object System.Windows.Forms.Label
                $label.Location = New-Object System.Drawing.Point(10,140) 
                $label.Size = New-Object System.Drawing.Size(280,20) 
                $label.Text = "Please enter Network Password:"
                $form.Controls.Add($label) 

                $textBox = New-Object System.Windows.Forms.TextBox 
                $textBox.Location = New-Object System.Drawing.Point(10,160) 
                $textBox.Size = New-Object System.Drawing.Size(260,20) 
                $form.Controls.Add($textBox) 

                $form.Topmost = $True

                $result = $form.ShowDialog()

                if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SSID = $listBox.SelectedItem
                    $PSKText = $textBox.Text
                    
                }

                Set-WiFi -SSID $SSID -PSK $PSKText
                Restart-Service -Name WlanSvc
                Start-Sleep -Seconds 10
                if (Test-WebConnection google.com){
                    Write-Output "Device is now online via WiFi"
                }
                else {
                    Write-Output "Unable to connect Device to Internet"
                }
            }
        }
    }


    <# Didn't work in Specialize
    if ($ExtrasJSON){
        write-host "Specialize Stage - Extra Addons" -ForegroundColor Green
        $WarningPreference = "SilentlyContinue"
        $VerbosePreference = "SilentlyContinue"
        #Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com')
        if ($ExtrasJSON.Addons.NetFx3 -eq $true){
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor DarkGray "Installing NetFX3"
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1')
            osdcloud-NetFX
        }
    }
    #>
    if ($ExtrasJSON){
        write-host "Specialize Stage - Extra Addons" -ForegroundColor Green
        $WarningPreference = "SilentlyContinue"
        $VerbosePreference = "SilentlyContinue"
        #Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com')
        if ($ExtrasJSON.Addons.Pause -eq $true){
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor DarkGray "Pausing Specialize"
            Start-Process "cmd.exe" -ArgumentList "start /wait cmd.exe" -wait
        }
    }   
    if (Test-WebConnection -Uri "google.com") {
        Write-Host -ForegroundColor Green "Internet Connection Confirmed"
        Write-Host -ForegroundColor Green "Enabling Vendor Addon Tools"
        if ($HPJson){
            write-host "Specialize Stage - HP Enterprise Devices" -ForegroundColor Green
            $WarningPreference = "SilentlyContinue"
            $VerbosePreference = "SilentlyContinue"
            #Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com')
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
            
            #osdcloud-SetExecutionPolicy -WarningAction SilentlyContinue
            #osdcloud-InstallPackageManagement -WarningAction SilentlyContinue
            #osdcloud-InstallModuleHPCMSL -WarningAction SilentlyContinue
            if ($HPJson.HPUpdates.HPTPMUpdate -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Updating TPM" -ForegroundColor Cyan
                osdcloud-HPTPMEXEInstall
                start-sleep -Seconds 10
            }
            if (($HPJson.HPUpdates.HPBIOSUpdate -eq $true) -and ($HPJson.HPUpdates.HPTPMUpdate -ne $true)){
                #Stage Firmware Update for Next Reboot
                Import-Module HPCMSL -ErrorAction SilentlyContinue | out-null
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host -ForegroundColor Cyan "Updating HP System Firmware"
                if (Get-HPBIOSSetupPasswordIsSet){Write-Host -ForegroundColor Red "Device currently has BIOS Setup Password, Please Update BIOS via different method"}
                else{
                    Write-Host -ForegroundColor DarkGray "Current Firmware: $(Get-HPBIOSVersion)"
                    Write-Host -ForegroundColor DarkGray "Staging Update: $((Get-HPBIOSUpdates -Latest).ver) "
                    #Details: https://developers.hp.com/hp-client-management/doc/Get-HPBiosUpdates
                    Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore
                }
                start-sleep -Seconds 10
            }
            <#
            if ($HPJson.HPUpdates.HPIADrivers -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running HPIA Drivers" -ForegroundColor Cyan
                osdcloud-HPIAOfflineSync
                osdcloud-HPIAExecute -OfflineMode $true
                start-sleep -Seconds 10
            }
            #>
        }
        if ($DellJSON){
            write-host "Specialize Stage - Dell Enterprise Devices" -ForegroundColor Green
            $WarningPreference = "SilentlyContinue"
            #Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com')
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
            if ($DellJSON.Updates.DCUInstall -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Installing Dell Command Update" -ForegroundColor Cyan
                osdcloud-InstallDCU
                start-sleep -Seconds 10
            }            
            if ($DellJSON.Updates.DCUDrivers -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running Dell Command Update - Drivers" -ForegroundColor Cyan
                osdcloud-RunDCU -updateType driver
                start-sleep -Seconds 10
            }    
            if ($DellJSON.Updates.DCUFirmware -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running Dell Command Update - Firmware" -ForegroundColor Cyan
                osdcloud-RunDCU -updateType firmware
                start-sleep -Seconds 10
            }    
            if ($DellJSON.Updates.DCUBIOS -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running Dell Command Update - BIOS" -ForegroundColor Cyan
                osdcloud-RunDCU -updateType bios
                start-sleep -Seconds 10
            }    
            if ($DellJSON.Updates.DCUAutoUpdateEnable -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running Dell Command Update - Set Auto Update Enabled" -ForegroundColor Cyan
                osdcloud-DCUAutoUpdate
                start-sleep -Seconds 10
            }    
        }
    }
    else {
        Write-Warning "Could not validate an Internet connection"  
    }
    #=================================================
    #   Specialize ODT
    #=================================================
    if ((Test-Path "C:\OSDCloud\ODT\setup.exe") -and (Test-Path "C:\OSDCloud\ODT\Config.xml")) {
        Write-Verbose "ODT: Disable Telemetry"
        reg add HKCU\Software\Policies\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d 1 /f

        Write-Verbose "ODT: Installing Microsoft Office"
        #Start-Process -WorkingDirectory 'C:\OSDCloud\ODT' -FilePath 'setup.exe' -ArgumentList "/configure","Config.xml" -Wait -Verbose
        & C:\OSDCloud\ODT\setup.exe /configure C:\OSDCloud\ODT\Config.xml

        Write-Verbose "ODT: Enable Telemetry"
        reg add HKCU\Software\Policies\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d 0 /f
    }
    #=================================================
    #	Stop-Transcript
    #=================================================
    Stop-Transcript
    
    #=================================================
    #=================================================
    #   Complete
    #   Give a fair amount of time to display errors
    #=================================================
    Start-Sleep -Seconds 10
    #=================================================
}
