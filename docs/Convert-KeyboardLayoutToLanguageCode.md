---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Convert-KeyboardLayoutToLanguageCode

## SYNOPSIS
Converts a Windows keyboard layout value to a language/culture code.

## SYNTAX

```
Convert-KeyboardLayoutToLanguageCode [[-KeyboardLayout] <String>] [[-FallbackLanguageCode] <String>]
 [-LowerCase] [<CommonParameters>]
```

## DESCRIPTION
Resolves the culture tag (for example, en-US or fr-FR) from a keyboard
layout hexadecimal string such as 00000409.
If no keyboard layout is
provided, the function attempts to detect the current layout from
Win32_Keyboard.
When conversion fails, a fallback language code is returned.

## EXAMPLES

### EXAMPLE 1
```
Convert-KeyboardLayoutToLanguageCode
```

Detects the active keyboard layout from Win32_Keyboard and returns the
resolved language code.

### EXAMPLE 2
```
Convert-KeyboardLayoutToLanguageCode -KeyboardLayout '0000040C'
```

Returns fr-FR.

### EXAMPLE 3
```
Convert-KeyboardLayoutToLanguageCode -KeyboardLayout '00000409' -LowerCase
```

Returns en-us.

## PARAMETERS

### -KeyboardLayout
Keyboard layout hexadecimal value (KLID), for example 00000409 or
00010409.
The function uses the trailing 4 hex characters as the LCID.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Layout, KLID

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FallbackLanguageCode
Language code to return when keyboard layout detection or conversion fails.
Default is en-US.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -LowerCase
Returns the language code in lowercase (for example en-us).

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-14 - Initial help block created
2026-07-14 - Added keyboard layout to language code conversion with fallback behavior

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values)

