function Initialize-OSDCloudStartnet {
    [CmdletBinding()]
    param (
        [switch] $WirelessConnect
    )
    if ($env:SystemDrive -eq 'X:') {
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