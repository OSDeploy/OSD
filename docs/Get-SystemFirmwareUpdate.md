---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-SystemFirmwareUpdate

## SYNOPSIS
Retrieves the latest system firmware update from Microsoft Update Catalog

## SYNTAX

```
Get-SystemFirmwareUpdate [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches Microsoft Update Catalog directly for the latest system firmware
update available for the current computer firmware resource GUID.

## EXAMPLES

### EXAMPLE 1
```
Get-SystemFirmwareUpdate
Returns the latest available firmware update
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

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help
2026-07-11 - Removed Get-MSCatalogUpdate dependency and added direct catalog query

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

