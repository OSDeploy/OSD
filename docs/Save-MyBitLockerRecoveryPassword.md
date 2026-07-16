---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-MyBitLockerRecoveryPassword

## SYNOPSIS
Saves BitLocker recovery passwords to text files.

## SYNTAX

```
Save-MyBitLockerRecoveryPassword [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Exports recovery password protector values from unlocked volumes and writes
them as recovery key text files in one or more destination folders.

## EXAMPLES

### EXAMPLE 1
```
Save-MyBitLockerRecoveryPassword -Path 'D:\BitLockerBackup'
```

Exports recovery password text files to D:\BitLockerBackup.

## PARAMETERS

### -Path
One or more destination folders used to store recovery password files.

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

