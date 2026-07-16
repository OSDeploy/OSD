---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MyBiosUpdate

## SYNOPSIS
Gets MyBiosUpdate information.

## SYNTAX

```
Get-MyBiosUpdate [[-Manufacturer] <String>] [[-Product] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns MyBiosUpdate data for the current system or OSD session context.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Get-MyBiosUpdate.

## PARAMETERS

### -Manufacturer
Specifies the Manufacturer to use when running Get-MyBiosUpdate.

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
Specifies the Product to use when running Get-MyBiosUpdate.

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
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

