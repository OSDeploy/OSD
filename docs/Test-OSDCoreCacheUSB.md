---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-OSDCoreCacheUSB

## SYNOPSIS
Tests whether any OSDCloud cache drive is a USB drive.

## SYNTAX

```
Test-OSDCoreCacheUSB [[-Include] <String[]>] [[-Exclude] <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Uses Get-OSDCoreCacheDrive to enumerate OSDCloud cache drives and returns
true when at least one discovered cache drive has USB set to true.

## EXAMPLES

### EXAMPLE 1
```
Test-OSDCoreCacheUSB
```

Returns true if any discovered OSDCloud cache drive is a USB drive.

### EXAMPLE 2
```
Test-OSDCoreCacheUSB -Include D
```

Returns true if drive D contains an OSDCloud cache path and is a USB drive.

## PARAMETERS

### -Include
Optional list of drive letters to include when searching for OSDCloud cache
drives.
Accepts values such as 'C', 'D:', or 'E:\'.

When omitted, all mounted file system drive letters are considered.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
Optional list of drive letters to exclude when searching for OSDCloud cache
drives.
Accepts values such as 'C', 'D:', or 'E:\'.

Excluded drives are skipped even when they are also present in Include.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

### System.Boolean. True when an OSDCloud cache drive is on USB; otherwise false.
## NOTES
Author: David Segura - Recast Software
2026-07-18 - Initial function created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

