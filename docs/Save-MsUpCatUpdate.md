---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/general/save-clipboardimage
schema: 2.0.0
---

# Save-MsUpCatUpdate

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Save-MsUpCatUpdate [[-OS] <String>] [[-Arch] <String>] [[-Build] <String>] [[-Category] <String>]
 [[-Include] <String[]>] [[-DestinationDirectory] <String>] [-Latest] [<CommonParameters>]
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

### -Arch
{{ Fill Arch Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Architecture
Accepted values: x64, x86

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Build
{{ Fill Build Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: 21H2, 21H1, 20H2, 2004, 1909, 1903, 1809, 1803, 1709, 1703, 1607, 1511, 1507

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
{{ Fill Category Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: LCU, SSU, DotNetCU

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationDirectory
{{ Fill DestinationDirectory Description }}

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

### -Include
{{ Fill Include Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Preview

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest
{{ Fill Latest Description }}

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

### -OS
{{ Fill OS Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: OperatingSystem
Accepted values: Windows 10, Windows Server, Windows Server 2016, Windows Server 2019

Required: False
Position: 0
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
