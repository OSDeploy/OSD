---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDWinEvent

## SYNOPSIS
Gets OSDWinEvent information.

## SYNTAX

```
Get-OSDWinEvent [[-Area] <String>] [[-DayCount] <Int32>] [[-LogName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Returns OSDWinEvent data for the current system or OSD session context.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Get-OSDWinEvent.

## PARAMETERS

### -Area
Specifies the Area to use when running Get-OSDWinEvent.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Quick

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayCount
Specifies the DayCount to use when running Get-OSDWinEvent.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogName
Specifies the LogName to use when running Get-OSDWinEvent.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @('System','Application')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

