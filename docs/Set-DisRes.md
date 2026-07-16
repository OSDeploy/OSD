---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Set-DisRes

## SYNOPSIS
Sets the primary display screen resolution.

## SYNTAX

```
Set-DisRes [[-Width] <String>] [[-Height] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Changes the primary display resolution to the specified width and height, or to a preset alias such as 720p, 1080p, 4k, or Restore.

## EXAMPLES

### EXAMPLE 1
```
Set-DisRes -Width 1920 -Height 1080
Sets the primary display resolution to 1920x1080.
```

## PARAMETERS

### -Width
Target horizontal resolution, a preset alias, or Restore to return to the previous value captured in the current session.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Horizontal

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Height
Target vertical resolution.
If omitted when Width is numeric or a preset alias, Height may be auto-selected from common aspect ratios.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Vertical

Required: False
Position: 2
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
2026-07-11 - Moved help block inside function and expanded sections

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
