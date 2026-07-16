---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-AdkCopyPE

## SYNOPSIS
Creates an ADK CopyPE working directory

## SYNTAX

```
New-AdkCopyPE [-Path] <String> [-WinPEArch <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a working directory structure for ADK CopyPE media with bootable WinPE environment.

## EXAMPLES

### EXAMPLE 1
```
New-AdkCopyPE -MediaPath 'C:\CopyPEMedia'
Creates a CopyPE working directory at C:\CopyPEMedia
```

## PARAMETERS

### -Path
{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WinPEArch
{{ Fill WinPEArch Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Amd64
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
2026-07-10 - Updated help to follow OSD standard
2021-05-27 - Resolved issue with paths
2021-03-15 - Renamed to make it easier to understand what it does
2021-03-10 - Initial Release

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
