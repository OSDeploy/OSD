---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Find-TextInModule

## SYNOPSIS
Searches module files for matching text.

## SYNTAX

```
Find-TextInModule [-Text] <String> [[-Module] <String>] [[-Include] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves the latest installed version of a module, searches its files for matching text, shows results in Out-GridView, and opens selected files in Visual Studio Code when available.

## EXAMPLES

### EXAMPLE 1
```
Find-TextInModule -Text Save-WebFile -Module OSD -Include *.ps1
Searches PowerShell files in the latest installed OSD module for Save-WebFile.
```

## PARAMETERS

### -Text
Text pattern to search for in module files.

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
Module name to search.
The latest installed version is selected.

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
File include pattern(s) used by Get-ChildItem during the recursive search.

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
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
