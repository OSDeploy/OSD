---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreOperatingSystems

## SYNOPSIS
Gets the core operating system catalog entries that OSD uses for offline media selection.

## SYNTAX

```
Get-OSDCoreOperatingSystems [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Imports the operating system catalog XML files stored under the module's core operating systems cache,
normalizes duplicate metadata, and returns a sorted list of operating system records with build,
architecture, language, activation, hash, and image metadata.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreOperatingSystems
```

Returns all available core operating system records discovered in the module cache.

### EXAMPLE 2
```
Get-OSDCoreOperatingSystems | Where-Object Version -eq 'Windows 11'
```

Returns only Windows 11 operating system records.

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

### None. You cannot pipe input to this function.
## OUTPUTS

### PSCustomObject
### One or more normalized operating system records.
## NOTES
Author: David Segura - Recast Software
2026-07-22 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

