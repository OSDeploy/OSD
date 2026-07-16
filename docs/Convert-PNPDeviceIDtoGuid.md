---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Convert-PNPDeviceIDtoGuid

## SYNOPSIS
Extracts GUID values from a PNP Device ID string.

## SYNTAX

```
Convert-PNPDeviceIDtoGuid [-PNPDeviceID] <String> [<CommonParameters>]
```

## DESCRIPTION
Uses a regular expression to locate and return GUID values embedded in a
Plug and Play device identifier.
Accepts input directly or from the
pipeline.

## EXAMPLES

### EXAMPLE 1
```
Convert-PNPDeviceIDtoGuid -PNPDeviceID 'USB\\VID_1234&PID_5678\\{12345678-1234-1234-1234-1234567890AB}'
```

Returns the GUID found in the PNP device ID.

### EXAMPLE 2
```
'USB\\VID_1234&PID_5678\\{12345678-1234-1234-1234-1234567890AB}' | Convert-PNPDeviceIDtoGuid
```

Returns the GUID found in the piped PNP device ID.

## PARAMETERS

### -PNPDeviceID
PNP device ID string to search for GUID values.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DeviceID

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Author: David Segura - Recast Software
2026-07-11 - Added comment-based help
2026-07-11 - Added pipeline support and improved GUID matching logic

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

