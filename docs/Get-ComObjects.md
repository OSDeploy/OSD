---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-ComObjects

## SYNOPSIS
Lists registered COM ProgIDs from the local machine registry.

## SYNTAX

### FilterByName
```
Get-ComObjects -Filter <String> [<CommonParameters>]
```

### ListAllComObjects
```
Get-ComObjects [-ListAll] [<CommonParameters>]
```

## DESCRIPTION
Enumerates COM object ProgIDs under HKLM:\Software\Classes that map to a CLSID.
Use -ListAll to return the full list, or -Filter to return matching entries.

## EXAMPLES

### EXAMPLE 1
```
Get-ComObjects -ListAll
```

Returns all COM ProgIDs that contain a CLSID registration.

### EXAMPLE 2
```
Get-ComObjects -Filter 'Microsoft.Update.*'
```

Returns only COM ProgIDs that match the specified wildcard pattern.

## PARAMETERS

### -Filter
Wildcard pattern used to match ProgID names (for example, Microsoft.Update.*).

```yaml
Type: String
Parameter Sets: FilterByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListAll
Returns all discovered COM ProgIDs without applying a name filter.

```yaml
Type: SwitchParameter
Parameter Sets: ListAllComObjects
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-13 - Added standardized comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

