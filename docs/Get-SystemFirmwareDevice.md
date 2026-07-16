---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-SystemFirmwareDevice

## SYNOPSIS
Returns the system firmware device

## SYNTAX

```
Get-SystemFirmwareDevice [<CommonParameters>]
```

## DESCRIPTION
Retrieves the system firmware device by querying Win32_PnpEntity for the System Firmware class GUID.

## EXAMPLES

### EXAMPLE 1
```
Get-SystemFirmwareDevice
```

Returns the system firmware device information

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Management.Infrastructure.CimInstance
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help
2026-07-11 - Improved CIM filtering and error handling

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

