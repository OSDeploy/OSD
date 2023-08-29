---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-OSDPower

## SYNOPSIS
Displays Power Plan information using powercfg /LIST

## SYNTAX

```
Get-OSDPower [[-Property] <String>] [<CommonParameters>]
```

## DESCRIPTION
Displays Power Plan information using powercfg /LIST. 
Optionally Set an Active Power Plan

## EXAMPLES

### EXAMPLE 1
```
OSDPower
```

Returns Power Plan information using powercfg /LIST
Option 1: Get-OSDPower
Option 2: Get-OSDPower LIST
Option 3: Get-OSDPower -Property LIST

### EXAMPLE 2
```
OSDPower High
```

Sets the active Power Plan to High Performance
Option 1: Get-OSDPower High
Option 2: Get-OSDPower -Property High

## PARAMETERS

### -Property
Powercfg option (Low, Balanced, High, LIST, QUERY)
Default is LIST

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: LIST
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
19.10.1     David Segura @SeguraOSD

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

