---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-WindowsAdkISO

## SYNOPSIS
Creates an ISO file from a bootable media directory using ADK

## SYNTAX

```
New-WindowsAdkISO [-MediaPath] <FileInfo> [-isoFileName] <String> [-isoLabel] <String>
 [[-IsoDirectory] <FileInfo>] [[-WindowsAdkRoot] <FileInfo>] [-OpenExplorer]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates an ISO file from a bootable media directory using Windows Assessment and Deployment Kit (ADK) tools.

## EXAMPLES

### EXAMPLE 1
```
New-WindowsAdkISO -MediaPath 'C:\\Media' -isoFileName 'boot.iso' -isoLabel 'BootMedia'\n    Creates an ISO file from the bootable media
```

## PARAMETERS

### -MediaPath
Path to the directory containing the bootable media

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoFileName
Filename for the output ISO file

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

### -isoLabel
Label for the ISO volume (limited to 16 characters)

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

### -IsoDirectory
{{ Fill IsoDirectory Description }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: $((Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName)
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowsAdkRoot
Path to the Windows ADK root directory (optional if installed in default location)

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenExplorer
Opens Windows Explorer to the parent directory of the ISO File

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
2026-07-10 - Updated help to follow OSD standard
2025-03-01 - Updated to use Get-WindowsAdkPaths
2025-02-26 - Initial Release replacing New-AdkISO

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
