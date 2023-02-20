function Initialize-OSDCloudStartnet {
    [CmdletBinding()]
    param (
        [switch] $WirelessConnect
    )
    if ($env:SystemDrive -eq 'X:') {
        #region
        #==================================================================================================
        #OSDCloud Config Startup Scripts
        #==================================================================================================

        <#
        David Segura
        22.11.11.1
        These scripts will be in the OSDCloud Workspace in Config\Scripts\StartNet
        When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
        In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\*
        #>
        $Global:ScriptStartNet = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\StartNet\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
        }
        if ($Global:ScriptStartNet) {
            Write-Host -ForegroundColor Gray 'OSDCloud Config StartNet Scripts'
            $Global:ScriptStartNet = $Global:ScriptStartNet | Sort-Object -Property FullName
            foreach ($Item in $Global:ScriptStartNet) {
                Write-Host -ForegroundColor Gray "$($Item.FullName)"
                & "$($Item.FullName)"
            }
        }
        #endregion
        #=================================================
        #   Initialize Splash Screen
        #=================================================  
        #Looks for SPLASH.JSON files in OSDCloud\Config, if found, it will run a splash screen.
        $Global:SplashScreen = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Config\" -Include "SPLASH.JSON" -File -Recurse -Force -ErrorAction Ignore
        }
        if ($Global:SplashScreen) {
            Write-Host -ForegroundColor Gray 'OSDCloud Config StartNet Scripts'
            $Global:SplashScreen = $Global:SplashScreen | Sort-Object -Property FullName
            foreach ($Item in $Global:SplashScreen) {
                Write-Host -ForegroundColor DarkGray "Found: $($Item.FullName)"
            }
            if ($Global:SplashScreen.count -gt 1){
                $SplashJson = $Global:SplashScreen | Select-Object -Last 1
                Write-Host -ForegroundColor Gray "Using $($SplashJson.FullName)"
            }
            if (Test-Path -Path "C:\OSDCloud\Logs"){Remove-Item -Path "C:\OSDCloud\Logs" -Recurse -Force}
            if (!(Test-Path -Path "x:\OSDCloud\Logs")){New-Item -Path "x:\OSDCloud\Logs" -ItemType directory -Force | Out-Null}
            Start-Transcript -Path "x:\OSDCloud\Logs\Deploy-OSDCloud.log"
            if (!($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase)){Import-Module -Name OSD}
            if ($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase){
                #$Global:MahAppsPath = "$Global:ModuleBase\Projects\assembly2\MahApps.Metro.dll"
                #$Global:InteractivityPath = "$Global:ModuleBase\Projects\assembly2\System.Windows.Interactivity.dll"
                Write-Host -ForegroundColor Gray "Starting $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1"
                #start-process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1"
                & $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1
            }
        }
        #=================================================
        #   Initialize Hardware Devices
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Hardware Devices"
        Start-Sleep -Seconds 10
        #=================================================
        #   Initialize Wireless Network
        #=================================================
        if (Test-Path "$env:SystemRoot\System32\dmcmnutils.dll") {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Wireless Network"
            if ($WirelessConnect){
                Start-Process PowerShell -ArgumentList 'Start-WinREWiFi -WirelessConnect' -Wait
            }
            else {
                Start-Process PowerShell Start-WinREWiFi -Wait
            }
        }
        #=================================================
        #   Initialize Network Connections
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Network Connections"
        Start-Sleep -Seconds 10
        #=================================================
        #   Update PowerShell Modules
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) PowerShell Modules"
        $PSModuleName = 'OSD'
        $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
        $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

        if ($GalleryPSModule) {
            if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
        }
        #=================================================
        #   Start Minimized PowerShell Session
        #=================================================
        #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start Minimized PowerShell Session"
        Start-Process PowerShell -WindowStyle Minimized
        #=================================================
        #   Complete
        #=================================================
        Import-Module OSD -Force -ErrorAction Ignore -WarningAction Ignore
        $OSDVersion = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        Write-Host -ForegroundColor Green "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud $OSDVersion Ready"
    }
}