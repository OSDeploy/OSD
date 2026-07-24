---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDModuleCache

## SYNOPSIS
Returns the OSD module cache directory path.

## SYNTAX

```
Get-OSDModuleCache [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves the module base path from the current command context and appends
the cache child directory name.
This returns the expected cache folder path
for the installed OSD module.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDModuleCache
```

Returns the full path to the OSD module cache directory.

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

### System.String. The full path to the module cache directory.
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

