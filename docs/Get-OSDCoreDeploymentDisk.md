---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDeploymentDisk

## SYNOPSIS
Retrieves disk objects suitable for OS deployment with enhanced filtering capabilities.

## SYNTAX

```
Get-OSDCoreDeploymentDisk [[-Number] <UInt32>] [-BootFromDisk] [-IsBoot] [-IsReadOnly] [-IsSystem]
 [[-BusType] <String[]>] [[-BusTypeNot] <String[]>] [[-MediaType] <String[]>] [[-MediaTypeNot] <String[]>]
 [[-PartitionStyle] <String[]>] [[-PartitionStyleNot] <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-OSDCoreDeploymentDisk queries the system for physical disks and returns disk objects with extended properties including MediaType.
The function automatically filters out offline disks, disks with no media, and incompatible bus types (USB, Virtual, etc.).
It provides comprehensive filtering options based on disk properties such as boot status, bus type, media type, and partition style.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDeploymentDisk
```

Returns all available deployment-ready disks, excluding USB, virtual, and other incompatible bus types.

### EXAMPLE 2
```
Get-OSDCoreDeploymentDisk -Number 0
```

Returns disk 0 if it meets deployment criteria.

### EXAMPLE 3
```
Get-OSDCoreDeploymentDisk -MediaType SSD
```

Returns all SSD disks suitable for deployment.

### EXAMPLE 4
```
Get-OSDCoreDeploymentDisk -BusType NVMe,SATA -PartitionStyle GPT
```

Returns all NVMe or SATA disks with GPT partition style.

### EXAMPLE 5
```
Get-OSDCoreDeploymentDisk -BusTypeNot USB -MediaTypeNot HDD
```

Returns all non-USB, non-HDD disks (typically SSDs and NVMe drives).

## PARAMETERS

### -Number
Specifies the disk number to retrieve.
Can also be referenced using aliases 'Disk' or 'DiskNumber'.

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
Filters disks where the system boots from the disk.

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

### -IsBoot
Filters disks that contain boot partitions.

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

### -IsReadOnly
Filters disks based on read-only status.

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

### -IsSystem
Filters disks that contain system partitions.

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

### -BusType
Filters disks by one or more specific bus types.
Valid values: '1394', 'ATA', 'ATAPI', 'Fibre Channel', 'File Backed Virtual', 'iSCSI', 'MMC', 'MAX', 'Microsoft Reserved', 'NVMe', 'RAID', 'SAS', 'SATA', 'SCSI', 'SD', 'SSA', 'Storage Spaces', 'USB', 'Virtual'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusTypeNot
Excludes disks with specified bus types.
Valid values: '1394', 'ATA', 'ATAPI', 'Fibre Channel', 'File Backed Virtual', 'iSCSI', 'MMC', 'MAX', 'Microsoft Reserved', 'NVMe', 'RAID', 'SAS', 'SATA', 'SCSI', 'SD', 'SSA', 'Storage Spaces', 'USB', 'Virtual'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaType
Filters disks by one or more specific media types.
Valid values: 'SSD', 'HDD', 'SCM', 'Unspecified'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaTypeNot
Excludes disks with specified media types.
Valid values: 'SSD', 'HDD', 'SCM', 'Unspecified'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionStyle
Filters disks by one or more specific partition styles.
Valid values: 'GPT', 'MBR', 'RAW'

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

### -PartitionStyleNot
Excludes disks with specified partition styles.
Valid values: 'GPT', 'MBR', 'RAW'

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
Requires .NET System.Management access to the MSFT_Disk class and the Storage module Get-PhysicalDisk cmdlet.
Automatically excludes: File Backed Virtual, MAX, Microsoft Reserved, USB, and Virtual bus types.
The function throws an error if no disks match the specified criteria.
A warning is issued when multiple disks match the criteria.

## RELATED LINKS
