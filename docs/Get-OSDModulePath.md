---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDModulePath

## SYNOPSIS
Returns the base path of the loaded OSD module.

## SYNTAX

```
Get-OSDModulePath [<CommonParameters>]
```

## DESCRIPTION
Uses the current command invocation context to return the module base path
where the OSD module is installed or loaded from.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDModulePath
```

Returns the OSD module installation path.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String. The full module base path.
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

