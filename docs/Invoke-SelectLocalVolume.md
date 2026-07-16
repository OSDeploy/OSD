---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-SelectLocalVolume

## SYNOPSIS
Invokes SelectLocalVolume actions.

## SYNTAX

```
Invoke-SelectLocalVolume [[-Input] <Object>] [[-MinimumSizeGB] <Int32>] [[-FileSystem] <String>] [-Skip]
 [-SelectOne] [<CommonParameters>]
```

## DESCRIPTION
Runs interactive or workflow-oriented SelectLocalVolume operations used by OSD tasks.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Invoke-SelectLocalVolume.

## PARAMETERS

### -Input
Specifies the Input to use when running Invoke-SelectLocalVolume.

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
Specifies the MinimumSizeGB to use when running Invoke-SelectLocalVolume.

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

### -FileSystem
Specifies the FileSystem to use when running Invoke-SelectLocalVolume.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Specifies the Skip to use when running Invoke-SelectLocalVolume.

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
Specifies the SelectOne to use when running Invoke-SelectLocalVolume.

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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

