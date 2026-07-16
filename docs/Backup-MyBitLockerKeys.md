---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Backup-MyBitLockerKeys

## SYNOPSIS
Saves available BitLocker key materials to one or more folders.

## SYNTAX

```
Backup-MyBitLockerKeys [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Calls helper functions to export external keys, key packages, and recovery
passwords for BitLocker-protected volumes.

## EXAMPLES

### EXAMPLE 1
```
Backup-MyBitLockerKeys -Path 'D:\BitLockerBackup'
```

Exports BitLocker key materials to D:\BitLockerBackup.

## PARAMETERS

### -Path
One or more destination folders used to store exported key materials.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

