---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Mount-MyWindowsImage

## SYNOPSIS
Mounts MyWindowsImage for servicing.

## SYNTAX

```
Mount-MyWindowsImage [-ImagePath] <String[]> [-Index <UInt32>] [-ReadOnly] [-Explorer] [<CommonParameters>]
```

## DESCRIPTION
Mounts MyWindowsImage and prepares it for offline servicing tasks.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Mount-MyWindowsImage.

## PARAMETERS

### -ImagePath
Specifies the ImagePath to use when running Mount-MyWindowsImage.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Index
Specifies the Index to use when running Mount-MyWindowsImage.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ReadOnly
Specifies the ReadOnly to use when running Mount-MyWindowsImage.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Explorer
Specifies the Explorer to use when running Mount-MyWindowsImage.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

