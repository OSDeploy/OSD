<#
.SYNOPSIS
Displays information about the OSD Module

.DESCRIPTION
Displays information about the OSD Module

.LINK
https://osd.osdeploy.com/module/functions/general/get-osd

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
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        "$GetCommandNoun $GetCommandVersion http://osd.osdeploy.com"
    Write-Host -ForegroundColor DarkCyan    $GetModuleDescription
    Write-Host -ForegroundColor DarkCyan    "Module Path: $GetModulePath"
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'General Functions'

    Write-Host -ForegroundColor White       'Get-OSD                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'This information'

    Write-Host -ForegroundColor White       'Get-OSDClass                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns CimInstance information from common OSD Classes'

    Write-Host -ForegroundColor White       'Get-OSDGather                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns common OSD information as an ordered hash table'

    Write-Host -ForegroundColor White       'Get-OSDPower                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Displays Power Plan information using powercfg /LIST'

    Write-Host -ForegroundColor White       'Get-RegCurrentVersion              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Registry Key values from'

    Write-Host -ForegroundColor Yellow      '                                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

    Write-Host -ForegroundColor White       'Get-SessionsXml                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Session.xml Updates that have been applied to an Operating System'

    Write-Host -ForegroundColor White       'Save-OSDDownload                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Downloads a file by URL to a destination folder'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Appx Functions'

    Write-Host -ForegroundColor White       'Remove-AppxOnline                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Removes Appx Packages and Appx Provisioned Packages for All Users'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Backup Functions'

    Write-Host -ForegroundColor Yellow      'Backup-DiskToFFU                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Captures a Windows Image FFU to a secondary drive'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Dism Functions'

    Write-Host -ForegroundColor White       'Dismount-WindowsImageOSD           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Dismounts WIM by Mounted Path, or all WIMs if no Path is specified'

    Write-Host -ForegroundColor White       'Edit-WindowsImageOSD               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modify an Online or Offline Windows Image with Cleanup and Appx Stuff'

    Write-Host -ForegroundColor White       'Mount-WindowsImageOSD              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Give it a WIM, let it mount it'

    Write-Host -ForegroundColor Yellow      'Set-WIMExecutionPolicy             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a .wim File'

    Write-Host -ForegroundColor Yellow      'Set-WindowsImageExecutionPolicy    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a Mounted Windows Image'

    Write-Host -ForegroundColor White       'Update-WindowsImageOSD             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Identify, Download, and Apply Updates to a Mounted Windows Image'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Display Functions'

    Write-Host -ForegroundColor Yellow      'Get-CIMVideoControllerResolution   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the CIM_VideoControllerResolution Properties for the Primary Screen'
    
    Write-Host -ForegroundColor Yellow      'Get-DisplayAllScreens              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.Screen]::AllScreens'
    
    Write-Host -ForegroundColor Yellow      'Get-DisplayPrimaryBitmapSize       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Calulates the Bitmap Screen Size (PrimaryMonitorSize x ScreenScaling)'

    Write-Host -ForegroundColor Yellow      'Get-DisplayPrimaryMonitorSize      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize'
    
    Write-Host -ForegroundColor Yellow      'Get-DisplayPrimaryScaling          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Primary Screen Scaling in Percent'
    
    Write-Host -ForegroundColor Yellow      'Get-DisplayVirtualScreen           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.SystemInformation]::VirtualScreen'
    
    Write-Host -ForegroundColor Yellow      'Set-DisRes                         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the Primary Display Screen Resolution'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Driver Functions'
    Write-Host -ForegroundColor White       'Get-OSDDriver                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Driver download links for Amd Dell Hp Intel and Nvidia'
    Write-Host -ForegroundColor White       'Get-OSDDriverWmiQ                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Select multiple Dell or HP Computer Models to generate WMI Query'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'PowerShellGet Functions'
    Write-Host -ForegroundColor Yellow      'Copy-ModuleToFolder                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a specified Destination'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Storage Functions'
    Write-Host -ForegroundColor Yellow      'Get-DiskIsBoot                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Gets the Disk containing the BOOT partition'
    Write-Host -ForegroundColor Yellow      'Get-DiskIsSystem                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Gets the Disk containing the SYSTEM partition'
    Write-Host -ForegroundColor Yellow      'Get-DiskToBackup                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Gets Disks that can be backed up'
    Write-Host -ForegroundColor White       'Initialize-DiskOSD                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Initializes a Disk'
    Write-Host -ForegroundColor White       'New-OSDDisk                        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE'
    Write-Host -ForegroundColor White       'New-PartitionOSDSystem             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a SYSTEM Partition'
    Write-Host -ForegroundColor White       'New-PartitionOSDWindows            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a WINDOWS Partition'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'Screenshot Functions'

    Write-Host -ForegroundColor Yellow      'Get-ScreenPNG                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Takes a screeshot'

    Write-Host -ForegroundColor Yellow      'Set-ClipboardScreenshot            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets a Screenshot of the Primary Screen on the Clipboard'
    Write-Host -ForegroundColor Yellow      '                                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Use Save-ClipboardImage to save the PNG'
    
    Write-Host -ForegroundColor Yellow      'Save-ClipboardImage                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves the Clipboard Image as a file.  PNG extension is recommended'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'SystemInformation Functions'
    Write-Host -ForegroundColor Yellow      'Get-EZComputerManufacturer         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns a simple Computer Manufacturer'
    Write-Host -ForegroundColor Yellow      'Get-EZComputerModel                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns a Computer Model'
    Write-Host -ForegroundColor Yellow      'Get-EZComputerSerialNumber         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Serial Number'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Cyan        'WinPE Functions'
    Write-Host -ForegroundColor White       'Get-OSDWinPE                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    Write-Host -ForegroundColor Yellow      'Update-Module OSD -Force           ' -NoNewline
    Write-Host -ForegroundColor Cyan        'Update the OSD Module'
    Write-Host -ForegroundColor DarkCyan    '================================================================================================================'
    #======================================================================================================
}