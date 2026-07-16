---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-HPSoftPaqItems

## SYNOPSIS
Gets HPIA SoftPaq items for a specific HP platform and OS release.

## SYNTAX

```
Get-HPSoftPaqItems [[-Platform] <String>] [-osver] <String> [-os] <String> [<CommonParameters>]
```

## DESCRIPTION
Validates that the requested operating system and release are supported by
the target platform, downloads the matching HPIA CAB metadata file, and
returns the SoftPaq update entries from the extracted XML.

## EXAMPLES

### EXAMPLE 1
```
Get-HPSoftPaqItems -osver 23H2 -os 11.0
```

Returns SoftPaq items for Windows 11 23H2 on the local platform.

### EXAMPLE 2
```
Get-HPSoftPaqItems -Platform 83B2 -osver 22H2 -os 10.0
```

Returns SoftPaq items for Windows 10 22H2 on platform 83B2.

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

### -osver
Operating system release ID value to query, such as 23H2.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -os
Operating system major version number to query.
Valid values are 10.0 and 11.0.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

