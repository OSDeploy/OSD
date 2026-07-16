---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Enable-PEWimPSGallery

## SYNOPSIS
Enables PowerShell Gallery functionality in a WinPE WIM file

## SYNTAX

```
Enable-PEWimPSGallery [-ImagePath] <String[]> [[-Index] <UInt32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Mounts a WinPE WIM file and configures it to support PowerShell Gallery functionality by modifying registry settings and environment variables.

## EXAMPLES

### EXAMPLE 1
```
Enable-PEWimPSGallery -ImagePath 'C:\WinPE\winpe.wim'
Enables PowerShell Gallery in the specified WIM file
```

## PARAMETERS

### -ImagePath
Full path to the WinPE WIM file to modify.
This parameter is mandatory and accepts pipeline input.

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

### -Index
Index of the WIM to mount.
Default is 1

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
