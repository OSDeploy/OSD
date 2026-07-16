---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MyBitLockerKeyProtectors

## SYNOPSIS
Returns BitLocker key protector details for encrypted volumes.

## SYNTAX

```
Get-MyBitLockerKeyProtectors [-ShowRecoveryPassword] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Enumerates BitLocker volumes and returns protector metadata, with optional
inclusion of recovery password values.

## EXAMPLES

### EXAMPLE 1
```
Get-MyBitLockerKeyProtectors
Lists key protector details without recovery password values.
```

### EXAMPLE 2
```
Get-MyBitLockerKeyProtectors -ShowRecoveryPassword
Lists key protector details including recovery password values.
```

## PARAMETERS

### -ShowRecoveryPassword
Includes recovery password values in the output when specified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
