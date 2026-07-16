---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MyDriverPack

## SYNOPSIS
Retrieves the driver pack for the current computer from OSDCloud

## SYNTAX

```
Get-MyDriverPack [[-Manufacturer] <String>] [[-Product] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Queries OSDCloud for a matching driver pack based on computer manufacturer and product model.

## EXAMPLES

### EXAMPLE 1
```
Get-MyDriverPack
Returns the driver pack for the current computer
```

### EXAMPLE 2
```
Get-MyDriverPack -Manufacturer 'Lenovo' -Product 'ThinkPad X1'
Returns the driver pack for the specified model
```

## PARAMETERS

### -Manufacturer
Computer manufacturer.
Default is auto-detected from current system

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-MyComputerManufacturer -Brief)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
Computer product model.
Default is auto-detected from current system

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-MyComputerProduct)
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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
