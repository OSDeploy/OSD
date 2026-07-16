---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-EnablementPackage

## SYNOPSIS
Returns the latest matching Windows enablement package metadata.

## SYNTAX

```
Get-EnablementPackage [[-OSBuild] <String>] [[-OSArch] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves enablement package metadata from the WSUSXML catalog and filters the result by build and architecture.

## EXAMPLES

### EXAMPLE 1
```
Get-EnablementPackage -OSBuild 22H2 -OSArch x64
Returns the newest x64 enablement package metadata for 22H2.
```

## PARAMETERS

### -OSBuild
Target Windows release build used to filter the enablement package.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Build

Required: False
Position: 1
Default value: 22H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArch
Target operating system architecture used to filter the enablement package.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: X64
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
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
