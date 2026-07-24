---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Update-MyDellBios

## SYNOPSIS
Downloads and launches a compatible BIOS update for the current Dell system.

## SYNTAX

```
Update-MyDellBios [[-DownloadPath] <String>] [-Force] [-Reboot] [-Silent] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Downloads the latest compatible Dell BIOS update, optionally prepares the
Flash64W utility for WinPE x64 scenarios, suspends BitLocker on the operating
system volume when needed, and launches the BIOS update installer.
The BIOS
installer log is written to $env:TEMP\Update-MyDellBios.log.
Administrative
rights are required.

## EXAMPLES

### EXAMPLE 1
```
Update-MyDellBios
Downloads and launches the compatible Dell BIOS update with the default
interactive installer behavior.
```

### EXAMPLE 2
```
Update-MyDellBios -Silent
Runs the compatible Dell BIOS update silently and does not add a reboot.
```

### EXAMPLE 3
```
Update-MyDellBios -Silent -Reboot
Runs the compatible Dell BIOS update silently and requests a reboot when the
installer completes.
```

## PARAMETERS

### -DownloadPath
Specifies the directory used to cache the BIOS update and supporting files.
The default location is the current user's temporary folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DownloadFolder, Path

Required: False
Position: 1
Default value: $env:TEMP
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Forces the update workflow even when the installed BIOS version comparison
would not normally trigger an update.

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

### -Reboot
Adds reboot arguments to the BIOS installer so the system reboots after the
silent update completes.

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

### -Silent
Runs the BIOS installer silently without automatically rebooting the system.

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
2021-03-04 - Initial release
2021-03-05 - Resolved issue with multiple objects
2021-03-09 - Started adding logic for WinPE
2026-07-22 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

