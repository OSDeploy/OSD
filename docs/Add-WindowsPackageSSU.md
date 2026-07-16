---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Add-WindowsPackageSSU

## SYNOPSIS
Adds a Servicing Stack Update package to Windows.

## SYNTAX

### Offline (Default)
```
Add-WindowsPackageSSU -PackagePath <String> -Path <String> [-LogPath <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Online
```
Add-WindowsPackageSSU -PackagePath <String> [-Online] [-LogPath <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Extracts SSU cabinet files from a .cab or .msu package and applies them to an online or offline Windows image using Add-WindowsPackage.

## EXAMPLES

### EXAMPLE 1
```
Add-WindowsPackageSSU -PackagePath C:\Updates\windows10.0-kbxxxx.msu -Path C:\Mount
Extracts SSU content from the MSU and applies it to the mounted image at C:\Mount.
```

### EXAMPLE 2
```
Add-WindowsPackageSSU -PackagePath C:\Updates\ssu.cab -Online
Applies SSU cab content to the running operating system.
```

## PARAMETERS

### -PackagePath
Full path to the source .cab or .msu package file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Full path to the root directory of the offline mounted Windows image.

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Applies the SSU to the currently running operating system.

```yaml
Type: SwitchParameter
Parameter Sets: Online
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogPath
Full path to the DISM log file used during package application.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: "$env:windir\Logs\Dism\dism.log"
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
2026-07-11 - Moved help block inside function and expanded sections

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
