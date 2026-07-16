---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Expand-StagedDriverPack

## SYNOPSIS
Expands staged driver pack archives during Windows Setup

## SYNTAX

```
Expand-StagedDriverPack [-Apply] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Extracts and processes staged driver pack files (CAB, EXE, MSI, ZIP) from the C:\Drivers directory.
Supports multiple vendor formats including Dell, HP, Lenovo, and generic packages.

## EXAMPLES

### EXAMPLE 1
```
Expand-StagedDriverPack
Expands all driver packs in C:\Drivers
```

### EXAMPLE 2
```
Expand-StagedDriverPack -Apply
Expands driver packs and applies them during setup
```

## PARAMETERS

### -Apply
Applies drivers during PnP unattend phase

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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
