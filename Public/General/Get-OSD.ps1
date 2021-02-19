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
    param ()
    
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
    Write-Host -ForegroundColor Cyan        "$GetCommandNoun $GetCommandVersion"
    Write-Host -ForegroundColor DarkCyan    "osd.osdeploy.com"
    Write-Host -ForegroundColor DarkCyan    "Module Path: $GetModulePath"

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.19'
    Write-Host -ForegroundColor Yellow      'Get-OSDDisk                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modified version of Get-Disk with some neat filters'
    Write-Host -ForegroundColor Yellow      'New-OSDDisk (Updated)                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates System | OS | Recovery Partitions for GPT and MBR Drives in WinPE'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.10'
    Write-Host -ForegroundColor Yellow      'Backup-MyBitLockerKeys                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves all BitLocker ExternalKeys (BEK), KeyPackages (KPG), and RecoveryPasswords (TXT)'
    Write-Host -ForegroundColor Yellow      'Get-MyBitLockerKeyProtectors           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Object of BitLocker KeyProtectors and RecoveryPasswords'
    Write-Host -ForegroundColor Yellow      'Save-MyBitLockerExternalKey            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves ExternalKey BEK files to a Path'
    Write-Host -ForegroundColor Yellow      'Save-MyBitLockerKeyPackage             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves a key package for a drive for corrupt recovery'
    Write-Host -ForegroundColor Yellow      'Save-MyBitLockerRecoveryPassword       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves RecoveryPassword TXT files to a Path'
    Write-Host -ForegroundColor Yellow      'Unlock-MyBitLockerExternalKey          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.9'
    Write-Host -ForegroundColor Yellow      'Copy-PSModuleToWim                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a Windows Image .wim file'
    Write-Host -ForegroundColor Yellow      'Copy-PSModuleToWindowsImage            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a mounted Windows Image'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.8'
    Write-Host -ForegroundColor Yellow      'Get-MyWindowsCapability                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsCapability'
    Write-Host -ForegroundColor Yellow      'Get-MyWindowsPackage                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsPackage'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.3'
    Write-Host -ForegroundColor Yellow      'Get-ComObjects                         ' -NoNewline
    Write-Host -ForegroundColor Gray        'List of (mostly all) of the system ComObjects'
    Write-Host -ForegroundColor Yellow      'Get-ComObjMicrosoftUpdateAutoUpdate    ' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.AutoUpdate).Settings'
    Write-Host -ForegroundColor Yellow      'Get-ComObjMicrosoftUpdateInstaller     ' -NoNewline
    Write-Host -ForegroundColor Gray        'New-Object -ComObject Microsoft.Update.Installer'
    Write-Host -ForegroundColor Yellow      'Get-ComObjMicrosoftUpdateServiceManager' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.ServiceManager).Services'
    Write-Host -ForegroundColor Yellow      'Get-MyComputerManufacturer             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Manufacturer'
    Write-Host -ForegroundColor Yellow      'Get-MyComputerModel                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Model'
    Write-Host -ForegroundColor Yellow      'Get-MyBiosSerialNumber                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Serial Number'
    Write-Host -ForegroundColor Yellow      'Get-MyDefaultAUService                 ' -NoNewline
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
    Write-Host -ForegroundColor Yellow      'Set-DisRes                             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the Primary Display Screen Resolution'
    Write-Host -ForegroundColor Yellow      'Copy-PSModuleToFolder                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a specified Destination'
    Write-Host -ForegroundColor Yellow      'Get-ScreenPNG                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Takes a screeshot'
    Write-Host -ForegroundColor White       'Set-ClipboardScreenshot                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets a Screenshot of the Primary Screen on the Clipboard'
    Write-Host -ForegroundColor White       'Save-ClipboardImage                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves the Clipboard Image as a file.  PNG extension is recommended'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.1'
    Write-Host -ForegroundColor Yellow      'Set-WimExecutionPolicy                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a .wim File'
    Write-Host -ForegroundColor Yellow      'Set-WindowsImageExecutionPolicy        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a Mounted Windows Image'

    Write-Host -ForegroundColor DarkCyan    '================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.1.29'
    Write-Host -ForegroundColor Yellow      'Backup-DiskToFFU                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Captures a Windows Image FFU to a secondary drive'
    Write-Host -ForegroundColor White       'Get-DiskWithSystemPartition                       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Gets the Disk containing the SYSTEM partition'

    Write-Host -ForegroundColor DarkCyan    '==================================' -NoNewline
    Write-Host -ForegroundColor Cyan        'OLDER'
    Write-Host -ForegroundColor White       'Dismount-MyWindowsImage                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Dismounts WIM by Mounted Path, or all WIMs if no Path is specified'
    Write-Host -ForegroundColor White       'Edit-MyWindowsImage                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modify an Online or Offline Windows Image with Cleanup and Appx Stuff'
    Write-Host -ForegroundColor White       'Get-OSDDriver                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns Driver download links for Amd Dell Hp Intel and Nvidia'
    Write-Host -ForegroundColor White       'Get-OSDDriverWmiQ                      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Select multiple Dell or HP Computer Models to generate WMI Query'
    Write-Host -ForegroundColor White       'Get-OSDWinPE                           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery'
<#     Write-Host -ForegroundColor White       'Initialize-DiskOSD                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Initializes a Disk' #>
    Write-Host -ForegroundColor White       'Mount-MyWindowsImage                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Give it a WIM, let it mount it'
<#     Write-Host -ForegroundColor White       'New-PartitionOSDSystem                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a SYSTEM Partition'
    Write-Host -ForegroundColor White       'New-PartitionOSDWindows                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates a WINDOWS Partition' #>
    Write-Host -ForegroundColor White       'Update-MyWindowsImage                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Identify, Download, and Apply Updates to a Mounted Windows Image'
    Write-Host -ForegroundColor DarkCyan    '======================' -NoNewline
    Write-Host -ForegroundColor Cyan        'UPDATE THE MODULE'
    Write-Host -ForegroundColor Yellow      'Update-Module OSD -Force'
    #======================================================================================================
}