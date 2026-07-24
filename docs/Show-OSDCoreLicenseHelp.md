---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Show-OSDCoreLicenseHelp

## SYNOPSIS
Displays instructions for setting the Recast Core license for OSDCloud.

## SYNTAX

```
Show-OSDCoreLicenseHelp [[-LicensePath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides a concise, step-by-step guide to acquire and place the
Right Click Tools Community Edition license used by OSDCloud.
The function also checks the local license directory and reports
whether any .license2 files are currently present.

## EXAMPLES

### EXAMPLE 1
```
Show-OSDCoreLicenseHelp
Displays the default setup steps and checks ProgramData\Recast Software\Licenses.
```

### EXAMPLE 2
```
Show-OSDCoreLicenseHelp -LicensePath 'D:\Licenses'
Displays setup steps and checks a custom license directory.
```

## PARAMETERS

### -LicensePath
The directory path where .license2 files should be stored when not using
a full Right Click Tools Community Edition installation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path -Path $env:ProgramData -ChildPath 'Recast Software\Licenses')
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

## NOTES
Author: David Segura - Recast Software
2026-07-22 - Initial help block created
2026-07-22 - Added OSDCloud Recast Core license setup guidance

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://portal.recastsoftware.com/](https://portal.recastsoftware.com/)

