---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# New-OSDisk

## SYNOPSIS
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

## SYNTAX

```
New-OSDisk [[-Input] <Object>] [[-DiskNumber] <UInt32>] [[-PartitionStyle] <String>] [[-LabelSystem] <String>]
 [[-SizeSystemGpt] <UInt64>] [[-SizeSystemMbr] <UInt64>] [[-SizeMSR] <UInt64>] [[-LabelWindows] <String>]
 [-NoRecoveryPartition] [[-LabelRecovery] <String>] [[-SizeRecovery] <UInt64>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates System | OS | Recovery Partitions for MBR or UEFI Drives in WinPE

## EXAMPLES

### EXAMPLE 1
```
New-OSDisk
```

Displays Get-Help New-OSDisk

### EXAMPLE 2
```
New-OSDisk -Force
```

Interactive. 
Prompted to Confirm Clear-Disk for each Local Disk

## PARAMETERS

### -Input
{{ Fill Input Description }}

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

### -LabelSystem
Drive Label of the System Partition
Default = System
Alias = LS, LabelS

```yaml
Type: String
Parameter Sets: (All)
Aliases: LS, LabelS

Required: False
Position: 4
Default value: System
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeSystemGpt
System Partition size for UEFI GPT based Computers
Default = 260MB
Range = 100MB - 3000MB (3GB)
Alias = SSG, Efi, SystemG

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: SSG, Efi, SystemG

Required: False
Position: 5
Default value: 272629760
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeSystemMbr
System Partition size for BIOS MBR based Computers
Default = 260MB
Range = 100MB - 3000MB (3GB)
Alias = SSM, Mbr, SystemM

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: SSM, Mbr, SystemM

Required: False
Position: 6
Default value: 272629760
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeMSR
MSR Partition size
Default = 16MB
Range = 16MB - 128MB
Alias = MSR

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: MSR

Required: False
Position: 7
Default value: 16777216
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelWindows
Drive Label of the Windows Partition
Default = OS
Alias = LW, LabelW

```yaml
Type: String
Parameter Sets: (All)
Aliases: LW, LabelW

Required: False
Position: 8
Default value: OS
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRecoveryPartition
Alias = SkipRecovery, SkipRecoveryPartition
Skips the creation of the Recovery Partition

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: SkipRecovery, SkipRecoveryPartition

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelRecovery
Drive Label of the Recovery Partition
Default = Recovery
Alias = LR, LabelR

```yaml
Type: String
Parameter Sets: (All)
Aliases: LR, LabelR

Required: False
Position: 9
Default value: Recovery
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeRecovery
Size of the Recovery Partition
Default = 990MB
Range = 350MB - 80000MB (80GB)
Alias = SR, Recovery

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: SR, Recovery

Required: False
Position: 10
Default value: 1038090240
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
19.10.10    Created by David Segura @SeguraOSD
21.2.19     Complete redesign

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

