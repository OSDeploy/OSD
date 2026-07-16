---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-HPOSSupport

## SYNOPSIS
Gets supported Windows releases for an HP platform from the HPIA catalog.

## SYNTAX

```
Get-HPOSSupport [[-Platform] <String>] [-Latest] [-MaxOS] [-MaxOSVer] [-MaxOSNum]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Downloads and parses the HP platform catalog and returns operating system
support data for a specified platform or the local device platform.
Optional
switches can return only the latest supported OS values.

## EXAMPLES

### EXAMPLE 1
```
Get-HPOSSupport
Returns all supported OS entries for the local platform.
```

### EXAMPLE 2
```
Get-HPOSSupport -Platform 83B2 -MaxOSVer
Returns the maximum supported release ID for platform 83B2.
```

## PARAMETERS

### -Platform
HP platform ID to query.
If not provided, the local baseboard product ID is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest
Returns a combined string containing the latest supported OS description and release ID.

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

### -MaxOS
Returns the latest supported OS family as Win10 or Win11.

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

### -MaxOSVer
Returns the latest supported OS release ID value.

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

### -MaxOSNum
Returns the latest supported OS major version number as 10.0 or 11.0.

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
2026-07-13 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
