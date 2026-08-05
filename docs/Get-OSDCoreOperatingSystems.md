---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreOperatingSystems

## SYNOPSIS
Gets parsed OSD core operating system catalog entries.

## SYNTAX

```
Get-OSDCoreOperatingSystems [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Imports normalized raw catalog records from Get-ModuleCoreOperatingSystems and
transforms them into OSD core operating system objects used by selection and
deployment workflows.
The function derives build identity, Windows family and
release, normalized architecture, activation channel, and compatibility flags,
then returns unique sorted records.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreOperatingSystems
```

Returns all available parsed core operating system records.

### EXAMPLE 2
```
Get-OSDCoreOperatingSystems | Where-Object Version -eq 'Windows 11'
```

Returns only Windows 11 operating system records.

### EXAMPLE 3
```
Get-OSDCoreOperatingSystems | Where-Object { $_.Architecture -eq 'arm64' }
```

Returns only arm64 operating system records.

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

### None
### You cannot pipe input to this function.
## OUTPUTS

### PSCustomObject[]
### Parsed operating system records with OSD-specific properties.
## NOTES
Author: David Segura - Recast Software
2026-07-22 - Initial help block created
2026-08-05 - Expanded help content and examples

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

