---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-OSDCloudOperatingSystems

## SYNOPSIS
Gets OSDCloud operating system entries for a specific architecture.

## SYNTAX

```
Get-OSDCloudOperatingSystems [[-OSArch] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries OSDCloud operating system data and returns entries that match the
requested operating system architecture.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCloudOperatingSystems
```

Returns x64 operating system entries.

### EXAMPLE 2
```
Get-OSDCloudOperatingSystems -OSArch arm64
```

Returns ARM64 operating system entries.

## PARAMETERS

### -OSArch
Specifies the operating system architecture to return.

Valid values:
- x64
- arm64

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### None. You cannot pipe input to this function.
## OUTPUTS

### PSCustomObject
### One or more operating system entries returned by Get-OSDCoreOperatingSystems.
## NOTES
25.2.17 Removed unnecessary Default ParameterSet Name
26.6.24 Refined comment-based help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

