---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-HPSoftpaqListLatest

## SYNOPSIS
Gets the latest HPIA SoftPaq list for an HP platform.

## SYNTAX

```
Get-HPSoftpaqListLatest [[-Platform] <String>] [-SystemInfo] [-MaxOSVer] [-MaxOSNum]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves the latest supported OS information for a platform, downloads the
corresponding HPIA reference CAB, and returns the SoftPaq update list from
the extracted XML metadata.

## EXAMPLES

### EXAMPLE 1
```
Get-HPSoftpaqListLatest
Returns the latest SoftPaq list for the local platform.
```

### EXAMPLE 2
```
Get-HPSoftpaqListLatest -Platform 83B2 -SystemInfo
Returns system information metadata for platform 83B2.
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

### -SystemInfo
Returns system information from the HPIA XML instead of the SoftPaq list.

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
Reserved switch parameter in this function signature.

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
Reserved switch parameter in this function signature.

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

