---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudVM

## SYNOPSIS
Creates resources by using New-OSDCloudVM.

## SYNTAX

```
New-OSDCloudVM [[-CheckpointVM] <Boolean>] [[-Generation] <UInt16>] [[-MemoryStartupGB] <UInt16>]
 [[-NamePrefix] <String>] [[-ProcessorCount] <UInt16>] [[-StartVM] <Boolean>] [[-SwitchName] <String>]
 [[-VHDSizeGB] <UInt16>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for New-OSDCloudVM.

## EXAMPLES

### EXAMPLE 1
```
-Generation <Generation>
Runs New-OSDCloudVM with common parameters.
```

## PARAMETERS

### -CheckpointVM
Specifies the value for CheckpointVM.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Generation
Specifies the value for Generation.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryStartupGB
Specifies the value for MemoryStartupGB.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePrefix
Specifies the value for NamePrefix.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessorCount
Specifies the value for ProcessorCount.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartVM
Specifies the value for StartVM.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SwitchName
Specifies the value for SwitchName.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VHDSizeGB
Specifies the value for VHDSizeGB.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
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
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
