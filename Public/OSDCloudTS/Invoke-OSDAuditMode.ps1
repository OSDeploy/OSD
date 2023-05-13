function Invoke-OSDAuditMode {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Apply
    )
    #=================================================
    #   UserAudit
    #=================================================
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
 
    if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {

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
    
    Write-Output "ImageState = $ImageState"
    #endregion

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
            write-host "User Audit Stage - HP Enterprise Devices" -ForegroundColor Green
            $WarningPreference = "SilentlyContinue"
            $VerbosePreference = "SilentlyContinue"
            #Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com')
            Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
            
            #osdcloud-SetExecutionPolicy -WarningAction SilentlyContinue
            #osdcloud-InstallPackageManagement -WarningAction SilentlyContinue
            #osdcloud-InstallModuleHPCMSL -WarningAction SilentlyContinue
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
            if ($HPJson.HPUpdates.HPIADrivers -eq $true){
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Write-Host "Running HPIA Drivers" -ForegroundColor Cyan
                #osdcloud-HPIAOfflineSync
                osdcloud-HPIAExecute
                start-sleep -Seconds 10
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
