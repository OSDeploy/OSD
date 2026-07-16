---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-MsUpCatDriver

## SYNOPSIS
Downloads driver updates from Microsoft Update Catalog

## SYNTAX

### ByPNPClass (Default)
```
Save-MsUpCatDriver [-DestinationDirectory <String>] [-PNPClass <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ByHardwareID
```
Save-MsUpCatDriver [-DestinationDirectory <String>] [-HardwareID <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches Microsoft Update Catalog for drivers matching specified hardware IDs or Plug and Play device classes and downloads them to a destination directory.

## EXAMPLES

### EXAMPLE 1
```
Save-MsUpCatDriver -DestinationDirectory 'C:\Drivers' -PNPClass 'Net'
Downloads network driver updates to C:\Drivers
```

## PARAMETERS

### -DestinationDirectory
Directory where downloaded drivers will be saved

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HardwareID
One or more hardware IDs to search for drivers (ParameterSet: ByHardwareID)

```yaml
Type: String[]
Parameter Sets: ByHardwareID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PNPClass
Plug and Play device class to search for drivers.
Valid values are DiskDrive, Display, Net, SCSIAdapter, SecurityDevices, or USB.
(ParameterSet: ByPNPClass)

```yaml
Type: String
Parameter Sets: ByPNPClass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
