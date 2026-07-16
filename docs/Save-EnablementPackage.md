---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-EnablementPackage

## SYNOPSIS
Downloads a matching Windows enablement package.

## SYNTAX

```
Save-EnablementPackage [[-DownloadPath] <String>] [[-OSBuild] <String>] [[-OSArch] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Resolves an enablement package for the requested build and architecture, verifies connectivity, and downloads the package to the specified directory.

## EXAMPLES

### EXAMPLE 1
```
Save-EnablementPackage -DownloadPath C:\Temp -OSBuild 22H2 -OSArch x64
```

Downloads the latest matching x64 enablement package for 22H2 to C:\Temp.

## PARAMETERS

### -DownloadPath
Destination directory where the enablement package file is saved.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DownloadFolder, Path

Required: False
Position: 1
Default value: "$env:TEMP"
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OSBuild
Target Windows release build used to select the enablement package.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Build

Required: False
Position: 2
Default value: 21H1
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArch
Target operating system architecture used to select the enablement package.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

