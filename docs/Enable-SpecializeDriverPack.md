---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Enable-SpecializeDriverPack

## SYNOPSIS
Configures driver pack expansion during Windows Specialize phase

## SYNTAX

```
Enable-SpecializeDriverPack [<CommonParameters>]
```

## DESCRIPTION
Sets up an unattend XML file to automatically expand driver packs during the Windows Specialize pass.
Requires admin rights and Windows 10 or later.

## EXAMPLES

### EXAMPLE 1
```
Enable-SpecializeDriverPack
```

Configures the system to expand driver packs during Specialize phase

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

