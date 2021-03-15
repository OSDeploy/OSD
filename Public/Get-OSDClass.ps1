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