---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-OSDCloudDriverPackPPKG

## SYNOPSIS
Uses DISM in WinPE to expand and apply Driver Packs

## SYNTAX

```
Invoke-OSDCloudDriverPackPPKG [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses DISM in WinPE to expand and apply Driver Packs

## EXAMPLES

### EXAMPLE 1
```
Invoke-OSDCloudDriverPackPPKG
Applies the packaged OSDCloud driver pack to the Windows image from WinPE.
```

## PARAMETERS

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
2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

