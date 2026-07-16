---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-WindowsImage

## SYNOPSIS
Tests WindowsImage conditions.

## SYNTAX

```
Test-WindowsImage [-ImagePath] <String> [-Index <UInt32>] [-Extension <String>] [<CommonParameters>]
```

## DESCRIPTION
Evaluates WindowsImage state and returns a validation result for scripting decisions.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Test-WindowsImage.

## PARAMETERS

### -ImagePath
Specifies the ImagePath to use when running Test-WindowsImage.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Index
Specifies the Index to use when running Test-WindowsImage.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: ImageIndex

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Extension
Specifies the Extension to use when running Test-WindowsImage.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

