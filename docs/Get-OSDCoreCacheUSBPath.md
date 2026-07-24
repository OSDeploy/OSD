---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreCacheUSBPath

## SYNOPSIS
Returns OSDCloud cache paths located on USB drives.

## SYNTAX

```
Get-OSDCoreCacheUSBPath [[-Include] <String[]>] [[-Exclude] <String[]>] [[-SizeRemaining] <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses Get-OSDCoreCacheDrive to enumerate OSDCloud cache drives and returns
the OSDCloud directory path for each discovered cache drive where USB is true,
the file system is NTFS or exFAT, and more than the specified free space is available.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreCacheUSBPath
```

Returns OSDCloud directory paths for all discovered USB cache drives with more than 10 GB free and an NTFS or exFAT file system.

### EXAMPLE 2
```
Get-OSDCoreCacheUSBPath -Include D
```

Returns the OSDCloud directory path when drive D contains an OSDCloud cache path, is a USB drive, has more than 10 GB free, and is formatted NTFS or exFAT.

### EXAMPLE 3
```
Get-OSDCoreCacheUSBPath -SizeRemaining 20
```

Returns OSDCloud directory paths for discovered USB cache drives with more than 20 GB free and an NTFS or exFAT file system.

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

### -SizeRemaining
Optional minimum free space required on the USB cache drive, in GB.

The default is 10 GB.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 10
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

### System.String[]. OSDCloud directory paths located on USB drives with more
### than the specified GB free and an NTFS or exFAT file system.
## NOTES
Author: David Segura - Recast Software
2026-07-18 - Initial function created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

