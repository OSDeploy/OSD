---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Block-WindowsReleaseIdLt1703

## SYNOPSIS
Blocks execution if Windows ReleaseId is less than 1703

## SYNTAX

```
Block-WindowsReleaseIdLt1703 [-Warn] [-Pause] [<CommonParameters>]
```

## DESCRIPTION
Validates that Windows ReleaseId is 1703 or greater.
If the ReleaseId is less than 1703, writes a warning and breaks execution unless the -Warn parameter is specified.

## EXAMPLES

### EXAMPLE 1
```
Block-WindowsReleaseIdLt1703
```

Halts execution if Windows ReleaseId is less than 1703

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

