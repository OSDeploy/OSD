---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-HPDriverPackLatest

## SYNOPSIS
Gets the latest available HP driver pack for a platform.

## SYNTAX

```
Get-HPDriverPackLatest [[-Platform] <String>] [-URL] [-download] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Checks supported OS releases for the target platform, searches from newest
to oldest release for Windows 11 and then Windows 10, and returns the first
matching Driver Pack entry found in the HPIA SoftPaq catalog.

## EXAMPLES

### EXAMPLE 1
```
Get-HPDriverPackLatest
Returns the latest driver pack metadata for the local platform.
```

### EXAMPLE 2
```
Get-HPDriverPackLatest -Platform 83B2 -URL
Returns only the driver pack URL for platform 83B2.
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

### -URL
Returns only the full download URL for the discovered driver pack.

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

### -download
Downloads the discovered driver pack to C:\Drivers using Save-WebFile.

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

