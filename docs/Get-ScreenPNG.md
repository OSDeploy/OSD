---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-ScreenPNG

## SYNOPSIS
Gets ScreenPNG information.

## SYNTAX

```
Get-ScreenPNG [[-Directory] <String>] [[-Prefix] <String>] [[-Delay] <UInt32>] [[-Count] <UInt32>] [-Clipboard]
 [-Primary] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns ScreenPNG data for the current system or OSD session context.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Get-ScreenPNG.
```

## PARAMETERS

### -Directory
Specifies the Directory to use when running Get-ScreenPNG.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix
Specifies the Prefix to use when running Get-ScreenPNG.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delay
Specifies the Delay to use when running Get-ScreenPNG.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
Specifies the Count to use when running Get-ScreenPNG.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clipboard
Specifies the Clipboard to use when running Get-ScreenPNG.

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

### -Primary
Specifies the Primary to use when running Get-ScreenPNG.

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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
