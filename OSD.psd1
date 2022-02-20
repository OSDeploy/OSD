@{

# Script module or binary module file associated with this manifest.
RootModule = 'OSD.psm1'

# Version number of this module.
ModuleVersion = '22.2.19.1'

# Supported PSEditions
CompatiblePSEditions = @('Desktop')

# ID used to uniquely identify this module
GUID = '9fe5b9b6-0224-4d87-9018-a8978529f6f5'

# Author of this module
Author = 'David Segura @SeguraOSD'

# Company or vendor of this module
CompanyName = 'osdeploy.com'

# Copyright statement for this module
Copyright = '(c) 2022 David Segura osdeploy.com. All rights reserved.'

# Description of the functionality provided by this module
Description = @'
OSD PowerShell Module is a collection of OSD shared functions that can be used WinPE and Windows 10
https://osd.osdeploy.com/
'@

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @(
    '.\Format\MsUpCat.Format.ps1xml'
)

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport =
'Add-WindowsDriver.offlineservicing',
'Add-WindowsPackageSSU',
'Backup-Disk.ffu',
'Backup-MyBitLockerKeys',
'Block-AdminUser',
'Block-ManufacturerNeLenovo',
'Block-NoCurl',
'Block-NoInternet',
'Block-PowerShellVersionLt5',
'Block-StandardUser',
'Block-WinOS',
'Block-WinPE',
'Block-WindowsReleaseIdLt1703',
'Block-WindowsVersionNe10',
'Clear-Disk.fixed',
'Clear-Disk.usb',
'Connect-WinREWiFi',
'Connect-WinREWiFiByXMLProfile',
'Convert-EsdToFolder',
'Convert-EsdToIso',
'Convert-EsdToWim',
'Convert-FolderToIso',
'Convert-PNPDeviceIDtoGuid',
'Copy-IsoToUsb',
'Copy-PSModuleToFolder',
'Copy-PSModuleToWim',
'Copy-PSModuleToWindowsImage',
'Copy-WinRE.wim',
'Dismount-MyWindowsImage',
'Edit-ADKwinpe.wim',
'Edit-MyWinPE',
'Edit-MyWindowsImage',
'Edit-OSDCloud.winpe',
'Enable-OSDCloudODT',
'Enable-PEWimPSGallery',
'Enable-PEWindowsImagePSGallery',
'Enable-SpecializeDriverPack',
'Expand-StagedDriverPack',
'Expand-ZTIDriverPack',
'Export-OSDCertificatesAsReg',
'Find-OSDCloudFile',
'Find-OSDCloudODTFile',
'Find-OSDCloudOfflineFile',
'Find-OSDCloudOfflinePath',
'Find-TextInFile',
'Find-TextInModule',
'Get-ADKpaths',
'Get-DellApplicationCatalog',
'Get-DellBiosCatalog',
'Get-DellDriverCatalog',
'Get-DellDriverPackMasterCatalog',
'Get-DellFirmwareCatalog',
'Get-DellSystemMasterCatalog',
'Get-HPAccessoryCatalog',
'Get-HPBiosCatalog',
'Get-HPDriverCatalog',
'Get-HPDriverPackMasterCatalog',
'Get-HPFirmwareCatalog',
'Get-HPPlatformListMasterCatalog',
'Get-HPSoftwareCatalog',
'Get-HPSystemMasterCatalog',
'Get-LenovoBiosMasterCatalog',
'Get-LenovoDriverPackMasterCatalog',
'Get-MicrosoftDriverPackMasterCatalog',
'Get-CimVideoControllerResolution',
'Get-ComObjMicrosoftUpdateAutoUpdate',
'Get-ComObjMicrosoftUpdateInstaller',
'Get-ComObjMicrosoftUpdateServiceManager',
'Get-ComObjects',
'Get-DellDriverPack',
'Get-Disk.fixed',
'Get-Disk.osd',
'Get-Disk.storage',
'Get-Disk.usb',
'Get-DisplayAllScreens',
'Get-DisplayPrimaryBitmapSize',
'Get-DisplayPrimaryMonitorSize',
'Get-DisplayPrimaryScaling',
'Get-DisplayVirtualScreen',
'Get-DownLinks',
'Get-IntelDisplayDriverMasterCatalog',
'Get-IntelRadeonDisplayDriverMasterCatalog',
'Get-IntelWirelessDriverMasterCatalog',
'Get-EnablementPackage',
'Get-FeatureUpdate',
'Get-HpDriverPack',
'Get-LenovoDriverPack',
'Get-MicrosoftDriverPack',
'Get-MsUpCat',
'Get-MsUpCatUpdate',
'Get-MyBiosSerialNumber',
'Get-MyBiosUpdate',
'Get-MyBiosVersion',
'Get-MyBitLockerKeyProtectors',
'Get-MyComputerManufacturer',
'Get-MyComputerModel',
'Get-MyComputerProduct',
'Get-MyDefaultAUService',
'Get-MyDellBios',
'Get-MyDriverPack',
'Get-MyWindowsCapability',
'Get-MyWindowsPackage',
'Get-OSD',
'Get-OSDClass',
'Get-OSDCloud.template',
'Get-OSDCloud.workspace',
'Get-OSDDriver',
'Get-OSDDriverNvidiaDisplay',
'Get-OSDDriverWmiQ',
'Get-OSDGather',
'Get-OSDHelp',
'Get-OSDPad',
'Get-OSDPower',
'Get-OSDWinEvent',
'Get-OSDWinPE',
'Get-Partition.fixed',
'Get-Partition.osd',
'Get-Partition.usb',
'Get-PartitionWinRE',
'Get-ReAgentXml',
'Get-RegCurrentVersion',
'Get-ScreenPNG',
'Get-SessionsXml',
'Get-SystemFirmwareDevice',
'Get-SystemFirmwareResource',
'Get-SystemFirmwareUpdate',
'Get-Volume.fixed',
'Get-Volume.osd',
'Get-Volume.usb',
'Get-WSUSXML',
'Get-WinREWiFi',
'Install-SystemFirmwareUpdate',
'Invoke-Exe',
'Invoke-MSCatalogParseDate',
'Invoke-OSDCloud',
'Invoke-OSDSpecialize',
'Invoke-WebPSScript',
'Invoke-oobeAddNetFX3',
'Invoke-oobeAddRSAT',
'Invoke-oobeUpdateDrivers',
'Invoke-oobeUpdateWindows',
'Mount-MyWindowsImage',
'New-ADK.iso',
'New-ADKcopype',
'New-Bootable.usb',
'New-CAB',
'New-CabDevelopment',
'New-OSDCloud.iso',
'New-OSDCloud.template',
'New-OSDCloud.usb',
'New-OSDCloud.workspace',
'New-OSDisk',
'Remove-AppxOnline',
'Save-ClipboardImage',
'Save-EnablementPackage',
'Save-FeatureUpdate',
'Save-MsUpCatDriver',
'Save-MsUpCatUpdate',
'Save-MyBiosUpdate',
'Save-MyBitLockerExternalKey',
'Save-MyBitLockerKeyPackage',
'Save-MyBitLockerRecoveryPassword',
'Save-MyDellBios',
'Save-MyDellBiosFlash64W',
'Save-MyDriverPack',
'Save-OSDCloud.usb',
'Save-OSDCloudDriverPack.usb',
'Save-OSDDownload',
'Save-SystemFirmwareUpdate',
'Save-WebFile',
'Save-ZTIDriverPack',
'Select-Disk.ffu',
'Select-Disk.fixed',
'Select-Disk.osd',
'Select-Disk.storage',
'Select-Disk.usb',
'Select-OSDCloudAutopilotJsonItem',
'Select-OSDCloudFile.wim',
'Select-OSDCloudImageIndex',
'Select-OSDCloudODTFile',
'Select-Volume.fixed',
'Select-Volume.osd',
'Select-Volume.usb',
'Set-ClipboardScreenshot',
'Set-DisRes',
'Set-OSDCloud.workspace',
'Set-OSDCloudUnattendAuditMode',
'Set-OSDCloudUnattendAuditModeAutopilot',
'Set-OSDCloudUnattendSpecialize',
'Set-WimExecutionPolicy',
'Set-WinREWiFi',
'Set-WindowsImageExecutionPolicy',
'Show-MsSettings',
'Show-RegistryXML',
'Start-OOBEDeploy',
'Start-OSDCloud',
'Start-OSDCloudGUI',
'Start-OSDPad',
'Start-OSDeployPad',
'Start-ScreenPNGProcess',
'Start-WinREWiFi',
'Stop-ScreenPNGProcess',
'Test-FolderToIso',
'Test-IsVM',
'Test-OSDCloud.template',
'Test-WebConnection',
'Test-WindowsImage',
'Test-WindowsImageMountPath',
'Test-WindowsImageMounted',
'Test-WindowsPackageCAB',
'Unblock-WindowsUpdate',
'Unlock-MyBitLockerExternalKey',
'Update-MyDellBios',
'Update-MyWindowsImage',
'Update-OSDCloud.usb',
'Use-WinPEContent',
'Wait-WebConnection',
'Get-GithubRawContent',
'Get-GithubRawUrl',
'Get-PSCloudScript',
'Resolve-MsUrl',
'Save-WinPECloudDriver',
'ConvertTo-PSKeyVaultSecret',
'Get-OSDDriverDellModel',
'Get-OSDDriverHpModel',
'New-OSDCloudUSB',
'Update-OSDCloudUSB',
'Get-DellOSDDriversCatalog',
'Get-HPOSDDriversCatalog',
'Set-OSDxCloudUnattendSpecialize',
'Start-DiskImageFFU'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('OSD','OSDeploy','OSDBuilder')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/OSDeploy/OSD/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/OSDeploy/OSD'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/OSDeploy/OSD/master/OSD.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://osd.osdeploy.com/release'
    } # End of PSData hashtable
} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}