function Invoke-OSDSpecialize {
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
    #   Specialize DriverPacks
    #=================================================
    if (Test-Path 'C:\Drivers') {
        $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

        foreach ($Item in $DriverPacks) {
            $ExpandFile = $Item.FullName
            Write-Verbose -Verbose "DriverPack: $ExpandFile"
            #=================================================
            #   Cab
            #=================================================
            if ($Item.Extension -eq '.cab') {
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName
    
                if (-NOT (Test-Path "$DestinationPath")) {
                    New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                    Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                    Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null

                    if ($Apply) {
                        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                        pnpunattend.exe AuditSystem /L
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                    }
                }
                Continue
            }
            #=================================================
            #   Dell
            #=================================================
            if ($Item.Extension -eq '.exe') {
                if ($Item.VersionInfo.FileDescription -match 'Dell') {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                    $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding Dell Driver Pack to $DestinationPath"
                        $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                        Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait

                        if ($Apply) {
                            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                            pnpunattend.exe AuditSystem /L
                            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                        }
                    }
                    Continue
                }
            }
            #=================================================
            #   HP
            #=================================================
            if ($Item.Extension -eq '.exe') {
                if (($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($Item.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($Item.VersionInfo.FileDescription -like "HP *")) {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "InternalName: $($Item.VersionInfo.InternalName)"
                    Write-Verbose -Verbose "OriginalFilename: $($Item.VersionInfo.OriginalFilename)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"
                    
                    $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait

                        if ($Apply) {
                            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                            pnpunattend.exe AuditSystem /L
                            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                        }
                    }
                    Continue
                }
            }
            #=================================================
            #   Lenovo
            #=================================================
            if ($Item.Extension -eq '.exe') {
                if (($Item.VersionInfo.FileDescription -match 'Lenovo') -or ($Item.Name -match 'tc_') -or ($Item.Name -match 'tp_') -or ($Item.Name -match 'ts_') -or ($Item.Name -match '500w') -or ($Item.Name -match 'sccm_') -or ($Item.Name -match 'm710e') -or ($Item.Name -match 'tp10') -or ($Item.Name -match 'tp8') -or ($Item.Name -match 'yoga')) {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                    $DestinationPath = Join-Path $Item.Directory 'SCCM'

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait

                        if ($Apply) {
                            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                            pnpunattend.exe AuditSystem /L
                            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                        }
                    }
                    Continue
                }
            }
            #=================================================
            #   MSI
            #=================================================
            if ($Item.Extension -eq '.msi') {
                $DateStamp = Get-Date -Format yyyyMMddTHHmmss
                $logFile = '{0}-{1}.log' -f $ExpandFile,$DateStamp
                $MSIArguments = @(
                    "/i"
                    ('"{0}"' -f $ExpandFile)
                    "/qb"
                    "/norestart"
                    "/L*v"
                    $logFile
                )
                Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
                Continue
            }
            #=================================================
            #   Zip
            #=================================================
            if ($Item.Extension -eq '.zip') {
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                    Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                
                    if ($Apply) {
                        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                        pnpunattend.exe AuditSystem /L
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                    }
                }
                Continue
            }
            #=================================================
            #   Json
            #=================================================
            if ($Item.Extension -eq '.json') {
                #Do Nothing
                Continue
            }
            #=================================================
            #   TXT
            #=================================================
            if ($Item.Extension -eq '.txt') {
                #Do Nothing
                Continue
            }
            #=================================================
            #   Everything Else
            #=================================================
            Write-Warning "File cannot be expanded $ExpandFile"
            Write-Verbose -Verbose ""
            #=================================================
        }
    }
    #=================================================
    #   Specialize Config HP & Dell JSON
    #=================================================
    $ConfigPath = "c:\osdcloud\configs"
    if (Test-Path $ConfigPath){
        $JSONConfigs = Get-ChildItem -path $ConfigPath -Filter "*.json"
        if ($JSONConfigs.name -contains "HP.JSON"){
            $HPJson = Get-Content -Path "$ConfigPath\HP.JSON" |ConvertFrom-Json
        }
        if ($JSONConfigs.name -contains "Dell.JSON"){
            $DellJSON = Get-Content -Path "$ConfigPath\DELL.JSON" |ConvertFrom-Json
        }
    }
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
    #	Start-IntuneAutoPilotConnection
    #=================================================
    #Load OSDCloud Functions
    Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
    
    #Get Autopilot information from the device
    $TestAutopilotProfile = osdcloud-TestAutopilotProfile

    #If the device has an Autopilot Profile
    if ($TestAutopilotProfile -eq $true) {
        #osdcloud-ShowAutopilotProfile
    }
    #If not, need to register the device using the Enterprise GroupTag and Assign it
    elseif ($TestAutopilotProfile -eq $false) {
        $AutopilotRegisterCommand = 'Get-WindowsAutopilotInfo -Online -GroupTag Enterprise -Assign'
        $AutopilotRegisterProcess = osdcloud-AutopilotRegisterCommand -Command $AutopilotRegisterCommand;Start-Sleep -Seconds 30
    }
    #Or maybe we just can't figure it out
    else {
        Write-Warning 'Unable to determine if device is Autopilot registered'
    }
    if ($AutopilotRegisterProcess) {
        Write-Host -ForegroundColor Cyan 'Waiting for Autopilot Registration to complete'
        #$AutopilotRegisterProcess.WaitForExit()
        if (Get-Process -Id $AutopilotRegisterProcess.Id -ErrorAction Ignore) {
            Wait-Process -Id $AutopilotRegisterProcess.Id
        }
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
