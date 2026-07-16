---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-AdkISO

## SYNOPSIS
Creates an ISO file from a bootable media directory using ADK tools

## SYNTAX

```
New-AdkISO [[-WindowsAdkRoot] <String>] [-MediaPath] <String> [-isoFileName] <String> [-isoLabel] <String>
 [-OpenExplorer] [<CommonParameters>]
```

## DESCRIPTION
Creates an ISO file from a bootable media directory.
Requires the Windows Assessment and Deployment Kit (ADK) to be installed.

## EXAMPLES

### EXAMPLE 1
```
New-AdkISO -MediaPath 'C:\BootMedia' -isoFileName 'WinPE.iso' -isoLabel 'WinPE'
```

Creates an ISO file from the bootable media

## PARAMETERS

### -WindowsAdkRoot
Path to Windows ADK root directory.
Optional if ADK is in default location.

```yaml
Type: String
Parameter Sets: (All)
Aliases: AdkRoot

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath
Path to the directory containing the bootable media

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoFileName
Filename of the output ISO file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoLabel
Label of the ISO (limited to 16 characters)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenExplorer
Switch to open Windows Explorer to the parent directory of the ISO file after creation

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Updated help to follow OSD standard
2021-03-16 - Initial Release

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

