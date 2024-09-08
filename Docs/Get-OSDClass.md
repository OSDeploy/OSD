---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-OSDClass

## SYNOPSIS
Returns CimInstance information from common OSD Classes

## SYNTAX

```
Get-OSDClass [[-Class] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns CimInstance information from common OSD Classes

## EXAMPLES

### EXAMPLE 1
```
OSDClass
```

Returns CimInstance Win32_ComputerSystem properties
Option 1: Get-OSDClass
Option 2: Get-OSDClass ComputerSystem
Option 3: Get-OSDClass -Class ComputerSystem

## PARAMETERS

### -Class
CimInstance Class Name
Battery
BaseBoard
BIOS
BootConfiguration
ComputerSystem \[DEFAULT\]
Desktop
DiskPartition
DisplayConfiguration
Environment
LogicalDisk
LogicalDiskRootDirectory
MemoryArray
MemoryDevice
NetworkAdapter
NetworkAdapterConfiguration
OperatingSystem
OSRecoveryConfiguration
PhysicalMedia
PhysicalMemory
PnpDevice
PnPEntity
PortableBattery
Processor
SCSIController
SCSIControllerDevice
SMBIOSMemory
SystemBIOS
SystemEnclosure
SystemDesktop
SystemPartitions
UserDesktop
VideoController
VideoSettings
Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ComputerSystem
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
19.10.1     David Segura @SeguraOSD

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

