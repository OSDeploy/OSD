---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreCacheDrive

## SYNOPSIS
Returns OSDCloud cache drive metadata from local file system drives.

## SYNTAX

```
Get-OSDCoreCacheDrive [[-Include] <String[]>] [[-Exclude] <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Enumerates mounted file system drives that contain an OSDCloud cache path
and returns only USB, DriveRoot, VolumeLabel, and VolumeUniqueId properties.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreCacheDrive
```

Returns OSDCloud cache drive metadata for all mounted file system drives.

### EXAMPLE 2
```
Get-OSDCoreCacheDrive -Include C,D -Exclude D
```

Returns OSDCloud cache drive metadata only for drive C.

## PARAMETERS

### -Include
Optional list of drive letters to include when searching for OSDCloud cache
paths.
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
paths.
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

### System.Object[]. Objects with USB, DriveRoot, VolumeLabel, and VolumeUniqueId.
## NOTES
Author: David Segura - Recast Software
2026-07-18 - Initial function created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

