---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdeploy.com
schema: 2.0.0
---

# Copy-IsoToUsb

## SYNOPSIS
Creates a Bootable FAT32 USB (32GB or smaller) and copies a Mounted ISO.

## SYNTAX

```
Copy-IsoToUsb [-ISOFile] <String> [-MakeBootable] [-NTFS] [-SplitWim] [[-USBLabel] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a Bootable FAT32 USB (32GB or smaller) and copies a Mounted ISO.

## EXAMPLES

### EXAMPLE 1
```
Copy-IsoToUsb -ISOFile "C:\Temp\SW_DVD5_Win_Pro_Ent_Edu_N_10_1709_64BIT_English_MLF_X21-50143.ISO" -MakeBootable -USBDriveLabel WIN10X64
```

You will be prompted to select a USB Drive in GridView

## PARAMETERS

### -ISOFile
Full path to the ISO file to Mount

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
Uses Bootsect to make the USB Bootable

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
{{ Fill NTFS Description }}

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
{{ Fill SplitWim Description }}

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
{{ Fill USBLabel Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
NAME:	Copy-IsoToUsb.ps1
AUTHOR:	David Segura, david@segura.org
BLOG:	http://www.osdeploy.com
VERSION:	18.9.4
        
Original credit to Mike Robbins
http://mikefrobbins.com/2018/01/18/use-powershell-to-create-a-bootable-usb-drive-from-a-windows-10-or-windows-server-2016-iso/

Additional credit to Sergey Tkachenko
https://winaero.com/blog/powershell-windows-10-bootable-usb/

## RELATED LINKS

[https://www.osdeploy.com](https://www.osdeploy.com)

