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
Get-FeatureUpdate [-OSName <String>] [-OSLicense <String>] [-OSLanguage <String>] [<CommonParameters>]
```

### v1
```
Get-FeatureUpdate [-OSVersion <String>] [-OSBuild <String>] [-OSArch <String>] [-OSLicense <String>]
 [-OSLanguage <String>] [<CommonParameters>]
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
{{ Fill OSName Description }}

```yaml
Type: String
Parameter Sets: ByOSName
Aliases:

Required: False
Position: Named
Default value: Windows 11 22H2 x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
Operating System Version
Default = Windows 11

```yaml
Type: String
Parameter Sets: v1
Aliases:

Required: False
Position: Named
Default value: Windows 11
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSBuild
Operating System Build
Default = 22H2

```yaml
Type: String
Parameter Sets: v1
Aliases: Build

Required: False
Position: Named
Default value: 22H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArch
Operating System Architecture
Default = x64

```yaml
Type: String
Parameter Sets: v1
Aliases:

Required: False
Position: Named
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLicense
Operating System Licensing
Default = Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases: License

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
Aliases: Culture, OSCulture

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

