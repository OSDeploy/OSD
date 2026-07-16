---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-ComObjMicrosoftUpdateInstaller

## SYNOPSIS
Creates and returns the Microsoft Update installer COM object.

## SYNTAX

```
Get-ComObjMicrosoftUpdateInstaller [<CommonParameters>]
```

## DESCRIPTION
Instantiates the Microsoft.Update.Installer COM object so callers can query
or manage update installation behavior through the Windows Update API.

## EXAMPLES

### EXAMPLE 1
```
Get-ComObjMicrosoftUpdateInstaller
```

Returns a Microsoft.Update.Installer COM object instance.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-13 - Added standardized comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

