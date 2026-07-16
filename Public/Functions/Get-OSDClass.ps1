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
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDClass {
<#
.SYNOPSIS
Gets OSDClass information.

.DESCRIPTION
Returns OSDClass data for the current system or OSD session context.

.PARAMETER Class
Specifies the Class to use when running Get-OSDClass.

.EXAMPLE
Get-OSDClass -C <value>
Demonstrates a common way to run Get-OSDClass.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
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
