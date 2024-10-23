---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-FeatureUpdate

## SYNOPSIS
Returns a Windows Client Feature Update

## SYNTAX

### ByOSName (Default)
```
Get-FeatureUpdate [-OSName <String>] [-OSArchitecture <String>] [-OSActivation <String>] [-OSLanguage <String>]
 [<CommonParameters>]
```

### v1
```
Get-FeatureUpdate [-OSVersion <String>] [-OSReleaseID <String>] [-OSArchitecture <String>]
 [-OSActivation <String>] [-OSLanguage <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a Windows Client Feature Update

## EXAMPLES

### EXAMPLE 1
```
Get-FeatureUpdate
```

## PARAMETERS

### -OSName
Operating System Name
Default = Windows 11 22H2 x64

```yaml
Type: String
Parameter Sets: ByOSName
Aliases: Name

Required: False
Position: Named
Default value: Windows 11 24H2 x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
Operating System Version
Default = Windows 11

```yaml
Type: String
Parameter Sets: v1
Aliases: Version

Required: False
Position: Named
Default value: Windows 11
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSReleaseID
Operating System ReleaseID
Default = 22H2

```yaml
Type: String
Parameter Sets: v1
Aliases: Build, OSBuild, ReleaseID

Required: False
Position: Named
Default value: 24H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArchitecture
Operating System Architecture
Default = x64

```yaml
Type: String
Parameter Sets: (All)
Aliases: Arch, OSArch, Architecture

Required: False
Position: Named
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSActivation
Operating System Activation
Default = Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases: License, OSLicense, Activation

Required: False
Position: Named
Default value: Volume
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Operating System Language
Default = en-us

```yaml
Type: String
Parameter Sets: (All)
Aliases: Culture, OSCulture, Language

Required: False
Position: Named
Default value: En-us
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

