<#
.SYNOPSIS
Returns CimInstance information from common OSD Classes

.DESCRIPTION
Returns CimInstance information from common OSD Classes

.PARAMETER Class
CimInstance Class Name

.EXAMPLE
OSDCimClass
Returns CimInstance Win32_ComputerSystem properties
Option 1: Get-OSDCimClass
Option 2: Get-OSDCimClass ComputerSystem
Option 3: Get-OSDCimClass -Class ComputerSystem

.LINK
https://osd.osdeploy.com/module/functions/get-osdcimclass

.NOTES
19.9.29 Contributed by David Segura @SeguraOSD
#>
function Get-OSDCimClass {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
            'Battery',`
            'BaseBoard',`
            'BIOS',`
            'BootConfiguration',`
            'ComputerSystem',`
            'Desktop',`
            'DiskPartition',`
            'DisplayConfiguration',`
            'Environment',`
            'LogicalDisk',`
            'LogicalDiskRootDirectory',`
            'MemoryArray',`
            'MemoryDevice',`
            'NetworkAdapter',`
            'NetworkAdapterConfiguration',`
            'OperatingSystem',`
            'OSRecoveryConfiguration',`
            'PhysicalMedia',`
            'PhysicalMemory',`
            'PnpDevice',`
            'PnPEntity',`
            'PortableBattery',`
            'Processor',`
            'SCSIController',`
            'SCSIControllerDevice',`
            'SMBIOSMemory',`
            'SystemBIOS',`
            'SystemEnclosure',`
            'SystemDesktop',`
            'SystemPartitions',`
            'UserDesktop',`
            'VideoController',`
            'VideoSettings',`
            'Volume'`
        )]
        [string]$Class = 'ComputerSystem'
    )

    $Value = (Get-CimInstance -ClassName Win32_$Class | Select-Object -Property *)
    Return $Value
}