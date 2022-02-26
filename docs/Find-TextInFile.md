---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osdcloud.osdeploy.com
schema: 2.0.0
---

# Find-TextInFile

## SYNOPSIS
Simple function that searches for Text in Files

## SYNTAX

```
Find-TextInFile [-Path] <String> [-Text] <String> [[-Include] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Simple function that searches for Text in Files. 
Files selected in Out-GridView can be opened in VSCode

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Path to Search for Files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text
String to find in the Files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
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
Default value: *.txt
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
