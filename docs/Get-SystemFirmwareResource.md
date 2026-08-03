---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-SystemFirmwareResource

## SYNOPSIS
Returns the GUID of the system firmware resource

## SYNTAX

```
Get-SystemFirmwareResource [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the system firmware device and extracts GUID values directly from
its PNP Device ID for use with Microsoft Update Catalog queries.

## EXAMPLES

### EXAMPLE 1
```
Get-SystemFirmwareResource
Returns the firmware resource GUID
```

## PARAMETERS

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

### System.String
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help
2026-07-11 - Removed dependency on Convert-PNPDeviceIDtoGuid and added local GUID extraction

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

