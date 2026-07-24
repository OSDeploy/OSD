---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudTemplate

## SYNOPSIS
Creates resources by using New-OSDCloudTemplate.

## SYNTAX

```
New-OSDCloudTemplate [[-Name] <String>] [[-Language] <String[]>] [[-CumulativeUpdate] <FileInfo>]
 [[-SetAllIntl] <String>] [[-SetInputLocale] <String>] [-WinRE] [-Add7Zip] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for New-OSDCloudTemplate.

## EXAMPLES

### EXAMPLE 1
```
-Language <Language>
Runs New-OSDCloudTemplate with common parameters.
```

## PARAMETERS

### -Name
Specifies the value for Name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
Specifies the value for Language.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CumulativeUpdate
Specifies the value for CumulativeUpdate.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetAllIntl
Specifies the value for SetAllIntl.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetInputLocale
Specifies the value for SetInputLocale.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WinRE
Indicates whether to enable WinRE.

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

### -Add7Zip
Indicates whether to enable Add7Zip.

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
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

