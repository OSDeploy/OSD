---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDDisk

## SYNOPSIS
Gets OSDDisk information.

## SYNTAX

```
Get-OSDDisk [[-Number] <UInt32>] [[-BootFromDisk] <Boolean>] [[-IsBoot] <Boolean>] [[-IsReadOnly] <Boolean>]
 [[-IsSystem] <Boolean>] [[-BusType] <String[]>] [[-BusTypeNot] <String[]>] [[-MediaType] <String[]>]
 [[-MediaTypeNot] <String[]>] [[-PartitionStyle] <String[]>] [[-PartitionStyleNot] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns OSDDisk data for the current system or OSD session context.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Get-OSDDisk.
```

## PARAMETERS

### -Number
Specifies the Number to use when running Get-OSDDisk.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: Disk, DiskNumber

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BootFromDisk
Specifies the BootFromDisk to use when running Get-OSDDisk.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsBoot
Specifies the IsBoot to use when running Get-OSDDisk.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsReadOnly
Specifies the IsReadOnly to use when running Get-OSDDisk.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsSystem
Specifies the IsSystem to use when running Get-OSDDisk.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusType
Specifies the BusType to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusTypeNot
Specifies the BusTypeNot to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaType
Specifies the MediaType to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaTypeNot
Specifies the MediaTypeNot to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyle
Specifies the PartitionStyle to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyleNot
Specifies the PartitionStyleNot to use when running Get-OSDDisk.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
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
