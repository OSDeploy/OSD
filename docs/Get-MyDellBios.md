---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MyDellBios

## SYNOPSIS
Returns the latest compatible Dell BIOS update for the current system.

## SYNTAX

```
Get-MyDellBios [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Detects the current Dell system SKU, filters the cached Dell BIOS catalog for
compatible entries, and returns the newest matching BIOS update object.
This
function only returns data when it is run on Dell hardware.

## EXAMPLES

### EXAMPLE 1
```
Get-MyDellBios
Returns the newest compatible Dell BIOS update object for the current Dell device.
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
2021-03-04 - Initial release
2021-03-05 - Resolved issue with multiple objects
2021-03-11 - Pulled data from local catalog due to Dell site availability issues
2026-07-22 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

