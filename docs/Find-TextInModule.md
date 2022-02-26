---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions
schema: 2.0.0
---

# Find-TextInModule

## SYNOPSIS
Simple function that searches for Text in a PowerShell Module

## SYNTAX

```
Find-TextInModule [-Text] <String> [[-Module] <String>] [[-Include] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Simple function that searches for Text in a PowerShell Module. 
Files selected in Out-GridView can be opened in VSCode

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Text
String to find

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Module
Module to search in. 
OSD is the default

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: OSD
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Files to include in the search. 
*.* is the default

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: *.*
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://osd.osdeploy.com/module/functions](https://osd.osdeploy.com/module/functions)

