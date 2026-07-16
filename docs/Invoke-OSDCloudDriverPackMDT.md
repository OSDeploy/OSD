---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-OSDCloudDriverPackMDT

## SYNOPSIS
Downloads a matching DriverPack to %OSDisk%\Drivers

## SYNTAX

```
Invoke-OSDCloudDriverPackMDT [[-Manufacturer] <String>] [[-Product] <String>] [<CommonParameters>]
```

## DESCRIPTION
Downloads a matching DriverPack to %OSDisk%\Drivers

## EXAMPLES

### EXAMPLE 1
```
Invoke-OSDCloudDriverPackMDT
```

Downloads and stages a matching driver pack during an MDT task sequence.

## PARAMETERS

### -Manufacturer
{{ Fill Manufacturer Description }}

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
{{ Fill Product Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

