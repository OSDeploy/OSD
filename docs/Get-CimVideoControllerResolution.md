---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-CimVideoControllerResolution

## SYNOPSIS
Returns CIM video controller resolution entries for the system display adapter.

## SYNTAX

```
Get-CimVideoControllerResolution [-Interlaced] [<CommonParameters>]
```

## DESCRIPTION
Queries CIM_VideoControllerResolution, filters out low resolutions, and returns
either progressive or interlaced modes based on the selected switch.

## EXAMPLES

### EXAMPLE 1
```
Get-CimVideoControllerResolution
```

Returns progressive resolutions with a horizontal resolution of 800 or higher.

### EXAMPLE 2
```
Get-CimVideoControllerResolution -Interlaced
```

Returns interlaced resolutions with a horizontal resolution of 800 or higher.

## PARAMETERS

### -Interlaced
Returns interlaced resolutions when specified.
By default, progressive
resolutions are returned.

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
2026-07-11 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

