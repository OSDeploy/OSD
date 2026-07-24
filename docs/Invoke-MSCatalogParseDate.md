---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-MSCatalogParseDate

## SYNOPSIS
Parses a date string from Microsoft Update Catalog format

## SYNTAX

```
Invoke-MSCatalogParseDate [[-DateString] <String>]
```

## DESCRIPTION
Converts a date string in MM/DD/YYYY format (as returned by Microsoft Update Catalog) into a PowerShell DateTime object.

## EXAMPLES

### EXAMPLE 1
```
Invoke-MSCatalogParseDate -DateString "01/15/2025"
Returns a DateTime object for January 15, 2025
```

## PARAMETERS

### -DateString
Date string in MM/DD/YYYY format to parse

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

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

