---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MyWindowsCapability

## SYNOPSIS
Gets MyWindowsCapability information.

## SYNTAX

### Online (Default)
```
Get-MyWindowsCapability [-State <String>] [-Category <String>] [-Culture <String[]>] [-Like <String[]>]
 [-Match <String[]>] [-Detail] [-DisableWSUS] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Offline
```
Get-MyWindowsCapability -Path <String> [-State <String>] [-Category <String>] [-Culture <String[]>]
 [-Like <String[]>] [-Match <String[]>] [-Detail] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns MyWindowsCapability data for the current system or OSD session context.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Get-MyWindowsCapability.
```

## PARAMETERS

### -Path
Specifies the Path to use when running Get-MyWindowsCapability.

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -State
Specifies the State to use when running Get-MyWindowsCapability.

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

### -Category
Specifies the Category to use when running Get-MyWindowsCapability.

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

### -Culture
Specifies the Culture to use when running Get-MyWindowsCapability.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Like
Specifies the Like to use when running Get-MyWindowsCapability.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Match
Specifies the Match to use when running Get-MyWindowsCapability.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detail
Specifies the Detail to use when running Get-MyWindowsCapability.

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

### -DisableWSUS
Specifies the DisableWSUS to use when running Get-MyWindowsCapability.

```yaml
Type: SwitchParameter
Parameter Sets: Online
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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
