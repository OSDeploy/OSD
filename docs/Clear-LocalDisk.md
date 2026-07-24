---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Clear-LocalDisk

## SYNOPSIS
Clears LocalDisk data or state.

## SYNTAX

```
Clear-LocalDisk [[-Input] <Object>] [[-DiskNumber] <UInt32>] [-Initialize] [[-PartitionStyle] <String>]
 [-Force] [-NoResults] [-ShowWarning] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Removes existing LocalDisk data or configuration and applies the requested reset behavior.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Clear-LocalDisk.
```

## PARAMETERS

### -Input
Specifies the Input to use when running Clear-LocalDisk.

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

### -DiskNumber
Specifies the DiskNumber to use when running Clear-LocalDisk.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: Disk, Number

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Initialize
Specifies the Initialize to use when running Clear-LocalDisk.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: I

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyle
Specifies the PartitionStyle to use when running Clear-LocalDisk.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PS

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies the Force to use when running Clear-LocalDisk.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: F

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoResults
Specifies the NoResults to use when running Clear-LocalDisk.

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

### -ShowWarning
Specifies the ShowWarning to use when running Clear-LocalDisk.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: W, Warn, Warning

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

