---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs/New-OSDCloudTemplate.md
schema: 2.0.0
---

# New-OSDCloudTemplate

## SYNOPSIS
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

## SYNTAX

```
New-OSDCloudTemplate [[-Name] <String>] [[-Language] <String[]>] [[-CumulativeUpdate] <FileInfo>]
 [[-SetAllIntl] <String>] [[-SetInputLocale] <String>] [-WinRE] [-ARM64] [<CommonParameters>]
```

## DESCRIPTION
Creates an OSDCloud Template in $env:ProgramData\OSDCloud

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudTemplate
```

### EXAMPLE 2
```
New-OSDCloudTemplate -WinRE
```

## PARAMETERS

### -Name
Name of the OSDCloud Template.
This determines the OSDCloud Template Path

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
Adds additional language ADK Packages

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
Installs the specified Cumulative Update Package

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
Sets all International settings in WinPE to the specified setting

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
Sets the default InputLocale in WinPE to the specified Input Locale

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
Uses Windows 10 WinRE.wim instead of the ADK Boot.wim

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

### -ARM64
Uses ARM64 instead of AMD64

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs/New-OSDCloudTemplate.md](https://github.com/OSDeploy/OSD/tree/master/Docs/New-OSDCloudTemplate.md)

[https://www.osdcloud.com/setup/osdcloud-template](https://www.osdcloud.com/setup/osdcloud-template)

