---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreCache

## SYNOPSIS
Returns cached OSDCloud content found on local file system drives.

## SYNTAX

```
Get-OSDCoreCache [[-Type] <String[]>] [[-Include] <String[]>] [[-Exclude] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Enumerates mounted file system drives and discovers OSDCloud cache content.
Returns objects with Type, Name, FullName, SizeMB,
DriveRoot, VolumeLabel, and VolumeUniqueId properties.

If Type is omitted, retur ns all supported cache content types.

Type values:
- ESD: All .esd files under '\<DriveLetter\>:\OSDCloud\OS' recursively.
- ISO: All .iso files under '\<DriveLetter\>:\OSDCloud\ISO' recursively.
- DriverPacks: All .cab, .exe, .msi, and .zip files under
  '\<DriveLetter\>:\OSDCloud\DriverPacks' recursively.
- Drivers: Immediate folders under '\<DriveLetter\>:\OSDCloud\Drivers' that
  contain at least one .inf file in any child folder.
        - Profiles: Immediate folders under '\<DriveLetter\>:\OSDCloud\Profiles'.
- WIM: All .wim files under '\<DriveLetter\>:\OSDCloud\WIM' recursively.
- *: Includes all supported Type values.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreCache
```

Returns all supported cache content types.

### EXAMPLE 2
```
Get-OSDCoreCache -Type ESD
```

Returns all .esd files under each discovered cache OS folder.

### EXAMPLE 3
```
Get-OSDCoreCache -Type ESD,DriverPacks
```

Returns all .esd files and driver pack files from each discovered cache.

### EXAMPLE 4
```
Get-OSDCoreCache -Type *
```

Returns all supported cache content types.

### EXAMPLE 5
```
Get-OSDCoreCache -Include C,D -Exclude D
```

Searches only drive C for supported cache content types.

## PARAMETERS

### -Type
Optional cache content selector.

Supports one or more values.
Use '*' to return all supported
cache content types.

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

### -Include
Optional list of drive letters to include when searching for OSDCloud cache
content.
Accepts values such as 'C', 'D:', or 'E:\'.

When omitted, all mounted file system drive letters are considered.

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

### -Exclude
Optional list of drive letters to exclude when searching for OSDCloud cache
content.
Accepts values such as 'C', 'D:', or 'E:\'.

Excluded drives are skipped even when they are also present in Include.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]. Objects with Type, Name, FullName, SizeMB,
### DriveRoot, VolumeLabel, and VolumeUniqueId.
## NOTES

## RELATED LINKS
