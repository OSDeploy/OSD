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
        $Global:OSDCloud.ScriptStartNet = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\StartNet\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
        }
        if ($Global:OSDCloud.ScriptStartNet) {
            Write-SectionHeader 'OSDCloud Config StartNet Scripts'
            $Global:OSDCloud.ScriptStartNet = $Global:OSDCloud.ScriptStartNet | Sort-Object -Property FullName
            foreach ($Item in $Global:OSDCloud.ScriptStartNet) {
                Write-DarkGrayHost "$($Item.FullName)"
                & "$($Item.FullName)"
            }
        }
        #endregion
        
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