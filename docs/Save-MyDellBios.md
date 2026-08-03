---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-MyDellBios

## SYNOPSIS
Downloads the latest compatible Dell BIOS update to a local folder.

## SYNTAX

```
Save-MyDellBios [[-DownloadPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves the current system's compatible Dell BIOS update and downloads the
BIOS package to the specified folder when it is not already present.
This
function only operates on Dell hardware and returns the existing or newly
downloaded BIOS file when successful.

## EXAMPLES

### EXAMPLE 1
```
Save-MyDellBios
Downloads the compatible Dell BIOS update to the default temporary folder.
```

### EXAMPLE 2
```
Save-MyDellBios -DownloadPath 'C:\OSDCloud\Firmware'
Downloads the compatible Dell BIOS update to C:\OSDCloud\Firmware.
```

## PARAMETERS

### -DownloadPath
Specifies the directory where the Dell BIOS update should be stored.
The
default location is the current user's temporary folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DownloadFolder, Path

Required: False
Position: 1
Default value: $env:TEMP
Accept pipeline input: True (ByValue)
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
2026-07-22 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

