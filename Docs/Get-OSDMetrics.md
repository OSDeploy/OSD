---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/general/get-osdgather
schema: 2.0.0
---

# Get-OSDMetrics

## SYNOPSIS
Retrieves metrics for the OSD PowerShell module and OSDCloud deployment methods.

## SYNTAX

```
Get-OSDMetrics [<CommonParameters>]
```

## DESCRIPTION
The Get-OSDMetrics script retrieves metrics for the OSD PowerShell module and OSDCloud deployment methods.
It displays the latest version of the OSD PowerShell module, the date it was published, and the number of times it has been installed or saved.
It also displays metrics for OSDCloud CLI, OSDCloud GUI, and OSDCloud Azure deployment methods, including the number of devices deployed, the current usage rate, and the number of devices deployed per day, week, month, and year.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDMetrics
```

This example retrieves metrics for the OSD PowerShell module and OSDCloud deployment methods.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This script requires the OSD PowerShell module and the OSDCloudCLI, OSDCloudGUI, and OSDCloudAzure modules to be installed.

## RELATED LINKS
