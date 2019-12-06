<#
.SYNOPSIS
Displays information about the OSD Module

.DESCRIPTION
Displays information about the OSD Module

.LINK
https://osd.osdeploy.com/module/functions/get-osd

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSD {
    [CmdletBinding()]
    Param ()
    #==================================================
    #   Defaults
    #==================================================
    $Info = $true
    #==================================================
    #   Info
    #==================================================
    if ($Info) {
        $OSDModuleVersion = $($MyInvocation.MyCommand.Module.Version)
        Write-Host "#OSDmodule PowerShell Library $OSDModuleVersion" -ForegroundColor Green
        Write-Host "http://osd.osdeploy.com/release" -ForegroundColor Cyan
        Write-Host
        Write-Host 'Functions' -ForegroundColor Green
        Write-Host 'Get-OSD - This information'
        Write-Host 'Get-OSDClass - Returns CimInstance information from common OSD Classes'
        Write-Host 'Get-OSDDrivers - Returns Driver download links for Amd Dell Hp Intel and Nvidia'
        Write-Host 'Get-OSDGather - Returns common OSD information as an ordered hash table'
        Write-Host 'Get-OSDPower - Displays Power Plan information using powercfg /LIST'
        Write-Host 'Get-OSDSessions - Returns the Session.xml Updates that have been applied to an Operating System'
        Write-Host 'Get-OSDWinPE - Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery'
        Write-Host 'Get-RegCurrentVersion - Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        Write-Host 'New-OSDDisk - Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE'
        Write-Host 'Save-OSDDownload - Downloads a file by URL to a destionation folder'
        Write-Host
        Write-Host 'Windows Image Functions' -ForegroundColor Green
        Write-Host 'Mount-OSDWindowsImage - Give it a WIM, let it do the rest'
        Write-Host 'Update-OSDWindowsImage - Identify, Download, and Apply Updates to a Mounted Windows Image'
        Write-Host
        Write-Host 'Update' -ForegroundColor Green
        Write-Host 'Update-Module OSD -Force'
        Write-Host
        Write-Host "#OSDdevteam" -ForegroundColor Green
        Write-Host "Andrew Jimenez " -NoNewline
        Write-Host "@AndrewJimenez_" -ForegroundColor Cyan
        Write-Host "Ben Whitmore " -NoNewline
        Write-Host "@byteben" -ForegroundColor Cyan
        Write-Host "David Segura " -NoNewline
        Write-Host "@SeguraOSD #MMSJazz" -ForegroundColor Cyan
        Write-Host "Donna Ryan " -NoNewline
        Write-Host "@TheNotoriousDRR #MMSJazz" -ForegroundColor Cyan
        Write-Host "Gary Blok " -NoNewline
        Write-Host "@gwblok #MMSJazz" -ForegroundColor Cyan
        Write-Host "Jerome Bezet-Torres " -NoNewline
        Write-Host "@JM2K69" -ForegroundColor Cyan
        Write-Host "Manel Rodero " -NoNewline
        Write-Host "@manelrodero" -ForegroundColor Cyan
        Write-Host "Nathan Bridges " -NoNewline
        Write-Host "@nathanjbridges" -ForegroundColor Cyan
    }
}