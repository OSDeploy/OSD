# Module Manifest
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'OSD.psm1'

# Version number of his module.
ModuleVersion = '21.3.11.6'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '9fe5b9b6-0224-4d87-9018-a8978529f6f5'

# Author of this module
Author = 'David Segura @SeguraOSD'

# Company or vendor of this module
CompanyName = 'osdeploy.com'

# Copyright statement for this module
Copyright = '(c) 2021 David Segura osdeploy.com. All rights reserved.'

# Description of the functionality provided by this module
Description = @'
OSD PowerShell Module is a collection of OSD shared functions that can be used WinPE and Windows 10
'@

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = 'Windows PowerShell ISE Host'

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
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 
'Get-MyAdk',#ADK
'New-MyAdkCopyPE',
'Remove-AppxOnline',#APPX
'Backup-MyBitLockerKeys',#BITLOCKER
'Get-MyBitLockerKeyProtectors',
'Save-MyBitLockerExternalKey',
'Save-MyBitLockerKeyPackage',
'Save-MyBitLockerRecoveryPassword',
'Unlock-MyBitLockerExternalKey',
'Get-CimVideoControllerResolution',#CIM
'Save-ClipboardImage',#CLIPBOARD
'Set-ClipboardScreenshot',
'Get-ComObjects',#COM
'Get-ComObjMicrosoftUpdateAutoUpdate',
'Get-ComObjMicrosoftUpdateInstaller',
'Get-ComObjMicrosoftUpdateServiceManager',
'Get-MyDefaultAUService',
'Get-MyDellBios',#DELL BIOS
'Save-MyDellBios',
'Save-MyDellBiosFlash64W',
'Update-MyDellBios',
'Get-DellCatalogPC',#DELL DRIVERS
'Get-MyDellDriverCab',
'Save-MyDellDriverCab',
'Backup-DiskToFFU',#DISK
'Clear-LocalDisk',
'Clear-USBDisk',
'Get-LocalDisk',
'Get-LocalPartition',
'Get-OSDPartition',
'Get-OSDVolume',
'Get-USBDisk',
'Get-USBPartition',
'Get-USBVolume',
'New-OSDisk',
'Select-USBVolume',
'Dismount-MyWindowsImage',#DISM
'Edit-MyWindowsImage',
'Edit-MyWinPE',
'Get-MyWindowsCapability',
'Get-MyWindowsPackage',
'Mount-MyWindowsImage',
'Set-WimExecutionPolicy',
'Set-WindowsImageExecutionPolicy',
'Test-WindowsImage',
'Test-WindowsImageMounted',
'Test-WindowsImageMountPath',
'Update-MyWindowsImage',
'Get-DisplayAllScreens',#DISPLAY
'Get-DisplayPrimaryBitmapSize',
'Get-DisplayPrimaryMonitorSize',
'Get-DisplayPrimaryScaling',
'Get-DisplayVirtualScreen',
'Set-DisRes',
'Get-OSDDriver',#DRIVER
'Get-OSDDriverWmiQ',
'Get-OSD',#GENERAL
'Get-OSDClass',
'Get-OSDGather',
'Get-RegCurrentVersion',
'Get-SessionsXml',
'Get-MyBiosSerialNumber',#HARDWARE
'Get-MyBiosVersion',
'Get-MyComputerManufacturer',
'Get-MyComputerModel',
'Get-OSDCloudAutoPilotProfiles',#OSDCLOUD
'Get-OSDCloudOfflineFile',
'New-OSDCloudWinPE',
'Save-OSDCloud',
'Select-AutoPilotJson',
'Start-OSDCloud',
'Update-OSDCloudISO',
'Get-OSDPower',#POWER
'Enable-PEWimPSGallery',#PSGALLERY
'Enable-PEWindowsImagePSGallery',
'Copy-PSModuleToFolder',#PSMODULE
'Copy-PSModuleToWim',
'Copy-PSModuleToWindowsImage',
'Save-OSDDownload',#RETIREPENDING
'Get-ScreenPNG',#SCREENPNG
'Start-ScreenPNGProcess',
'Stop-ScreenPNGProcess',
'Get-FeatureUpdate',#UPDATES
'Invoke-WebPSScript',#WEB
'Save-WebFile',
'Test-WebConnection',
'Get-OSDWinPE',#WINPE
'Use-WinPEContent'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @(
'Dismount-WindowsImageOSD',
'Edit-WindowsImageOSD',
'Get-OSDSessions',
'Mount-OSDWindowsImage',
'Mount-WindowsImageOSD',
'Update-OSDWindowsImage',
'Update-WindowsImageOSD'
)

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