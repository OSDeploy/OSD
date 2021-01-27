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
    #======================================================================================================
    #	Gather
    #======================================================================================================
    $GetCommandNoun = Get-Command -Name Get-OSD | Select-Object -ExpandProperty Noun
    $GetCommandVersion = Get-Command -Name Get-OSD | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name Get-OSD | Select-Object -ExpandProperty HelpUri
    $GetCommandModule = Get-Command -Name Get-OSD | Select-Object -ExpandProperty Module
    $GetModuleDescription = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Description
    $GetModuleProjectUri = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty ProjectUri
    $GetModulePath = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Path
    #======================================================================================================
    #	Usage
    #======================================================================================================
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        "$GetCommandNoun $GetCommandVersion http://osd.osdeploy.com"
    Write-Host -ForegroundColor DarkCyan    $GetModuleDescription
    Write-Host -ForegroundColor DarkCyan    "Module Path: $GetModulePath"
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'Functions'
    Write-Host -ForegroundColor White       'Get-OSD                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'This information'
    Write-Host -ForegroundColor White       'Get-OSDClass               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns CimInstance information from common OSD Classes'
    Write-Host -ForegroundColor White       'Get-OSDGather              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns common OSD information as an ordered hash table'
    Write-Host -ForegroundColor White       'Get-OSDPower               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Displays Power Plan information using powercfg /LIST'
    Write-Host -ForegroundColor White       'Get-OSDWinPE               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery'
    Write-Host -ForegroundColor White       'Get-SessionsXml            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Session.xml Updates that have been applied to an Operating System'
    Write-Host -ForegroundColor White       'Get-RegCurrentVersion      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    Write-Host -ForegroundColor White       'Save-OSDDownload           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Downloads a file by URL to a destination folder'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'Appx Functions'
    Write-Host -ForegroundColor White       'Remove-AppxOnline          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Removes Appx Packages and Appx Provisioned Packages for All Users'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'Driver Functions'
    Write-Host -ForegroundColor White       'Get-OSDDriver              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Driver download links for Amd Dell Hp Intel and Nvidia'
    Write-Host -ForegroundColor White       'Get-OSDDriverWmiQ          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Select multiple Dell or HP Computer Models to generate a proper Task Sequence WMI Query'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'Disk Functions'
    Write-Host -ForegroundColor White       'New-OSDDisk                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE'
    Write-Host -ForegroundColor White       'Initialize-DiskOSD         ' -NoNewline
    Write-Host -ForegroundColor Gray        ''
    Write-Host -ForegroundColor White       'New-PartitionOSDSystem     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a SYSTEM Partition'
    Write-Host -ForegroundColor White       'New-PartitionOSDWindows    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a WINDOWS Partition'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'WindowsImage Functions'
    Write-Host -ForegroundColor White       'Mount-WindowsImageOSD      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Give it a WIM, let it mount it'
    Write-Host -ForegroundColor White       'Edit-WindowsImageOSD       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modify an Online or Offline Windows Image with Cleanup and Appx Stuff'
    Write-Host -ForegroundColor White       'Update-WindowsImageOSD     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Identify, Download, and Apply Updates to a Mounted Windows Image'
    Write-Host -ForegroundColor White       'Dismount-WindowsImageOSD   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Dismounts WIM by Mounted Path, or all WIMs if no Path is specified'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    Write-Host -ForegroundColor Cyan        'Module Functions'
    Write-Host -ForegroundColor White       'Update-Module OSD -Force   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Updates the OSD Module'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================='
    #======================================================================================================
}