---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreLicense

## SYNOPSIS
Returns a single Recast Core license object.

## SYNTAX

```
Get-OSDCoreLicense [[-Path] <String>] [[-PreferredEmail] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Reads .license2 files from the Recast Software license directory, parses the
JSON payload, validates expected fields, removes duplicates, and returns one
selected license object.
Selection precedence is:
1) PreferredEmail exact match (when provided)
2) Any non-empty email that is not support@recastsoftware.com
3) support@recastsoftware.com fallback
4) Empty or null email
Expired licenses are still eligible for selection.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreLicense
Returns a selected validated license object from ProgramData\Recast Software\Licenses.
```

### EXAMPLE 2
```
Get-OSDCoreLicense -Path 'D:\Licenses'
Returns a selected validated license object from a custom directory.
```

### EXAMPLE 3
```
Get-OSDCoreLicense -PreferredEmail 'david@segura.org'
Prefers a license with the specified email when available.
```

## PARAMETERS

### -Path
The directory path to search for .license2 files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path -Path $env:ProgramData -ChildPath 'Recast Software\Licenses')
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreferredEmail
Optional preferred email value used to prioritize license selection when
multiple license files exist.
Comparison is case-insensitive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

### PSCustomObject. Returns one selected license object, or $null when no
### license files are available.
## NOTES
Author: David Segura - Recast Software
2026-07-17 - Initial help block created
2026-07-17 - Added content parsing, validation, and de-duplication
2026-07-17 - Added single-object selection with email preference and support fallback

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

