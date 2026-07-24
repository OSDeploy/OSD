---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Block-PowerShellVersionLt5

## SYNOPSIS
Blocks execution if PowerShell version is less than 5

## SYNTAX

```
Block-PowerShellVersionLt5 [-Warn] [-Pause] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Validates that PowerShell version 5 or greater is running.
If the version is less than 5, writes a warning and breaks execution unless the -Warn parameter is specified.

## EXAMPLES

### EXAMPLE 1
```
Block-PowerShellVersionLt5
Halts execution if PowerShell version is less than 5
```

## PARAMETERS

### -Warn
Shows a warning but continues execution instead of breaking

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pause
Pauses and displays a message before continuing execution

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

