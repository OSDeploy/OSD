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
Get-FeatureUpdate [-Name <String>] [-Activation <String>] [-Language <String>] [<CommonParameters>]
```

### v1
```
Get-FeatureUpdate [-Version <String>] [-ReleaseID <String>] [-Architecture <String>] [-Activation <String>]
 [-Language <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a Windows Client Feature Update

## EXAMPLES

### EXAMPLE 1
```
Get-FeatureUpdate
```

## PARAMETERS

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: ByOSName
Aliases: OSName

Required: False
Position: Named
Default value: Windows 11 22H2 x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Operating System Version
Default = Windows 11

```yaml
Type: String
Parameter Sets: v1
Aliases: OSVersion

Required: False
Position: Named
Default value: Windows 11
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseID
Operating System Build
Default = 22H2

```yaml
Type: String
Parameter Sets: v1
Aliases: Build, OSBuild, OSReleaseID

Required: False
Position: Named
Default value: 22H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Operating System Architecture
Default = x64

```yaml
Type: String
Parameter Sets: v1
Aliases: Arch, OSArch

Required: False
Position: Named
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### -Activation
Operating System Licensing
Default = Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases: License, OSLicense, OSActivation

Required: False
Position: Named
Default value: Volume
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
Operating System Language
Default = en-us

```yaml
Type: String
Parameter Sets: (All)
Aliases: Culture, OSCulture, OSLanguage

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

