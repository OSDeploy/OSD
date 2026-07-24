---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-MyDellBiosFlash64W

## SYNOPSIS
Downloads and extracts the Dell Flash64W BIOS utility.

## SYNTAX

```
Save-MyDellBiosFlash64W [[-DownloadPath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Downloads the Flash64W support package referenced by the current compatible
Dell BIOS update and extracts Flash64W.exe to the specified folder.
This is
primarily used to support BIOS flashing from WinPE x64 environments on Dell
hardware.

## EXAMPLES

### EXAMPLE 1
```
Save-MyDellBiosFlash64W
Downloads and extracts Flash64W.exe to the default temporary folder.
```

### EXAMPLE 2
```
Save-MyDellBiosFlash64W -DownloadPath 'C:\OSDCloud\Firmware'
Downloads and extracts Flash64W.exe to C:\OSDCloud\Firmware.
```

## PARAMETERS

### -DownloadPath
Specifies the directory where the Flash64W package should be downloaded and
extracted.
The default location is the current user's temporary folder.

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

