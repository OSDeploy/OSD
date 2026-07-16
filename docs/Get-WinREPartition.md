---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-WinREPartition

## SYNOPSIS
Retrieves the Windows Recovery Environment partition information

## SYNTAX

```
Get-WinREPartition [<CommonParameters>]
```

## DESCRIPTION
Returns the partition information for the Windows Recovery Environment (WinRE) WIM file.
This function must be run in Windows.

## EXAMPLES

### EXAMPLE 1
```
Get-WinREPartition
```

Returns the WinRE partition information

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Management.Infrastructure.CimInstance
### Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Updated help to follow OSD standard

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

