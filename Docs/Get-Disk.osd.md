---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-Disk.osd

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-Disk.osd [[-Number] <UInt32>] [[-BootFromDisk] <Boolean>] [[-IsBoot] <Boolean>] [[-IsReadOnly] <Boolean>]
 [[-IsSystem] <Boolean>] [[-BusType] <String[]>] [[-BusTypeNot] <String[]>] [[-MediaType] <String[]>]
 [[-MediaTypeNot] <String[]>] [[-PartitionStyle] <String[]>] [[-PartitionStyleNot] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -BootFromDisk
{{ Fill BootFromDisk Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusType
{{ Fill BusType Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: 1394, ATA, ATAPI, Fibre Channel, File Backed Virtual, iSCSI, MMC, MAX, Microsoft Reserved, NVMe, RAID, SAS, SATA, SCSI, SD, SSA, Storage Spaces, USB, Virtual

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusTypeNot
{{ Fill BusTypeNot Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: 1394, ATA, ATAPI, Fibre Channel, File Backed Virtual, iSCSI, MMC, MAX, Microsoft Reserved, NVMe, RAID, SAS, SATA, SCSI, SD, SSA, Storage Spaces, USB, Virtual

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsBoot
{{ Fill IsBoot Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsReadOnly
{{ Fill IsReadOnly Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsSystem
{{ Fill IsSystem Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaType
{{ Fill MediaType Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: SSD, HDD, SCM, Unspecified

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaTypeNot
{{ Fill MediaTypeNot Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: SSD, HDD, SCM, Unspecified

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Number
{{ Fill Number Description }}

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: Disk, DiskNumber

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyle
{{ Fill PartitionStyle Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: GPT, MBR, RAW

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyleNot
{{ Fill PartitionStyleNot Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: GPT, MBR, RAW

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
