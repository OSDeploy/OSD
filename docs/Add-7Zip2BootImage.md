---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Add-7Zip2BootImage

## SYNOPSIS
Adds 7-Zip command-line binaries to a mounted Windows image.

## SYNTAX

```
Add-7Zip2BootImage [[-MountPath] <String>] [-Use7zr] [-TempTest] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Downloads the latest 7-Zip release assets from GitHub and copies the
extracted binaries into Windows\System32 for the target mount path.

## EXAMPLES

### EXAMPLE 1
```
Add-7Zip2BootImage -MountPath 'C:\Mount'
Downloads and copies 7-Zip binaries into C:\Mount\Windows\System32.
```

### EXAMPLE 2
```
Add-7Zip2BootImage -Use7zr
Adds only 7zr.exe to the detected mounted image.
```

## PARAMETERS

### -MountPath
Mounted Windows image path.
If omitted, uses the currently mounted image.

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
Copies 7zr.exe only instead of the full 7z x64 binaries.

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
Uses a temporary test path under %TEMP% instead of a mounted image.

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
2026-07-13 - Refactored internals for readability without changing output behavior

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
