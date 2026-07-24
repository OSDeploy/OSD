---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-SelectUSBDisk

## SYNOPSIS
Invokes SelectUSBDisk actions.

## SYNTAX

```
Invoke-SelectUSBDisk [[-Input] <Object>] [[-MinimumSizeGB] <Int32>] [[-MaximumSizeGB] <Int32>] [-Skip]
 [-SelectOne] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Runs interactive or workflow-oriented SelectUSBDisk operations used by OSD tasks.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Invoke-SelectUSBDisk.
```

## PARAMETERS

### -Input
Specifies the Input to use when running Invoke-SelectUSBDisk.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MinimumSizeGB
Specifies the MinimumSizeGB to use when running Invoke-SelectUSBDisk.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Min, MinGB, MinSize

Required: False
Position: 2
Default value: 8
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumSizeGB
Specifies the MaximumSizeGB to use when running Invoke-SelectUSBDisk.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Max, MaxGB, MaxSize

Required: False
Position: 3
Default value: 1800
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Specifies the Skip to use when running Invoke-SelectUSBDisk.

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

### -SelectOne
Specifies the SelectOne to use when running Invoke-SelectUSBDisk.

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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

