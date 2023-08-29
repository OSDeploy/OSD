---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdeploy.com/
schema: 2.0.0
---

# New-CAB

## SYNOPSIS
Creates a CAB file from a Directory

## SYNTAX

```
New-CAB [-SourceDirectory] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a CAB file from a Directory

## EXAMPLES

### EXAMPLE 1
```
New-CAB -SourceDirectory C:\DeploymentShare\OSDeploy\OSConfig
```

Creates LZX High Compression CAB from of C:\DeploymentShare\OSDeploy\OSConfig
Saves file in Parent Directory C:\DeploymentShare\OSDeploy\OSConfig.cab

## PARAMETERS

### -SourceDirectory
Directory to create the CAB from

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
NAME:	New-CAB.ps1
AUTHOR:	David Segura, david@segura.org
BLOG:	http://www.osdeploy.com
VERSION:	18.9.4

## RELATED LINKS

[https://www.osdeploy.com/](https://www.osdeploy.com/)

