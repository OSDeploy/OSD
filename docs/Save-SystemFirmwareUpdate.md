---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-SystemFirmwareUpdate

## SYNOPSIS
Downloads and extracts the latest system firmware update.

## SYNTAX

```
Save-SystemFirmwareUpdate [[-DestinationDirectory] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Finds the latest applicable system firmware update from Microsoft Update
Catalog, downloads the package, and extracts its contents to a destination
directory.

## EXAMPLES

### EXAMPLE 1
```
Save-SystemFirmwareUpdate
Downloads and extracts the latest firmware update to the default temp path.
```

### EXAMPLE 2
```
Save-SystemFirmwareUpdate -DestinationDirectory C:\Drivers\SystemFirmware
Downloads and extracts the latest firmware update to C:\Drivers\SystemFirmware.
```

## PARAMETERS

### -DestinationDirectory
Directory where the firmware update package will be downloaded and extracted.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$env:TEMP\SystemFirmwareUpdate"
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

### PSCustomObject. Returns details about the selected update, extraction path, and discovered INF files.
## NOTES
Author: David Segura - Recast Software
2026-07-11 - Improved status output and error handling
2026-07-11 - Return structured save result and validate extraction exit code

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

