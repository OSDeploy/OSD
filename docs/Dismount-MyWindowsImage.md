---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Dismount-MyWindowsImage

## SYNOPSIS
Dismounts MyWindowsImage and finalizes changes.

## SYNTAX

### DismountDiscard (Default)
```
Dismount-MyWindowsImage [-Path <String[]>] [-Discard] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### DismountSave
```
Dismount-MyWindowsImage [-Path <String[]>] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Commits or discards changes to MyWindowsImage and then unmounts the image.

## EXAMPLES

### EXAMPLE 1
```

```

Demonstrates a common way to run Dismount-MyWindowsImage.

## PARAMETERS

### -Path
Specifies the Path to use when running Dismount-MyWindowsImage.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Discard
Specifies the Discard to use when running Dismount-MyWindowsImage.

```yaml
Type: SwitchParameter
Parameter Sets: DismountDiscard
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Save
Specifies the Save to use when running Dismount-MyWindowsImage.

```yaml
Type: SwitchParameter
Parameter Sets: DismountSave
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

