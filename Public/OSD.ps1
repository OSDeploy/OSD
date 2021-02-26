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
    Write-Host -ForegroundColor Cyan        '21.2.26'
    Write-Host -ForegroundColor White      '[WinPE] Use-WinPEContent               ' -NoNewline
    Write-Host -ForegroundColor Gray        'Coming soon'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.25'
    Write-Host -ForegroundColor White      'Get-USBVolume                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns attached USB Volumes'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.23'
    Write-Host -ForegroundColor White      'Backup-DiskToFFU (Updated)             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Captures a Windows Image FFU to a secondary or network drive'
    Write-Host -ForegroundColor White      'Clear-LocalDisk                        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Allows you to Clear and Initialize multiple Local Disks, now with -Confirm'
    Write-Host -ForegroundColor White      'Clear-USBDisk                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Allows you to Clear and Initialize multiple USB Disks, now with -Confirm'
    Write-Host -ForegroundColor White      'Get-LocalDisk                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Get-OSDDisk -BusTypeNot USB,Virtual'
    Write-Host -ForegroundColor White      'Get-OSDDisk                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'OSD version of Get-Disk with some easy filters'
    Write-Host -ForegroundColor White      'Get-USBDisk                            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Get-OSDDisk -BusType USB'
    Write-Host -ForegroundColor White      '[WinPE] New-OSDisk                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Creates System | OS | Recovery Partitions for GPT and MBR Drives in WinPE'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.10'
    Write-Host -ForegroundColor White      'Backup-MyBitLockerKeys                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves all BitLocker ExternalKeys (BEK), KeyPackages (KPG), and RecoveryPasswords (TXT)'
    Write-Host -ForegroundColor White      'Get-MyBitLockerKeyProtectors           ' -NoNewline
    Write-Host -ForegroundColor Gray        'Object of BitLocker KeyProtectors and RecoveryPasswords'
    Write-Host -ForegroundColor White      'Save-MyBitLockerExternalKey            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves ExternalKey BEK files to a Path'
    Write-Host -ForegroundColor White      'Save-MyBitLockerKeyPackage             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves a key package for a drive for corrupt recovery'
    Write-Host -ForegroundColor White      'Save-MyBitLockerRecoveryPassword       ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves RecoveryPassword TXT files to a Path'
    Write-Host -ForegroundColor White      'Unlock-MyBitLockerExternalKey          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.9'
    Write-Host -ForegroundColor White      'Copy-PSModuleToWim                     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a Windows Image .wim file'
    Write-Host -ForegroundColor White      'Copy-PSModuleToWindowsImage            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a mounted Windows Image'
    Write-Host -ForegroundColor White      'Dismount-MyWindowsImage (Renamed)      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Dismounts WIM by Mounted Path, or all WIMs if no Path is specified'
    Write-Host -ForegroundColor White      'Edit-MyWindowsImage (Renamed)          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Modify an Online or Offline Windows Image with Cleanup and Appx Stuff'
    Write-Host -ForegroundColor White      'Mount-MyWindowsImage (Renamed)         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Give it a WIM, let it mount it'
    Write-Host -ForegroundColor White      'Update-MyWindowsImage (Renamed)        ' -NoNewline
    Write-Host -ForegroundColor Gray        'Identify, Download, and Apply Updates to a Mounted Windows Image'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.8'
    Write-Host -ForegroundColor White      'Get-MyWindowsCapability                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsCapability'
    Write-Host -ForegroundColor White      'Get-MyWindowsPackage                   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Detailed version of Get-WindowsPackage'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.3'
    Write-Host -ForegroundColor White      'Get-ComObjects                         ' -NoNewline
    Write-Host -ForegroundColor Gray        'List of (mostly all) of the system ComObjects'
    Write-Host -ForegroundColor White      'Get-ComObjMicrosoftUpdateAutoUpdate    ' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.AutoUpdate).Settings'
    Write-Host -ForegroundColor White      'Get-ComObjMicrosoftUpdateInstaller     ' -NoNewline
    Write-Host -ForegroundColor Gray        'New-Object -ComObject Microsoft.Update.Installer'
    Write-Host -ForegroundColor White      'Get-ComObjMicrosoftUpdateServiceManager' -NoNewline
    Write-Host -ForegroundColor Gray        '(New-Object -ComObject Microsoft.Update.ServiceManager).Services'
    Write-Host -ForegroundColor White      'Get-MyComputerManufacturer             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Manufacturer'
    Write-Host -ForegroundColor White      'Get-MyComputerModel                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Model'
    Write-Host -ForegroundColor White      'Get-MyBiosSerialNumber                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Returns the Computer Serial Number'
    Write-Host -ForegroundColor White      'Get-MyDefaultAUService                 ' -NoNewline
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
    Write-Host -ForegroundColor White      'Set-DisRes                             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the Primary Display Screen Resolution'
    Write-Host -ForegroundColor White      'Copy-PSModuleToFolder                  ' -NoNewline
    Write-Host -ForegroundColor Gray        'Copies a PowerShell Module to a specified Destination'
    Write-Host -ForegroundColor White      'Get-ScreenPNG                          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Takes a screeshot'
    Write-Host -ForegroundColor White       'Set-ClipboardScreenshot                ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets a Screenshot of the Primary Screen on the Clipboard'
    Write-Host -ForegroundColor White       'Save-ClipboardImage                    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Saves the Clipboard Image as a file.  PNG extension is recommended'

    Write-Host -ForegroundColor DarkCyan    '=================================' -NoNewline
    Write-Host -ForegroundColor Cyan        '21.2.1'
    Write-Host -ForegroundColor White      'Set-WimExecutionPolicy                 ' -NoNewline
    Write-Host -ForegroundColor Gray        'Sets the PowerShell Execution Policy of a .wim File'
    Write-Host -ForegroundColor White      'Set-WindowsImageExecutionPolicy        ' -NoNewline
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
    Write-Host -ForegroundColor White      'Update-Module OSD -Force'
    #======================================================================================================
}
<#
.SYNOPSIS
Returns CimInstance information from common OSD Classes

.DESCRIPTION
Returns CimInstance information from common OSD Classes

.EXAMPLE
OSDClass
Returns CimInstance Win32_ComputerSystem properties
Option 1: Get-OSDClass
Option 2: Get-OSDClass ComputerSystem
Option 3: Get-OSDClass -Class ComputerSystem

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdclass

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDClass {
    [CmdletBinding()]
    param (
        #CimInstance Class Name
        #Battery
        #BaseBoard
        #BIOS
        #BootConfiguration
        #ComputerSystem [DEFAULT]
        #Desktop
        #DiskPartition
        #DisplayConfiguration
        #Environment
        #LogicalDisk
        #LogicalDiskRootDirectory
        #MemoryArray
        #MemoryDevice
        #NetworkAdapter
        #NetworkAdapterConfiguration
        #OperatingSystem
        #OSRecoveryConfiguration
        #PhysicalMedia
        #PhysicalMemory
        #PnpDevice
        #PnPEntity
        #PortableBattery
        #Processor
        #SCSIController
        #SCSIControllerDevice
        #SMBIOSMemory
        #SystemBIOS
        #SystemEnclosure
        #SystemDesktop
        #SystemPartitions
        #UserDesktop
        #VideoController
        #VideoSettings
        #Volume
        [ValidateSet(
            'Battery',
            'BaseBoard',
            'BIOS',
            'BootConfiguration',
            'ComputerSystem',
            'Desktop',
            'DiskPartition',
            'DisplayConfiguration',
            'Environment',
            'LogicalDisk',
            'LogicalDiskRootDirectory',
            'MemoryArray',
            'MemoryDevice',
            'NetworkAdapter',
            'NetworkAdapterConfiguration',
            'OperatingSystem',
            'OSRecoveryConfiguration',
            'PhysicalMedia',
            'PhysicalMemory',
            'PnpDevice',
            'PnPEntity',
            'PortableBattery',
            'Processor',
            'SCSIController',
            'SCSIControllerDevice',
            'SMBIOSMemory',
            'SystemBIOS',
            'SystemEnclosure',
            'SystemDesktop',
            'SystemPartitions',
            'UserDesktop',
            'VideoController',
            'VideoSettings',
            'Volume'
        )]
        [string]$Class = 'ComputerSystem'
    )

    $Value = (Get-CimInstance -ClassName Win32_$Class | Select-Object -Property *)
    Return $Value
}
<#
.SYNOPSIS
Returns common OSD information as an ordered hash table

.DESCRIPTION
Returns common OSD information as an ordered hash table

.EXAMPLE
OSDGather
Get-OSDGather
Returns the Gather Results

.EXAMPLE
$OSDGather = Get-OSDGather
$OSDGather.IsAdmin
$OSDGather.ComputerInfo
Returns the Gather Results saved in a Variable

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdgather

.NOTES
19.10.4.0   David Segura @SeguraOSD
#>
function Get-OSDGather {
    [CmdletBinding()]
    param (
        #Returns the Name Value
        [Parameter(Position = 0)]
        [ValidateSet(
            'IsAdmin',
            'IsBDE',
            'IsClientOS',
            'IsDesktop',
            'IsLaptop',
            'IsOnBattery',
            'IsSFF',
            'IsServer',
            'IsServerChassis',
            'IsServerCoreOS',
            'IsServerOS',
            'IsTablet',
            'IsUEFI',
            'IsVM',
            'IsWinPE',
            'IsInWinSE'
            )]
        [string]$Property,
        #Returns additional CimInstance results
        [switch]$Full
    )
    #======================================================================================================
    #   IsAdmin
    #======================================================================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if ($Property -eq 'IsAdmin') {Return $IsAdmin}
    #======================================================================================================
    #   IsWinPE
    #======================================================================================================
    $IsWinPE = $env:SystemDrive -eq 'X:'
    if ($Property -eq 'IsWinPE') {Return $IsWinPE}
    #======================================================================================================
    #   IsInWinPE
    #======================================================================================================
    $IsInWinSE = ($IsWinPE) -and (Test-Path 'X:\Setup.exe')
    if ($Property -eq 'IsInWinSE') {Return $IsInWinSE}
    #======================================================================================================
    #   IsUEFI
    #======================================================================================================
    if ($IsWinPE) {
        Start-Process -WindowStyle Hidden -FilePath wpeutil.exe -ArgumentList ('updatebootinfo') -Wait
        $IsUEFI = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
    } else {
        if ($null -eq (Get-ItemProperty HKLM:\System\CurrentControlSet\Control\SecureBoot\State -ErrorAction SilentlyContinue)) {
            $IsUEFI = $false
        } else {
            $IsUEFI = $true
        }
    }
    if ($Property -eq 'IsUEFI') {Return $IsUEFI}
    #===================================================================================================
    #   IsUEFI
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
<#     try {
        Get-SecureBootUEFI -Name SetupMode | Out-Null
        $IsUEFI = $true
    }
    catch {$IsUEFI = $false} #>
    #======================================================================================================
    #   IsBDE
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    if (! $IsAdmin) {
        Write-Warning "IsBDE property requires Admin Elevation"
        $IsBDE = $null
    } elseif ($IsWinPE) {
        Write-Warning "IsBDE property cannot run in WinPE"
        $IsBDE = $null
    } else {
        $IsBDE = $false
        $BitlockerEncryptionType = $null
        $BitlockerEncryptionMethod = $null
    
        $EncryptionMethods = @{ 0 = "UNSPECIFIED";
                            1 = 'AES_128_WITH_DIFFUSER';
                            2 = "AES_256_WITH_DIFFUSER";
                            3 = 'AES_128';
                            4 = "AES_256";
                            5 = 'HARDWARE_ENCRYPTION';
                            6 = "AES_256";
                            7 = "XTS_AES_256" }
    
        $EncVols = Get-WmiObject -Namespace 'ROOT\cimv2\Security\MicrosoftVolumeEncryption' -Query "Select * from Win32_EncryptableVolume" -EA SilentlyContinue
        if ($EncVols) {
            foreach ($EncVol in $EncVols) {
                if($EncVol.ProtectionStatus -ne 0) {
                    $EncMethod = [int]$EncVol.GetEncryptionMethod().EncryptionMethod
                    if ($EncryptionMethods.ContainsKey($EncMethod)) {$BitlockerEncryptionMethod = $EncryptionMethods[$EncMethod]}
                    $Status = $EncVol.GetConversionStatus(0)
                    if ($Status.ReturnValue -eq 0) {
                        if ($Status.EncryptionFlags -eq 0x00000001) {$BitlockerEncryptionType = "Used Space Only Encrypted"}
                        else {$BitlockerEncryptionType = "Full Disk Encryption"}
                    } else {$BitlockerEncryptionType = "Unknown"}
    
                    $IsBDE = $true
                }
            }
        }
    }
    if ($Property -eq 'IsBDE') {Return $IsBDE}
    #======================================================================================================
    #   Get-CimInstance Win32_ComputerSystem
    #======================================================================================================
    $Win32ComputerSystem = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   IsOS
    #======================================================================================================
    $IsClientOS = $false
    $IsServerOS = $false
    $IsServerCoreOS = $false

    if ($IsWinPE -eq $false) {
        if ($Win32ComputerSystem.Roles -match 'Server_NT' -or $Win32ComputerSystem.Roles -match 'LanmanNT') {
            $IsClientOS = $false
            $IsServerOS = $true
        } else {
            $IsClientOS = $true
            $IsServerOS = $false
        }

        if (!(Test-Path "$env:windir\explorer.exe")) {
            $IsClientOS = $false
            $IsServerOS = $false
            $IsServerCoreOS = $true
        }
    }
    if ($Property -eq 'IsClientOS') {Return $IsClientOS}
    if ($Property -eq 'IsServerOS') {Return $IsServerOS}
    if ($Property -eq 'IsServerCoreOS') {Return $IsServerCoreOS}
    #======================================================================================================
    #   IsVM
    #======================================================================================================
    $IsVM = ($Win32ComputerSystem.Model -match 'Virtual') -or ($Win32ComputerSystem.Model -match 'VMware')
    if ($Property -eq 'IsVM') {Return $IsVM}
    #======================================================================================================
    #   Get-CimInstance Win32_SystemEnclosure
    #======================================================================================================
    $Win32SystemEnclosure = (Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   Win32_SystemEnclosure
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    $IsDesktop = $false
    $IsLaptop = $false
    $IsServer = $false
    $IsSFF = $false
    $IsTablet = $false
    $Win32SystemEnclosure | ForEach-Object {
        if ($_.ChassisTypes[0] -in "8", "9", "10", "11", "12", "14", "18", "21") { $IsLaptop = $true }
        if ($_.ChassisTypes[0] -in "3", "4", "5", "6", "7", "15", "16") { $IsDesktop = $true }
        if ($_.ChassisTypes[0] -in "23") {$IsServer = $true}
        if ($_.ChassisTypes[0] -in "34", "35", "36") { $IsSFF = $true }
        if ($_.ChassisTypes[0] -in "13", "31", "32", "30") { $IsTablet = $true } 
    }
    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}
    if ($Property -eq 'IsServer' -or $Property -eq 'IsServerChassis') {Return $IsServer}
    if ($Property -eq 'IsSFF') {Return $IsSFF}
    if ($Property -eq 'IsTablet') {Return $IsTablet}
    #======================================================================================================
    #   Get-CimInstance Win32_Battery
    #======================================================================================================
    $Win32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)
    #======================================================================================================
    #   IsOnBattery
    #======================================================================================================
    $IsOnBattery = ($Win32Battery.BatteryStatus -contains 1)
    if ($Property -eq 'IsOnBattery') {Return $IsOnBattery}
    #===================================================================================================
    #   Architecture
    #===================================================================================================
    if ($env:PROCESSOR_ARCHITEW6432) {
        if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
            $Architecture = "x64"
        } else {
            $Architecture = $env:PROCESSOR_ARCHITEW6432.ToUpper()
        }
    } else {
        if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            $Architecture = "x64"
        } else {
            $Architecture = $env:PROCESSOR_ARCHITECTURE.ToUpper()
        }
    }
    #===================================================================================================
    #   Win32NetworkAdapterConfiguration
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #===================================================================================================
    $Win32NetworkAdapterConfiguration = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue | Select-Object -Property *)
    $ipList = @()
    $macList = @()
    $gwList = @()
    $Win32NetworkAdapterConfiguration | Where-Object {$_.IpEnabled -eq $true} | ForEach-Object {
        $_.IPAddress | ForEach-Object {$ipList += $_ }
        $_.MacAddress | ForEach-Object {$macList += $_ }
        if ($_.DefaultGateway) {$_.DefaultGateway | ForEach-Object {$gwList += $_ }}
    }
    $IPAddress = $ipList
    $MacAddress = $macList
    $DefaultGateway = $gwList
    #===================================================================================================
    #   Get Registry
    #===================================================================================================
    $RegControl = Get-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Control'
    $RegSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'
    $RegVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    try {
        $RegVersion.DigitalProductId = $null
        $RegVersion.DigitalProductId4 = $null
    }
    catch {}
    #===================================================================================================
    #   MDT Get CimInstance
    #===================================================================================================
    $Win32BIOS = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -Property *)
    $Win32BaseBoard = (Get-CimInstance -ClassName Win32_BaseBoard -ErrorAction SilentlyContinue | Select-Object -Property *)
    $Win32ComputerSystemProduct = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -ErrorAction SilentlyContinue | Select-Object -Property *)
    $Win32OperatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -Property *)
    $Win32Processor = (Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -Property *)
    #===================================================================================================
    #   Bitlocker
    #===================================================================================================
    if ($Full.IsPresent) {
        if ($IsAdmin) {
            try {$GetBitlockerVolume = Get-BitlockerVolume -ErrorAction SilentlyContinue}
            catch {$GetBitlockerVolume = $null}
        } else {
            Write-Warning "GetBitlockerVolume requires Admin Elevation"
        }
    }
    #===================================================================================================
    #   PhysicalDisk
    #===================================================================================================
    try {$GetPhysicalDisk = Get-PhysicalDisk}
    catch {$GetPhysicalDisk = $null}
    #===================================================================================================
    #   Supports
    #===================================================================================================
    $SupportsNX = $Win32OperatingSystem.DataExecutionPrevention_Available -eq $true
    $Supports32Bit = $Win32Processor.DataWidth -match 32
    $Supports64Bit = $Win32Processor.DataWidth -match 64
    #======================================================================================================
    #   MDT Variables
    #======================================================================================================
    $GetOSDGatherMDTPS = [ordered]@{
        Architecture = $Architecture
        AssetTag = $Win32SystemEnclosure.SMBIOSAssetTag.Trim()
        #CapableArchitecture = AMD64 X64 X86
        #DEBUG = FALSE
        #DefaultGateway =
        #HalName = acpiapic
        HostName = $Win32ComputerSystem.DNSHostName
        IPAddress = $IPAddress
        #LOGPATH = C:\MININT\SMSOSD\OSDLOGS
        MacAddress = $MacAddress
        Make = $Win32ComputerSystem.Manufacturer
        Memory = [int] ($Win32ComputerSystem.TotalPhysicalMemory / 1024 / 1024)
        Model = $Win32ComputerSystem.Model
        #ORIGINALARCHITECTURE = X64
        #ORIGINALPARTITIONIDENTIFIER = SELECT * FROM Win32_LogicalDisk WHERE Size = '498731053056' and VolumeName = 'OSDisk' and VolumeSerialNumber = '5AC885B9'
        OriginalWindir = $Win32OperatingSystem.WindowsDirectory
        OsCurrentBuild = $Win32OperatingSystem.BuildNumber
        OsCurrentVersion = $Win32OperatingSystem.Version
        #OsSku = Enterprise
        OsVersion = $Win32OperatingSystem.Version
        ProcessorSpeed = $Win32Processor.MaxClockSpeed
        Product = $Win32BaseBoard.Product
        SerialNumber = $Win32BIOS.SerialNumber
        #SupportsHyperVRole = $SupportsNX
        #SupportsSLAT = $Win32Processor.SecondLevelAddressTranslationExtensions
        SupportsX64 = $Supports64Bit
        SupportsX86 = $Supports32Bit
        UUID = $Win32ComputerSystemProduct.UUID
    }
    #======================================================================================================
    #   GetOSDGather
    #======================================================================================================
    $GetOSDGather = [ordered]@{
        #===================================================================================================
        #   Bool
        #===================================================================================================
        IsAdmin = $IsAdmin
        IsBDE = $IsBDE
        IsClientOS = $IsClientOS
        IsDesktop = $IsDesktop
        IsLaptop = $IsLaptop
        IsOnBattery = $IsOnBattery
        IsSFF = $IsSFF
        IsServer = $IsServer
        IsServerChassis = $IsServer
        IsServerCoreOS = $IsServerCoreOS
        IsServerOS = $IsServerOS
        IsTablet = $IsTablet
        IsUEFI = $IsUEFI
        IsVM = $IsVM
        IsWinPE = $IsWinPE
        IsInWinSE = $IsInWinSE
        #===================================================================================================
        #   MDTPS
        #===================================================================================================
        MDTPS = $GetOSDGatherMDTPS
        #===================================================================================================
        #   Registry
        #===================================================================================================
        RegControl = $RegControl
        RegSetup = $RegSetup
        RegVersion = $RegVersion
    }
    #===================================================================================================
    #   Full
    #===================================================================================================
    if ($Full.IsPresent) {
        $GetOSDGather.GetBitlockerVolume = $GetBitlockerVolume
        $GetOSDGather.GetPhysicalDisk = $GetPhysicalDisk
        
        $GetOSDGather.BIOS = $Win32BIOS
        $GetOSDGather.BaseBoard = $Win32BaseBoard
        $GetOSDGather.Battery = $Win32Battery
        $GetOSDGather.ComputerSystem = $Win32ComputerSystem
        $GetOSDGather.ComputerSystemProduct = $Win32ComputerSystemProduct
        $GetOSDGather.DiskPartition = (Get-CimInstance -ClassName Win32_DiskPartition -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.DisplayConfiguration = (Get-CimInstance -ClassName Win32_DisplayConfiguration -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.Environment = (Get-CimInstance -ClassName Win32_Environment -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.LogicalDisk = (Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.NetworkAdapter = (Get-CimInstance -ClassName Win32_NetworkAdapter -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.NetworkAdapterConfiguration = $Win32NetworkAdapterConfiguration
        $GetOSDGather.OperatingSystem = $Win32OperatingSystem
        $GetOSDGather.PnPEntity = (Get-CimInstance -ClassName Win32_PnPEntity -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.Processor = $Win32Processor
        $GetOSDGather.SCSIController = (Get-CimInstance -ClassName Win32_SCSIController -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.SystemDesktop = (Get-CimInstance -ClassName Win32_SystemDesktop -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.SystemEnclosure = $Win32SystemEnclosure
        $GetOSDGather.UserDesktop = (Get-CimInstance -ClassName Win32_UserDesktop -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.VideoController = (Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.VideoControllerResolution = (Get-CimInstance -ClassName CIM_VideoControllerResolution -ErrorAction SilentlyContinue | Select-Object -Property *)
        $GetOSDGather.Volume = (Get-CimInstance -ClassName Win32_Volume -ErrorAction SilentlyContinue | Select-Object -Property *)
        
        $GetOSDGather.ComputerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
    }
    Return $GetOSDGather
}
<#
.SYNOPSIS
Displays Power Plan information using powercfg /LIST

.DESCRIPTION
Displays Power Plan information using powercfg /LIST.  Optionally Set an Active Power Plan

.EXAMPLE
OSDPower
Returns Power Plan information using powercfg /LIST
Option 1: Get-OSDPower
Option 2: Get-OSDPower LIST
Option 3: Get-OSDPower -Property LIST

.EXAMPLE
OSDPower High
Sets the active Power Plan to High Performance
Option 1: Get-OSDPower High
Option 2: Get-OSDPower -Property High

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdpower

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDPower {
    [CmdletBinding()]
    param (
        #Powercfg option (Low, Balanced, High, LIST, QUERY)
        #Default is LIST
        [Parameter(Position = 0)]
        [ValidateSet('Low','Balanced','High','LIST','QUERY')]
        [string]$Property = 'LIST'
    )

    if ($Property -eq 'Low') {
        Write-Verbose 'OSDPower: Enable Power Saver Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','a1841308-3541-4fab-bc81-f71556f20b4a') -Wait
    }
    if ($Property -eq 'Balanced') {
        Write-Verbose 'OSDPower: Enable Balanced Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','381b4222-f694-41f0-9685-ff5bb260df2e') -Wait
    }
    if ($Property -eq 'High') {
        Write-Verbose 'OSDPower: Enable High Performance Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
    if ($Property -eq 'LIST') {
        Write-Verbose 'OSDPower: Lists all power schemes'
        powercfg.exe /LIST
    }
    if ($Property -eq 'QUERY') {
        Write-Verbose 'OSDPower: Displays the contents of a power scheme'
        powercfg.exe /QUERY
    }
}
<#
.SYNOPSIS
Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion

.DESCRIPTION
Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion for Online and Offline Windows Images

.LINK
https://osd.osdeploy.com/module/functions/general/get-regcurrentversion

.NOTES
19.11.20    Added Pipeline Support
19.11.9     David Segura @SeguraOSD Initial Release
#>
function Get-RegCurrentVersion {
    [CmdletBinding()]
    param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path,

        [ValidateSet(
            'BaseBuildRevisionNumber',
            'BuildBranch',
            'BuildGUID',
            'BuildLab',
            'BuildLabEx',
            'CompositionEditionID',
            'CurrentBuild',
            'CurrentBuildNumber',
            'CurrentMajorVersionNumber',
            'CurrentMinorVersionNumber',
            'CurrentType',
            'CurrentVersion',
            'EditionID',
            'InstallationType',
            'ProductId',
            'ProductName',
            'ReleaseId',
            'UBR'
            )]
        [string]$Property
    )
    begin {}
    process {
        $Global:GetRegCurrentVersion = $null

        if ($Path) {
            if (-not (Test-Path $Path -ErrorAction SilentlyContinue)) {Write-Warning "Unable to locate Mounted WindowsImage at $Path"; Break}
            Write-Verbose $Path
        
            $RegHive = "$Path\Windows\System32\Config\SOFTWARE"
            if (-not (Test-Path $RegHive)) {Write-Warning "Unable to locate RegHive at $RegHive"; Break}
        
            reg LOAD 'HKLM\OSD' "$Path\Windows\System32\Config\SOFTWARE" | Out-Null
            $Global:GetRegCurrentVersion = Get-ItemProperty -Path 'HKLM:\OSD\Microsoft\Windows NT\CurrentVersion'
            reg UNLOAD 'HKLM\OSD' | Out-Null
            Start-Sleep -Seconds 1
        } else {
            $Global:GetRegCurrentVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        }

        if ($Property) {
            Return ($Global:GetRegCurrentVersion).$Property
        } else {
            Return $Global:GetRegCurrentVersion
        }
    }
    end {}
}
<#
.SYNOPSIS
Returns the Session.xml Updates that have been applied to an Operating System

.DESCRIPTION
Returns the Session.xml Updates that have been applied to an Operating System

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdsessions

.NOTES
19.11.20    Added Pipeline Support
19.11.20    Path now supports Mounted WIM Path
19.10.14    David Segura @SeguraOSD Initial Release
#>
function Get-SessionsXml {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        #Specifies the full path to the root directory of the offline Windows image that you will service
        #Or Path of the Sessions.xml file
        #If this value is not set, the running OS Sessions.xml will be processed
        [string]$Path = "$env:SystemRoot\Servicing\Sessions\Sessions.xml",

        #Returns the KBNumber
        [string]$KBNumber
    )
    begin {}
    process {
        #===================================================================================================
        #   Set Sessions.xml
        #===================================================================================================
        $SessionsXml = $Path
        #===================================================================================================
        #   Mount Path
        #===================================================================================================
        if ($SessionsXml -notmatch 'Sessions.xml') {$SessionsXml = "$Path\Windows\Servicing\Sessions\Sessions.xml"}
        #===================================================================================================
        #   Test-Path
        #===================================================================================================
        if (!(Test-Path "$SessionsXml")) {Write-Warning "Cannot find Sessions.xml at $Path"; Break}
        Write-Verbose $SessionsXml
        #===================================================================================================
        #   Process Sessions.xml
        #===================================================================================================
        [xml]$XmlDocument = Get-Content -Path "$SessionsXml"
    
        $SessionsXml = $XmlDocument.SelectNodes('Sessions/Session') | ForEach-Object {
            New-Object -Type PSObject -Property @{
                Complete = $_.Complete
                KBNumber = $_.Tasks.Phase.package.name
                TargetState = $_.Tasks.Phase.package.targetState
                Id = $_.Tasks.Phase.package.id
                Client = $_.Client
                Status = $_.Status
            }
        }
    
        $SessionsXml = $SessionsXml | Where-Object {$_.Id -like "Package*"}
        $SessionsXml = $SessionsXml | Select-Object -Property Complete, KBNumber, TargetState, Id, Client, Status | Sort-Object Complete
        #===================================================================================================
        #   KBNumber
        #===================================================================================================
        if ($KBNumber) {$SessionsXml = $SessionsXml | Where-Object {$_.KBNumber -match $KBNumber}}
        #===================================================================================================
        #   Return $SessionsXml
        #===================================================================================================
        #if ($GridView.IsPresent) {$SessionsXml = $SessionsXml | Select-Object -Property * | Out-GridView -PassThru -Title 'Select Updates'}
        Return $SessionsXml
    }
    end {}
}
