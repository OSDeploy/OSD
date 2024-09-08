---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-iso
schema: 2.0.0
---

# New-OSDCloudOSWimFile

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Default (Default)
```
New-OSDCloudOSWimFile [-OSName <String>] [-OSEdition <String>] [-OSLanguage <String>] [-OSActivation <String>]
 [-CreateISO] [<CommonParameters>]
```

### Legacy
```
New-OSDCloudOSWimFile [-OSEdition <String>] [-OSLanguage <String>] [-OSActivation <String>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CreateISO
{{ Fill CreateISO Description }}

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

### -OSActivation
{{ Fill OSActivation Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: License, OSLicense, Activation
Accepted values: Retail, Volume

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
{{ Fill OSEdition Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Edition
Accepted values: Home, Home N, Home Single Language, Education, Education N, Enterprise, Enterprise N, Pro, Pro N

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
{{ Fill OSLanguage Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Culture, OSCulture
Accepted values: ar-sa, bg-bg, cs-cz, da-dk, de-de, el-gr, en-gb, en-us, es-es, es-mx, et-ee, fi-fi, fr-ca, fr-fr, he-il, hr-hr, hu-hu, it-it, ja-jp, ko-kr, lt-lt, lv-lv, nb-no, nl-nl, pl-pl, pt-br, pt-pt, ro-ro, ru-ru, sk-sk, sl-si, sr-latn-rs, sv-se, th-th, tr-tr, uk-ua, zh-cn, zh-tw

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSName
{{ Fill OSName Description }}

```yaml
Type: String
Parameter Sets: Default
Aliases:
Accepted values: Windows 11 23H2 x64, Windows 11 23H2 ARM64, Windows 11 22H2 x64, Windows 11 21H2 x64, Windows 10 22H2 x64, Windows 10 22H2 ARM64

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
