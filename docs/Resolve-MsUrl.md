---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com
schema: 2.0.0
---

# Resolve-MsUrl

## SYNOPSIS
Resolves a short Microsoft aka.ms or fwlink URL.

## SYNTAX

```
Resolve-MsUrl [-Uri] <Uri> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves a short Microsoft aka.ms or fwlink URL.

## EXAMPLES

### EXAMPLE 1
```
Resolve-MsUrl -Uri 'https://aka.ms/windows'
```

## PARAMETERS

### -Uri
Uri to resolve.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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

### System.Uri
## NOTES
Author: David Segura - Recast Software
2026-07-13 - Improved help and readability without changing behavior

## RELATED LINKS

[https://osd.osdeploy.com](https://osd.osdeploy.com)

