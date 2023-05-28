---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# New-OSDCloudVM

## SYNOPSIS
Creates a Hyper-V VM for use with OSDCloud

## SYNTAX

```
New-OSDCloudVM [[-CheckpointVM] <Boolean>] [[-Generation] <UInt16>] [[-MemoryStartupGB] <UInt16>]
 [[-NamePrefix] <String>] [[-ProcessorCount] <UInt16>] [[-SwitchName] <String>] [[-StartVM] <Boolean>]
 [[-VHDSizeGB] <UInt16>] [<CommonParameters>]
```

## DESCRIPTION
Creates a Hyper-V VM for use with OSDCloud

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudVM
```

## PARAMETERS

### -CheckpointVM
{{ Fill CheckpointVM Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $Global:OSDModuleResource.NewOSDCloudVM.CheckpointVM
Accept pipeline input: False
Accept wildcard characters: False
```

### -Generation
{{ Fill Generation Description }}

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $Global:OSDModuleResource.NewOSDCloudVM.Generation
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryStartupGB
{{ Fill MemoryStartupGB Description }}

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $Global:OSDModuleResource.NewOSDCloudVM.MemoryStartupGB
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePrefix
{{ Fill NamePrefix Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: $Global:OSDModuleResource.NewOSDCloudVM.NamePrefix
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessorCount
{{ Fill ProcessorCount Description }}

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $Global:OSDModuleResource.NewOSDCloudVM.ProcessorCount
Accept pipeline input: False
Accept wildcard characters: False
```

### -SwitchName
{{ Fill SwitchName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $Global:OSDModuleResource.NewOSDCloudVM.SwitchName
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartVM
{{ Fill StartVM Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: $Global:OSDModuleResource.NewOSDCloudVM.StartVM
Accept pipeline input: False
Accept wildcard characters: False
```

### -VHDSizeGB
{{ Fill VHDSizeGB Description }}

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: $Global:OSDModuleResource.NewOSDCloudVM.VHDSizeGB
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

