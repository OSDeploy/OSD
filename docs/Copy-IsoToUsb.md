---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Copy-IsoToUsb

## SYNOPSIS
Creates a bootable USB drive from a Windows ISO.

## SYNTAX

```
Copy-IsoToUsb [-ISOFile] <String> [-MakeBootable] [-NTFS] [-SplitWim] [[-USBLabel] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Formats a selected USB disk, mounts the ISO, and copies installation files
to the USB volume.
Supports FAT32 or NTFS, optional bootsect execution, and
optional splitting of large install.wim files.

## EXAMPLES

### EXAMPLE 1
```
Copy-IsoToUsb -ISOFile 'C:\Temp\Win11.iso' -MakeBootable -USBLabel WIN11
Creates a bootable USB and copies the ISO contents.
```

### EXAMPLE 2
```
Copy-IsoToUsb -ISOFile 'C:\Temp\Win11.iso' -NTFS -USBLabel WIN11NTFS
Creates an NTFS-formatted USB and copies the ISO contents.
```

## PARAMETERS

### -ISOFile
Full path to the ISO file to mount and copy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MakeBootable
Runs bootsect.exe against the USB drive after formatting.

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

### -NTFS
Formats the USB drive as NTFS instead of FAT32.

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

### -SplitWim
Forces splitting install.wim into .swm files during copy.

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

### -USBLabel
File system label assigned to the USB drive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
2026-07-11 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

