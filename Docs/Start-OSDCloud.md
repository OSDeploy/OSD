---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdeploy.com/
schema: 2.0.0
---

# Start-OSDCloud

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Default (Default)
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-OSName <String>] [-OSEdition <String>] [-OSLanguage <String>]
 [-OSActivation <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Legacy
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-OSVersion <String>] [-OSBuild <String>] [-OSEdition <String>]
 [-OSLanguage <String>] [-OSActivation <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### CustomImage
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-FindImageFile] [-ImageFileUrl <String>] [-OSImageIndex <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -FindImageFile
{{ Fill FindImageFile Description }}

```yaml
Type: SwitchParameter
Parameter Sets: CustomImage
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Firmware
{{ Fill Firmware Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageFileUrl
{{ Fill ImageFileUrl Description }}

```yaml
Type: String
Parameter Sets: CustomImage
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Manufacturer
{{ Fill Manufacturer Description }}

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

### -OSActivation
{{ Fill OSActivation Description }}

```yaml
Type: String
Parameter Sets: Default, Legacy
Aliases: License, OSLicense, Activation
Accepted values: Retail, Volume

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSBuild
{{ Fill OSBuild Description }}

```yaml
Type: String
Parameter Sets: Legacy
Aliases: Build
Accepted values: 25H2, 24H2, 23H2, 22H2

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
Parameter Sets: Default, Legacy
Aliases: Edition
Accepted values: Home, Home N, Home Single Language, Education, Education N, Enterprise, Enterprise N, Pro, Pro N

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSImageIndex
{{ Fill OSImageIndex Description }}

```yaml
Type: Int32
Parameter Sets: CustomImage
Aliases: ImageIndex

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
Parameter Sets: Default, Legacy
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
Accepted values: Windows 11 25H2 x64, Windows 11 24H2 x64, Windows 11 23H2 x64, Windows 11 22H2 x64, Windows 10 22H2 x64

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
{{ Fill OSVersion Description }}

```yaml
Type: String
Parameter Sets: Legacy
Aliases:
Accepted values: Windows 11, Windows 10

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
{{ Fill Product Description }}

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

### -Restart
{{ Fill Restart Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Screenshot
{{ Fill Screenshot Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Shutdown
{{ Fill Shutdown Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipAutopilot
{{ Fill SkipAutopilot Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipODT
{{ Fill SkipODT Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ZTI
{{ Fill ZTI Description }}

```yaml
Type: SwitchParameter
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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
