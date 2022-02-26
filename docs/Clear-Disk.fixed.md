---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/disk
schema: 2.0.0
---

# Clear-Disk.fixed

## SYNOPSIS
Clear-Disk on Fixed Disks

## SYNTAX

```
Clear-Disk.fixed [[-Input] <Object>] [[-DiskNumber] <UInt32>] [-Initialize] [[-PartitionStyle] <String>]
 [-Force] [-NoResults] [-ShowWarning] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Clear-Disk on Fixed Disks
-DiskNumber: Single Disk execution
-Force: Required for execution
-Initialize: Initializes RAW as MBR or GPT PartitionStyle
-PartitionStyle: Overrides the automatic selection of MBR or GPT

## EXAMPLES

### EXAMPLE 1
```
Clear-Disk.fixed
```

Informational. 
Executes Get-Help Clear-Disk.fixed
Always displayed if the -Force parameter is not used

### EXAMPLE 2
```
Clear-Disk.fixed -Force
```

Interactive. 
Prompted to Confirm Clear-Disk for each Local Disk

### EXAMPLE 3
```
Clear-Disk.fixed -Force -Confirm:$false
```

Non-Interactive.
Clears all Local Disks without being prompted to Confirm

## PARAMETERS

### -Input
Get-Disk.fixed Object

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
Specifies the disk number for which to get the associated Disk object
Alias = Disk, Number

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
Initializes the cleared disk as MBR or GPT
Alias = I

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
Override the automatic Partition Style of the Initialized Disk
EFI Default = GPT
BIOS Default = MBR
Alias = PS

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
Required for execution
Alias = F

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
{{ Fill NoResults Description }}

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
{{ Fill ShowWarning Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
21.3.3      Added SizeGB
21.2.22     Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/disk](https://osd.osdeploy.com/module/functions/disk)

