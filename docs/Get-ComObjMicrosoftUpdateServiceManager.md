---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-ComObjMicrosoftUpdateServiceManager

## SYNOPSIS
Gets Windows Update service registration details through COM.

## SYNTAX

```
Get-ComObjMicrosoftUpdateServiceManager [<CommonParameters>]
```

## DESCRIPTION
Creates the Microsoft.Update.ServiceManager COM object and returns the
registered update Services collection from the local device.

## EXAMPLES

### EXAMPLE 1
```
Get-ComObjMicrosoftUpdateServiceManager
```

Returns registered Windows Update services from the local system.

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

