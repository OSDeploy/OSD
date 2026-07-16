---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCloudOperatingSystemsIndexes

## SYNOPSIS
Returns OSDCloud operating system index entries by architecture.

## SYNTAX

```
Get-OSDCloudOperatingSystemsIndexes [-OSArch <String>] [<CommonParameters>]
```

## DESCRIPTION
Reads the cached OSDCloud operating system indexes and returns index
entries for the specified architecture.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCloudOperatingSystemsIndexes
```

Returns x64 operating system index entries from cache.

### EXAMPLE 2
```
Get-OSDCloudOperatingSystemsIndexes -OSArch ARM64
```

Returns ARM64 operating system index entries from cache.

## PARAMETERS

### -OSArch
Specifies the operating system architecture.
Valid values are x64 and ARM64.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

