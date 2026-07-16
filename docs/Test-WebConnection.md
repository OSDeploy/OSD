---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-WebConnection

## SYNOPSIS
Tests web connectivity to a target URI using an HTTP HEAD request.

## SYNTAX

```
Test-WebConnection [[-Uri] <Uri>] [<CommonParameters>]
```

## DESCRIPTION
Sends an HTTP HEAD request to the specified URI and returns \`$true\` when the
request succeeds, otherwise \`$false\`.
If a URI is provided without a scheme,
\`http://\` is assumed.

## EXAMPLES

### EXAMPLE 1
```
Test-WebConnection -Uri 'http://example.com'
```

Returns \`$true\` when the target responds to an HTTP HEAD request.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-16 - Moved help block inside function and improved request handling

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

