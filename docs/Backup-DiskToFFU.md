---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Backup-DiskToFFU

## SYNOPSIS
Captures a physical disk to a Full Flash Update (FFU) image.

## SYNTAX

```
Backup-DiskToFFU [<CommonParameters>]
```

## DESCRIPTION
Interactively selects a source disk and destination data disk, then uses DISM /Capture-FFU to create an FFU backup from WinPE.

## EXAMPLES

### EXAMPLE 1
```
Backup-DiskToFFU
```

Prompts for source and destination disks, then captures the selected source disk to an FFU file.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-11 - Moved help block inside function and expanded sections

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu)

