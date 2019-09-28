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
        [string]$Class
    )

    $Value = (Get-CimInstance -ClassName Win32_$Class | Select-Object -Property *)
    Return $Value
}