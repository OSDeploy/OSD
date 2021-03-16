<#
.SYNOPSIS
Displays information about the OSD Module

.DESCRIPTION
Displays information about the OSD Module

.LINK
https://osd.osdeploy.com/module/functions/general/get-osd

.NOTES
#>
function Get-OSD {
    [CmdletBinding()]
    param ()
    #======================================================================================================
    #	PSBoundParameters
    #======================================================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #======================================================================================================
    #	Module and Command Information
    #======================================================================================================
    $GetCommandName = $MyInvocation.MyCommand | Select-Object -ExpandProperty Name
    $GetModuleBase = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty ModuleBase
    $GetModulePath = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Path
    $GetModuleVersion = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name $GetCommandName | Select-Object -ExpandProperty HelpUri

    Write-Host "$GetCommandName" -ForegroundColor Cyan -NoNewline
    Write-Host " $GetModuleVersion at $GetModuleBase" -ForegroundColor Gray
    Write-Host "http://osd.osdeploy.com" -ForegroundColor Gray
    #======================================================================================================
    #	Function Information
    #======================================================================================================
    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.3.12'
    Write-Host -ForegroundColor Yellow      '92 Total Functions                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'There is really too many to list now.  Try: Get-Command -Module OSD'


    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.3.12'
    Write-Host -ForegroundColor Yellow      'Edit-MyWinPE                           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Performs many tasks on a WinPE.wim file.  Not good for an OS wim'
    
    Write-Host -ForegroundColor Yellow      'Invoke-WebPSScript                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Replaces Invoke-UrlExpression'

    Write-Host -ForegroundColor Yellow      'Select-AutoPilotJson                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Searches for AutoPilot Jsons and allows you to select one'

    Write-Host -ForegroundColor Yellow      'Test-WebConnection                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Tests if a url is is good'

    Write-Host -ForegroundColor Yellow      'Test-WindowsImage                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns True if ImagePath is a Windows Image'

    Write-Host -ForegroundColor Yellow      'Test-WindowsImageMounted               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns True if ImagePath is Mounted'

    Write-Host -ForegroundColor Yellow      'Test-WindowsImageMountPath             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns True if Path is a Windows Image mount directory'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.3.10'
    Write-Host -ForegroundColor Yellow      'Get-AdkPaths                              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Just a simple helper function to get ADK Variables'
    Write-Host -ForegroundColor Yellow      'New-OSDCloudWinPE                      ' -NoNewline
    Write-Host -ForegroundColor Gray        '[DEV] Creates an OSDCloud ready WinPE from the Windows ADK'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.3.8'
    Write-Host -ForegroundColor Yellow      'Enable-PEWimPSGallery                  ' -NoNewline
    Write-Host -ForegroundColor Gray        '[DEV] Get PowerShell Gallery working in WinPE'
    Write-Host -ForegroundColor White       'Get-LocalPartition                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Partitions on Local Disks'
    Write-Host -ForegroundColor White       'Get-USBPartition                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Partitions on USB Drives'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.3.4'
    Write-Host -ForegroundColor White       'Get-DellCatalogPC                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Downloads the Dell CatalogPC.xml and converts to an PSObject'
    Write-Host -ForegroundColor White       'Get-MyDellBios                         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Gets you information about the latest BIOS Update for your Dell computer'
    Write-Host -ForegroundColor White       'Get-MyDellDriverCab                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'In development'
    Write-Host -ForegroundColor White       'Save-MyDellDriverCab                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'In development'
    Write-Host -ForegroundColor White       'Update-MyDellBios                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Downloads and Installs the lastest Dell BIOS Update for your Dell computer'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.26'
    Write-Host -ForegroundColor White       '[WinPE] Use-WinPEContent               ' -NoNewline
    Write-Host -ForegroundColor Gray        'In development'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.25'
    Write-Host -ForegroundColor White       'Get-USBVolume                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns attached USB Volumes'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.23'
    Write-Host -ForegroundColor White       'Backup-DiskToFFU (Updated)             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Captures a Windows Image FFU to a secondary or network drive'
    Write-Host -ForegroundColor White       'Clear-LocalDisk                        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Allows you to Clear and Initialize multiple Local Disks, now with -Confirm'
    Write-Host -ForegroundColor White       'Clear-USBDisk                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Allows you to Clear and Initialize multiple USB Disks, now with -Confirm'
    Write-Host -ForegroundColor White       'Get-LocalDisk                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Get-OSDDisk -BusTypeNot USB,Virtual'
    Write-Host -ForegroundColor White       'Get-OSDDisk                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'OSD version of Get-Disk with some easy filters'
    Write-Host -ForegroundColor White       'Get-USBDisk                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Get-OSDDisk -BusType USB'
    Write-Host -ForegroundColor White       '[WinPE] New-OSDisk                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates System | OS | Recovery Partitions for GPT and MBR Drives in WinPE'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.10'
    Write-Host -ForegroundColor White       'Backup-MyBitLockerKeys                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves all BitLocker ExternalKeys (BEK), KeyPackages (KPG), and RecoveryPasswords (TXT)'
    Write-Host -ForegroundColor White       'Get-MyBitLockerKeyProtectors           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Object of BitLocker KeyProtectors and RecoveryPasswords'
    Write-Host -ForegroundColor White       'Save-MyBitLockerExternalKey            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves ExternalKey BEK files to a Path'
    Write-Host -ForegroundColor White       'Save-MyBitLockerKeyPackage             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves a key package for a drive for corrupt recovery'
    Write-Host -ForegroundColor White       'Save-MyBitLockerRecoveryPassword       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves RecoveryPassword TXT files to a Path'
    Write-Host -ForegroundColor White       'Unlock-MyBitLockerExternalKey          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.9'
    Write-Host -ForegroundColor White       'Copy-PSModuleToWim                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a Windows Image .wim file'
    Write-Host -ForegroundColor White       'Copy-PSModuleToWindowsImage            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a mounted Windows Image'
    Write-Host -ForegroundColor White       'Dismount-MyWindowsImage (Renamed)      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Dismounts WIM by Mounted Path, or all WIMs if no Path is specified'
    Write-Host -ForegroundColor White       'Edit-MyWindowsImage (Renamed)          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modify an Online or Offline Windows Image with Cleanup and Appx Stuff'
    Write-Host -ForegroundColor White       'Mount-MyWindowsImage (Renamed)         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Give it a WIM, let it mount it'
    Write-Host -ForegroundColor White       'Update-MyWindowsImage (Renamed)        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Identify, Download, and Apply Updates to a Mounted Windows Image'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.8'
    Write-Host -ForegroundColor White       'Get-MyWindowsCapability                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsCapability'
    Write-Host -ForegroundColor White       'Get-MyWindowsPackage                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsPackage'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.3'
    Write-Host -ForegroundColor White       'Get-ComObjects                         ' -NoNewline
    Write-Host -ForegroundColor Gray        'List of (mostly all) of the system ComObjects'
    Write-Host -ForegroundColor White       'Get-ComObjMicrosoftUpdateAutoUpdate    ' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.AutoUpdate).Settings'
    Write-Host -ForegroundColor White       'Get-ComObjMicrosoftUpdateInstaller     ' -NoNewline
    Write-Host -ForegroundColor Gray        'New-Object -ComObject Microsoft.Update.Installer'
    Write-Host -ForegroundColor White       'Get-ComObjMicrosoftUpdateServiceManager' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.ServiceManager).Services'
    Write-Host -ForegroundColor White       'Get-MyComputerManufacturer             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Manufacturer'
    Write-Host -ForegroundColor White       'Get-MyComputerModel                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Model'
    Write-Host -ForegroundColor White       'Get-MyBiosSerialNumber                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Serial Number'
    Write-Host -ForegroundColor White       'Get-MyDefaultAUService                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the default AutoUpdate repo, thanks Ben Whitmore!'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.2'
    Write-Host -ForegroundColor White       'Get-DisplayAllScreens                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.Screen]::AllScreens' 
    Write-Host -ForegroundColor White       'Get-DisplayPrimaryBitmapSize           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Calulates the Bitmap Screen Size (PrimaryMonitorSize x ScreenScaling)'
    Write-Host -ForegroundColor White       'Get-DisplayPrimaryMonitorSize          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize'
    Write-Host -ForegroundColor White       'Get-DisplayPrimaryScaling              ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Primary Screen Scaling in Percent'
    Write-Host -ForegroundColor White       'Get-DisplayVirtualScreen               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns [System.Windows.Forms.SystemInformation]::VirtualScreen'
    Write-Host -ForegroundColor White       'Get-CimVideoControllerResolution       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the CIM_VideoControllerResolution Properties for the Primary Screen'
    Write-Host -ForegroundColor White       'Set-DisRes                             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the Primary Display Screen Resolution'
    Write-Host -ForegroundColor White       'Copy-PSModuleToFolder                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a specified Destination'
    Write-Host -ForegroundColor White       'Get-ScreenPNG                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Takes a screeshot'
    Write-Host -ForegroundColor White       'Set-ClipboardScreenshot                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets a Screenshot of the Primary Screen on the Clipboard'
    Write-Host -ForegroundColor White       'Save-ClipboardImage                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves the Clipboard Image as a file.  PNG extension is recommended'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.1'
    Write-Host -ForegroundColor White       'Set-WimExecutionPolicy                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a .wim File'
    Write-Host -ForegroundColor White       'Set-WindowsImageExecutionPolicy        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a Mounted Windows Image'

    Write-Host -ForegroundColor DarkCyan    '==================================' -NoNewline
    Write-Host -ForegroundColor Cyan        'OLDER'
    Write-Host -ForegroundColor White       'Get-OSDDriver                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Driver download links for Amd Dell Hp Intel and Nvidia'
    Write-Host -ForegroundColor White       'Get-OSDDriverWmiQ                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Select multiple Dell or HP Computer Models to generate WMI Query'
    Write-Host -ForegroundColor White       '[WinPE] Get-OSDWinPE                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery'
<#     Write-Host -ForegroundColor White       'Initialize-DiskOSD                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Initializes a Disk' #>
<#     Write-Host -ForegroundColor White       'New-PartitionOSDSystem                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a SYSTEM Partition'
    Write-Host -ForegroundColor White       'New-PartitionOSDWindows                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a WINDOWS Partition' #>
    Write-Host -ForegroundColor DarkCyan    '======================' -NoNewline
    Write-Host -ForegroundColor Cyan        'UPDATE THE MODULE'
    Write-Host -ForegroundColor Yellow      'Update-Module OSD -Force'
    #======================================================================================================
}