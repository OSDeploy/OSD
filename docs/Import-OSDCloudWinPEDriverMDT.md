---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Import-OSDCloudWinPEDriverMDT

## SYNOPSIS
Imports OSDCloud CloudDrivers into an MDT Deployment Share

## SYNTAX

```
Import-OSDCloudWinPEDriverMDT [[-Driver] <String[]>] [[-DriverHWID] <String[]>] [[-ShareName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Imports OSDCloud CloudDrivers into an MDT Deployment Share

## EXAMPLES

### EXAMPLE 1
```
Import-OSDCloudWinPEDriverMDT
```

Imports OSDCloud WinPE cloud drivers into an MDT deployment share.

## PARAMETERS

### -Driver
WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CloudDriver

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverHWID
WinPE Driver: HardwareID of the Driver to add to WinPE

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: HardwareID

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShareName
{{ Fill ShareName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Share

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

