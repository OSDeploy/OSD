---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Convert-EsdToWim

## SYNOPSIS
Converts an ESD file into a WIM image.

## SYNTAX

```
Convert-EsdToWim [-esdFullName] <String> [[-wimFullName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Exports non-setup Windows indexes from an ESD source into a new WIM file.

## EXAMPLES

### EXAMPLE 1
```
Convert-EsdToWim -esdFullName 'C:\Media\install.esd'
```

Exports Windows image indexes from the ESD into install.wim.

## PARAMETERS

### -esdFullName
Full path to the source ESD file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -wimFullName
Destination WIM file path.
If omitted, a WIM is created beside the ESD.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

