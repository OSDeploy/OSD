---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-MicrosoftUpdateCatalog

## SYNOPSIS
Tests connectivity to Microsoft Update Catalog.

## SYNTAX

```
Test-MicrosoftUpdateCatalog [[-Uri] <String>] [[-TimeoutSec] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Sends an HTTP request to Microsoft Update Catalog and returns True when the
endpoint is reachable with a successful or redirect status code.
Uses a
HEAD request first, then falls back to GET if needed.

## EXAMPLES

### EXAMPLE 1
```
Test-MicrosoftUpdateCatalog
```

Returns True when the default Microsoft Update Catalog endpoint is reachable.

### EXAMPLE 2
```
Test-MicrosoftUpdateCatalog -TimeoutSec 5
```

Tests connectivity with a shorter timeout.

## PARAMETERS

### -Uri
The Microsoft Update Catalog endpoint to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Https://www.catalog.update.microsoft.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSec
Timeout in seconds for each HTTP request attempt.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 15
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES
Author: David Segura - Recast Software
2026-07-11 - Improved request resilience and added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

