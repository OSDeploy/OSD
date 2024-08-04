---
external help file: OSD-help.xml
Module Name: OSD
online version:
schema: 2.0.0
---

# Add-7Zip2BootImage

## SYNOPSIS
This function adds 7-Zip to a boot image.

## SYNTAX

```
Add-7Zip2BootImage [[-MountPath] <String>] [-Use7zr] [-TempTest] [<CommonParameters>]
```

## DESCRIPTION
The function downloads the latest version of 7-Zip from the GitHub page and extracts it to the specified boot image path or the mounted Windows image path.

## EXAMPLES

### EXAMPLE 1
```
Add-7Zip2BootImage -MountPath "C:\BootImage" -Use7zr
```

This example adds 7-Zip (7zr.exe) to the boot image located at "C:\BootImage"

### EXAMPLE 2
```
Add-7Zip2BootImage
```

This example adds 7-Zip (7z.exe + 2 dll files) to the boot image at the mounted WIM path it finds.

## PARAMETERS

### -MountPath
The path to the boot image or the mounted Windows image.
If not specified, the function will attempt to get the mounted Windows image path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Use7zr
Specifies whether to use 7zr.exe instead of 7z.exe in your boot media.
Default is false.

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

### -TempTest
Specifies whether to use a temporary test path for extracting the 7z file.
Default is false.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
