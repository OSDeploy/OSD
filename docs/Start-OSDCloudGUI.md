---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDCloudGUI

## SYNOPSIS
OSDCloud imaging using the command line

## SYNTAX

```
Start-OSDCloudGUI [[-BrandName] <String>] [[-BrandColor] <String>] [[-ComputerManufacturer] <String>]
 [[-ComputerProduct] <String>] [-v2] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
OSDCloud imaging using the command line

## EXAMPLES

### EXAMPLE 1
```
Start-OSDCloudGUI
Starts OSDCloud GUI with detected device values.
```

## PARAMETERS

### -BrandName
Sets the GUI brand text shown in the header/title.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Brand

Required: False
Position: 1
Default value: $Global:OSDModuleResource.StartOSDCloudGUI.BrandName
Accept pipeline input: False
Accept wildcard characters: False
```

### -BrandColor
Sets the GUI brand color.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Color

Required: False
Position: 2
Default value: $Global:OSDModuleResource.StartOSDCloudGUI.BrandColor
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerManufacturer
Overrides detected manufacturer for driver pack filtering.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-MyComputerManufacturer -Brief)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerProduct
Overrides detected product/system identifier for driver pack filtering.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: (Get-MyComputerProduct)
Accept pipeline input: False
Accept wildcard characters: False
```

### -v2
Legacy compatibility switch for manufacturer-based driver pack filtering.

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
2026-07-09 - Standardized comment-based help metadata and links.
2026-07-09 - The v2 parameter remains deprecated and retained temporarily for compatibility.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
