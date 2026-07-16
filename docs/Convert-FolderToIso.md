---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Convert-FolderToIso

## SYNOPSIS
Creates an ISO file from a source folder.

## SYNTAX

```
Convert-FolderToIso [-folderFullName] <String> [-isoFullName <String>] [-isoLabel <String>] [-noPrompt]
 [-WindowsAdkRoot <FileInfo>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses Windows ADK oscdimg to create a standard or bootable ISO from a folder.
The function validates required boot files when present and supports optional
no-prompt UEFI boot media generation.

## EXAMPLES

### EXAMPLE 1
```
Convert-FolderToIso -folderFullName 'C:\OSD\Media'
Creates C:\OSD\Media.iso from the specified folder.
```

### EXAMPLE 2
```
Convert-FolderToIso -folderFullName 'C:\OSD\Media' -isoFullName 'C:\ISO\Custom.iso' -isoLabel 'CustomISO' -noPrompt
Creates a bootable ISO at the specified destination with a custom label.
```

## PARAMETERS

### -folderFullName
Source folder path to convert into an ISO.

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
If omitted, an ISO is created beside the source
folder using the folder name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: FolderToIso
Accept pipeline input: False
Accept wildcard characters: False
```

### -noPrompt
Uses efisys_noprompt.bin when available for UEFI boot media.

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

### -WindowsAdkRoot
Optional Windows ADK root path used to resolve oscdimg.exe.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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
