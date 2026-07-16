---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Enable-PEWindowsImagePSGallery

## SYNOPSIS
Enables PowerShell Gallery in a mounted Windows image

## SYNTAX

```
Enable-PEWindowsImagePSGallery [[-Path] <String[]>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Configures a mounted Windows image to support PowerShell Gallery by adding necessary registry entries and environment variables to the system profile.

## EXAMPLES

### EXAMPLE 1
```
Enable-PEWindowsImagePSGallery
Enables PowerShell Gallery in the currently mounted image
```

### EXAMPLE 2
```
Enable-PEWindowsImagePSGallery -Path 'C:\Mount'
Enables PowerShell Gallery in the image mounted at C:\Mount
```

## PARAMETERS

### -Path
Path to the mounted Windows image root directory.
If not specified, will use the currently mounted image.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
