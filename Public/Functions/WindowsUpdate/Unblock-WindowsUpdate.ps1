function Unblock-WindowsUpdate {
    <#
    .SYNOPSIS
    Opens Windows Update and checks for WSUS configuration

    .DESCRIPTION
    Opens Windows Update and checks for WSUS configuration

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Sets the Group Policy 'Download repair content and optional features directly from Windows Update instead of Windows Server Update Services (WSUS)'
        #Restarts the Windows Update Service
        #This setting will be enabled after restart by Group Policy
        $DisableWSUS,

        [System.Management.Automation.SwitchParameter]
        #Allows Driver Updates in Windows Update
        $EnableDrivers
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    #=================================================
    #   UseWUServer
    #   Original code from Martin Bengtsson
    #   https://www.imab.dk/deploy-rsat-remote-server-administration-tools-for-windows-10-v2004-using-configmgr-and-powershell/
    #   https://github.com/imabdk/Powershell/blob/master/Install-RSATv1809v1903v1909v2004v20H2.ps1
    #=================================================
    $WUServer = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name WUServer -ErrorAction Ignore).WUServer
    $UseWUServer = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ErrorAction Ignore).UseWuServer
    $WUDrivers = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -ErrorAction Ignore).ExcludeWUDriversInQualityUpdate

    if (($WUServer -ne $null) -and ($UseWUServer -eq 1) -and ($DisableWSUS -eq $false)) {
        Write-Warning "This computer is configured to receive updates from WSUS Server $WUServer"
        Write-Warning "Add the DisableWSUS parameter to update from Windows Update"
    }

    if (($WUDrivers -eq 1) -and ($EnableDrivers -eq $false)) {
        Write-Warning "This computer is not configured to receive Driver updates from Windows Update"
        Write-Warning "Add the EnableDrivers parameter to enable Driver updates from Windows Update"
    }
    #=================================================
    #	Execute
    #=================================================
    if (($DisableWSUS -eq $true) -and ($UseWUServer -eq 1)) {
        Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value 0
    }

    if (($EnableDrivers -eq $true) -and ($WUDrivers -eq 1)) {
        Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Value 0
    }

    if (($DisableWSUS -eq $true) -or ($EnableDrivers -eq $true)) {
        Restart-Service wuauserv
    }

    Write-Host -ForegroundColor Cyan "Start-Process ms-settings:windowsupdate"
    Start-Process ms-settings:windowsupdate
    #=================================================
}