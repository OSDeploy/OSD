---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Convert-EsdToIso

## SYNOPSIS
Converts an ESD file into an ISO image.

## SYNTAX

```
Convert-EsdToIso [-esdFullName] <String> [[-isoFullName] <String>] [[-isoLabel] <String>] [-noPrompt] [-Demo]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Expands and exports required images from an ESD into a temporary media
folder, then creates an ISO using Convert-FolderToIso.

## EXAMPLES

### EXAMPLE 1
```
Convert-EsdToIso -esdFullName 'C:\Media\install.esd'
Converts install.esd to an ISO in the same directory.
```

### EXAMPLE 2
```
Convert-EsdToIso -esdFullName 'C:\Media\install.esd' -isoFullName 'C:\ISO\Custom.iso' -isoLabel 'CustomISO' -noPrompt
Converts the ESD to a custom-labeled ISO at the specified path.
```

## PARAMETERS

### -esdFullName
Full path to the source ESD file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -isoFullName
Destination ISO file path.
If omitted, an ISO is created beside the ESD.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoLabel
ISO volume label.
Must be 1 to 16 characters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: EsdToIso
Accept pipeline input: False
Accept wildcard characters: False
```

### -noPrompt
Uses no-prompt UEFI boot image behavior when creating the ISO.

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

### -Demo
Shows conversion actions without exporting images.

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
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
