---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Expand-ZTIDriverPack

## SYNOPSIS
Expands driver packs during Lite Touch or Zero Touch deployment

## SYNTAX

```
Expand-ZTIDriverPack [<CommonParameters>]
```

## DESCRIPTION
Processes and extracts driver pack files from C:\Drivers directory during MDT/ConfigMgr task sequence execution.
Supports CAB, EXE, MSI, and ZIP formats from multiple vendors.

## EXAMPLES

### EXAMPLE 1
```
Expand-ZTIDriverPack
```

Expands all driver packs in C:\Drivers during task sequence

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

