---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudOSWimFile

## SYNOPSIS
Builds Windows setup media content for an OSDCloud feature update.

## SYNTAX

### Default (Default)
```
New-OSDCloudOSWimFile [-OSName <String>] [-OSEdition <String>] [-OSLanguage <String>] [-OSActivation <String>]
 [-CreateISO] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Legacy
```
New-OSDCloudOSWimFile [-OSEdition <String>] [-OSLanguage <String>] [-OSActivation <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves the target operating system image, determines the correct image index for the requested edition, downloads or locates the matching ESD, expands the setup content, and optionally creates an ISO file.

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudOSWimFile -OSName 'Windows 11 25H2 x64' -OSEdition Pro -OSLanguage en-us -OSActivation Retail -CreateISO
Prepares the Windows 11 25H2 x64 Pro retail media and builds an ISO file.
```

## PARAMETERS

### -OSName
Specifies the Windows release and architecture to build media for.

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: Windows 11 25H2 x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
Specifies the Windows edition to package into the setup media.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Edition

Required: False
Position: Named
Default value: Pro
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Specifies the language and culture of the Windows image.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Culture, OSCulture

Required: False
Position: Named
Default value: En-us
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSActivation
Specifies whether the image should target Retail or Volume activation.

```yaml
Type: String
Parameter Sets: (All)
Aliases: License, OSLicense, Activation

Required: False
Position: Named
Default value: Retail
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateISO
Creates an ISO file from the generated setup content after the image is prepared.

```yaml
Type: SwitchParameter
Parameter Sets: Default
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
2026-07-10 - Standardized comment-based help metadata and links.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files](https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files)

[https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11)

