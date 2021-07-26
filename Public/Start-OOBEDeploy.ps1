function Start-OOBEDeploy {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$CustomProfile,
        [switch]$AddRSAT,
        [switch]$Autopilot,
        [string]$ProductKey,
        [string[]]$RemoveAppx,
        [switch]$UpdateDrivers,
        [switch]$UpdateWindows
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OOBEDeploy"
    #=======================================================================
    #   Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEDeploy.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    #   Custom Profile
    #=======================================================================
    if ($CustomProfile) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy $CustomProfile Custom Profile"
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy Default Profile"
    }
    #=======================================================================
    #   Profile OSD OSDeploy
    #=======================================================================
    if ($CustomProfile -in 'OSD','OSDeploy') {
        $AddRSAT = $true
        $Autopilot = $true
        $UpdateDrivers = $true
        $UpdateWindows = $true
        $RemoveAppx = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
        $ProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'
    }
    #=======================================================================
    #	ProductKey
    #=======================================================================
    if ($ProductKey) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-WindowsEdition Enterprise (ChangePK)"
        Invoke-Exe changepk.exe /ProductKey $ProductKey
        Get-WindowsEdition -Online
    }
    #=======================================================================
    #	AddRSAT
    #=======================================================================
    if ($AddRSAT) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows Capability RSAT"
        $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -eq 'Installed') {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
            else {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
        }
    }
    #=======================================================================
    #	Remove-AppxOnline
    #=======================================================================
    if ($RemoveAppx) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Remove-AppxOnline"

        foreach ($Item in $RemoveAppx) {
            Remove-AppxOnline -Name $Item
        }
    }
    #=======================================================================
    #	UpdateDrivers
    #=======================================================================
    if ($UpdateDrivers) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows Update Drivers"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateDrivers = $false
            }
        }
    }
    if ($UpdateDrivers) {
        Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
    }
    #=======================================================================
    #	Windows Update Software
    #=======================================================================
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows Update Software"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateWindows = $false
            }
        }
    }
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
        Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
    }
    #=======================================================================
    #	Microsoft Update
    #=======================================================================
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft Update"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateWindows = $false
            }
        }
    }
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
        Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
        Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
    }
    #=======================================================================
    #	Stop-Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stop-Transcript"
    Stop-Transcript
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    #   Autopilot
    #=======================================================================
    if ($Autopilot) {
        Install-Module AutopilotOOBE -Force
        Start-AutopilotOOBE
    }
    #=======================================================================
}