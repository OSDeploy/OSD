---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Set-BootmgrTimeout

## SYNOPSIS
Sets the Windows Boot Manager timeout value in BCD.

## SYNTAX

```
Set-BootmgrTimeout [-Timeout] <UInt32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Updates the '{bootmgr}' timeout entry in BCD using bcdedit.
This controls
how many seconds the boot menu waits before selecting the default entry.

## EXAMPLES

### EXAMPLE 1
```
Set-BootmgrTimeout -Timeout 10
Sets the Boot Manager timeout to 10 seconds.
```

## PARAMETERS

### -Timeout
Timeout value in seconds to set on the Boot Manager entry.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
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

### System.Void
## NOTES
Author: David Segura - Recast Software
2026-07-11 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

