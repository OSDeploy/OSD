---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-FeatureUpdate

## SYNOPSIS
Downloads the latest matching Windows client feature update package.

## SYNTAX

```
Save-FeatureUpdate [[-DownloadPath] <String>] [[-OSName] <String>] [[-OSActivation] <String>]
 [[-OSArchitecture] <String>] [[-OSLanguage] <String>] [[-OSReleaseID] <String>] [[-OSVersion] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries OSDCloud operating system metadata using language, activation,
architecture, and either OSName or legacy version/release criteria,
then downloads the newest matching feature update to the specified path.

## EXAMPLES

### EXAMPLE 1
```
Save-FeatureUpdate
Downloads the latest matching feature update using default filters.
```

### EXAMPLE 2
```
Save-FeatureUpdate -DownloadPath 'D:\OSDCloud\OS' -OSName 'Windows 11 24H2 arm64' -OSLanguage 'en-us' -OSActivation Volume
Downloads the latest matching Windows 11 24H2 arm64 volume feature update to D:\OSDCloud\OS.
```

## PARAMETERS

### -DownloadPath
Destination directory used to store the downloaded feature update file.
Defaults to C:\OSDCloud\OS.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DownloadFolder, Path

Required: False
Position: 1
Default value: C:\OSDCloud\OS
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OSName
Friendly OS target name used to select a specific version, release, and architecture profile.
Defaults to Windows 11 25H2 amd64.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: False
Position: 2
Default value: Windows 11 25H2 amd64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSActivation
Activation channel to filter on.
Valid values are Retail and Volume.

```yaml
Type: String
Parameter Sets: (All)
Aliases: License, OSLicense, Activation

Required: False
Position: 3
Default value: Volume
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArchitecture
Processor architecture to filter on.
Valid values are x64, amd64, and arm64.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Arch, OSArch, Architecture

Required: False
Position: 4
Default value: $env:PROCESSOR_ARCHITECTURE
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Language tag used to filter operating system content.
Defaults to en-us.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Culture, OSCulture, Language

Required: False
Position: 5
Default value: En-us
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSReleaseID
Feature update release identifier used with OSVersion for legacy version/release filtering.
Examples include 25H2, 24H2, 23H2, and 22H2.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Build, OSBuild, ReleaseID

Required: False
Position: 6
Default value: 25H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
Operating system family used with OSReleaseID for legacy version/release filtering.
Valid values are Windows 11 and Windows 10.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Version

Required: False
Position: 7
Default value: Windows 11
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

### System.IO.FileInfo
### Returns the downloaded file, or the existing local file when it is already present.
## NOTES
Author: David Segura - Recast Software
2026-07-16 - Updated comment-based help to match OSD standards

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

