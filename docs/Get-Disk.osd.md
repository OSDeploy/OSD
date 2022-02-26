---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/disk/get-disk
schema: 2.0.0
---

# Get-Disk.osd

## SYNOPSIS
Similar to Get-Disk, but includes the MediaType

## SYNTAX

```
Get-Disk.osd [[-Number] <UInt32>] [[-BootFromDisk] <Boolean>] [[-IsBoot] <Boolean>] [[-IsReadOnly] <Boolean>]
 [[-IsSystem] <Boolean>] [[-BusType] <String[]>] [[-BusTypeNot] <String[]>] [[-MediaType] <String[]>]
 [[-MediaTypeNot] <String[]>] [[-PartitionStyle] <String[]>] [[-PartitionStyleNot] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Similar to Get-Disk, but includes the MediaType

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Number
Specifies the disk number for which to get the associated Disk object
Alias = Disk, DiskNumber

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
Returns Disk results based BootFromDisk property
PS\> Get-Disk.osd -BootFromDisk:$true
PS\> Get-Disk.osd -BootFromDisk:$false

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
Returns Disk results based IsBoot property
PS\> Get-Disk.osd -IsBoot:$true
PS\> Get-Disk.osd -IsBoot:$false

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
Returns Disk results based IsReadOnly property
PS\> Get-Disk.osd -IsReadOnly:$true
PS\> Get-Disk.osd -IsReadOnly:$false

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
Returns Disk results based IsSystem property
PS\> Get-Disk.osd -IsSystem:$true
PS\> Get-Disk.osd -IsSystem:$false

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
Returns Disk results in BusType values
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS\> Get-Disk.osd -BusType NVMe
PS\> Get-Disk.osd -BusType NVMe,SAS

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
Returns Disk results notin BusType values
Values = '1394','ATA','ATAPI','Fibre Channel','File Backed Virtual','iSCSI','MMC','MAX','Microsoft Reserved','NVMe','RAID','SAS','SATA','SCSI','SD','SSA','Storage Spaces','USB','Virtual'
PS\> Get-Disk.osd -BusTypeNot USB
PS\> Get-Disk.osd -BusTypeNot USB,Virtual

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
Returns Disk results in MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
PS\> Get-Disk.osd -MediaType SSD

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
Returns Disk results notin MediaType values
Values = 'SSD','HDD','SCM','Unspecified'
PS\> Get-Disk.osd -MediaTypeNot HDD

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
Returns Disk results in PartitionStyle values
Values = 'GPT','MBR','RAW'
PS\> Get-Disk.osd -PartitionStyle GPT

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
Returns Disk results notin PartitionStyle values
Values = 'GPT','MBR','RAW'
PS\> Get-Disk.osd -PartitionStyleNot RAW

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
21.3.9      Removed Offline Drives
21.3.5      Added more BusTypes
21.2.19     Complete redesign
19.10.10    Created by David Segura @SeguraOSD

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/disk/get-disk](https://osd.osdeploy.com/module/functions/disk/get-disk)

