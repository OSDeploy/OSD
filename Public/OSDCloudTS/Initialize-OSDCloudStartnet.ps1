<#
.SYNOPSIS
    Initializes the OSDCloud startnet environment.

.DESCRIPTION
    This function initializes the OSDCloud startnet environment by performing the following tasks:
    - Creates a log path if it does not already exist.
    - Copies OSDCloud config startup scripts to the mounted WinPE.
    - Initializes a splash screen if a SPLASH.JSON file is found in OSDCloud\Config.
    - Initializes hardware devices.
    - Initializes wireless network (optional).
    - Initializes network connections.
    - Updates PowerShell modules.

.PARAMETER WirelessConnect
    Specifies whether to connect to a wireless network. If this switch is specified, the function will attempt to connect to a wireless network using the Start-WinREWiFi function.

.EXAMPLE
    Initialize-OSDCloudStartnet -WirelessConnect
    Initializes the OSDCloud startnet environment and attempts to connect to a wireless network.
#>
function Initialize-OSDCloudStartnet {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        $WirelessConnect,

        [System.Management.Automation.SwitchParameter]
        $WifiProfile
    )

    # Make sure we are in WinPE
    if ($env:SystemDrive -eq 'X:') {
        # Get the start time
        $Global:StartnetStart = Get-Date
    
        # Export the Global Variable so it can be used in other PowerShell sessions
        $Global:StartnetStart | Export-Clixml -Path "$env:TEMP\StartnetStart.xml" -Force

        # Create the log path if it does not already exist
        $LogsPath = "$env:SystemDrive\OSDCloud\Logs"
        if (-NOT (Test-Path -Path $LogsPath)) {
            New-Item -Path $LogsPath -ItemType Directory -Force | Out-Null
        }

        # Initialize-OSDCloudStartnet
        $TimeSpan = New-TimeSpan -Start $Global:StartnetStart -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize-OSDCloudStartnet"

        # Delay for 5 seconds to allow the hardware to initialize
        Start-Sleep -Seconds 5

        <#
        OSDCloud Config Startup Scripts
        These scripts will be in the OSDCloud Workspace in Config\Scripts\StartNet
        When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
        In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\*
        #>
        Write-Host -ForegroundColor Cyan '[i] Config StartNet Scripts'
        $Global:ScriptStartNet = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
            Write-Host -ForegroundColor DarkGray "$($_.Root)OSDCloud\Config\Scripts\StartNet\*.ps1"
            Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\StartNet\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
        }
        if ($Global:ScriptStartNet) {
            $Global:ScriptStartNet = $Global:ScriptStartNet | Sort-Object -Property FullName
            foreach ($Item in $Global:ScriptStartNet) {
                Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
                & "$($Item.FullName)"
            }
        }

        # Initialize Splash Screen  
        # Looks for SPLASH.JSON files in OSDCloud\Config, if found, it will run a splash screen.
        Write-Host -ForegroundColor Cyan '[i] Splash Screen Configuration'
        $Global:SplashScreen = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
            Write-Host -ForegroundColor DarkGray "$($_.Root)OSDCloud\Config\SPLASH.JSON"
            Get-ChildItem "$($_.Root)OSDCloud\Config\" -Include "SPLASH.JSON" -File -Recurse -Force -ErrorAction Ignore
        }

        if ($Global:SplashScreen) {
            $Global:SplashScreen = $Global:SplashScreen | Sort-Object -Property FullName
            foreach ($Item in $Global:SplashScreen) {
                Write-Host -ForegroundColor Gray "Apply $($Item.FullName)"
            }
            if ($Global:SplashScreen.count -gt 1) {
                $SplashJson = $Global:SplashScreen | Select-Object -Last 1
                Write-Host -ForegroundColor DarkGray "Multiple Splash Screen configurations, using $($Item.FullName)"
            }
            if (Test-Path -Path "C:\OSDCloud\Logs") {
                Remove-Item -Path "C:\OSDCloud\Logs" -Recurse -Force
            }
            Start-Transcript -Path "X:\OSDCloud\Logs\Deploy-OSDCloud.log"
            if (-NOT ($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase)) {
                Import-Module OSD -Force -ErrorAction Ignore -WarningAction Ignore
            }
            if ($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase) {
                # Write-Host -ForegroundColor DarkGray "Starting $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1"
                & $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1
            }
        }

        # Initialize Wireless Networking
        if (Test-Path "$env:SystemRoot\System32\dmcmnutils.dll") {
            $TimeSpan = New-TimeSpan -Start $Global:StartnetStart -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Wireless Networking"
            if ($WirelessConnect) {
                Start-Process PowerShell -ArgumentList 'Start-WinREWiFi -WirelessConnect' -Wait
            }
            elseif ($WifiProfile) {
                $Global:WifiProfile = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
                    Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts" -Include "WiFiProfile.xml" -File -Recurse -Force -ErrorAction Ignore
                }

                Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Using the WiFi Profile: $($Global:WifiProfile)"
                Start-Process PowerShell -ArgumentList "Start-WinREWiFi -WifiProfile `"$Global:WifiProfile`"" -Wait
            }
            else {
                Start-Process PowerShell Start-WinREWiFi -Wait
            }
        }

        # Wait for the network to initialize
        $TimeSpan = New-TimeSpan -Start $Global:StartnetStart -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Network Connections"
        $timeout = 0
        while ($timeout -lt 20) {
            Start-Sleep -Seconds $timeout
            $timeout = $timeout + 5

            $IP = Test-Connection -ComputerName $(HOSTNAME) -Count 1 | Select-Object -ExpandProperty IPV4Address
            if ($null -eq $IP) {
                Write-Host -ForegroundColor DarkGray "Network adapter error. This should not happen !"
            }
            elseif ($IP.IPAddressToString.StartsWith("169.254") -or $IP.IPAddressToString.Equals("127.0.0.1")) {
                Write-Host -ForegroundColor DarkGray "IP address not yet assigned by DHCP. Trying to get a new DHCP lease.."
                ipconfig /release | Out-Null
                ipconfig /renew | Out-Null
            }
            else {
                Write-Host -ForegroundColor DarkGray "Network configuration renewed with IP: $($IP.IPAddressToString)"
                break
            }
        }
        # PACHED START
        if (Test-WebConnection -Uri "google.com") {
            Write-Host -ForegroundColor Cyan '[i] Config Post StartNet Scripts'
            $Global:ScriptStartNet2 = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
                Write-Host -ForegroundColor DarkGray "$($_.Root)OSDCloud\Config\Scripts\StartNet2\*.ps1"
                Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\StartNet2\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
            }
            if ($Global:ScriptStartNet2) {
                $Global:ScriptStartNet2 = $Global:ScriptStartNet2 | Sort-Object -Property FullName
                foreach ($Item in $Global:ScriptStartNet2) {
                    Write-Host -ForegroundColor Gray "Execute $($Item.FullName)"
                    & "$($Item.FullName)"
                }
                $TimeSpan = New-TimeSpan -Start $Global:StartnetStart -End (Get-Date)
                Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Tried to execute Post StartNet Scripts" 
            }
        }
        if ($Global:SkipOSDModuleInstall) {
            Write-Host -ForegroundColor DarkGray "Skip Installing newer OSD PowerShell Module"
            return
        }
        # PATCHED END
        # Check if the OSD Module in the PowerShell Gallery is newer than the installed version
        $TimeSpan = New-TimeSpan -Start $Global:StartnetStart -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Updating OSD PowerShell Module"
        $PSModuleName = 'OSD'
        $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
        $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

        # Install the OSD module if it is not installed or if the version is older than the gallery version
        if ($GalleryPSModule) {
            if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
                Write-Host -ForegroundColor DarkGray "$PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
                Import-Module $PSModuleName -Force
            }
        }
    }
}
