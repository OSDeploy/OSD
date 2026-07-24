---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-WebConnection

## SYNOPSIS
Tests web connectivity to a target URI using a live TCP connection and HTTP HEAD request.

## SYNTAX

```
Test-WebConnection [[-Uri] <Uri>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Opens a live TCP connection and sends HTTP HEAD requests to the specified
URI, returning $true when the request succeeds and $false otherwise.
If a URI
is provided without a scheme, both https:// and http:// are tested.

## EXAMPLES

### EXAMPLE 1
```
Test-WebConnection -Uri 'http://example.com'
Returns $true when the target responds to an HTTP HEAD request.
```

### EXAMPLE 2
```
'google.com' | Test-WebConnection
Tests a bare URI supplied from the pipeline by checking both HTTPS and HTTP.
```

## PARAMETERS

### -Uri
URI to test.
Values from the pipeline are supported.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Http://www.google.com
Accept pipeline input: True (ByPropertyName, ByValue)
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
2026-07-16 - Moved help block inside function and improved request handling
2026-07-19 - Improved terminating error handling and verbose diagnostics
2026-07-19 - Added HTTPS and HTTP checks for bare URI values
2026-07-20 - Added live TCP validation before HTTP HEAD to avoid cached success responses

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

