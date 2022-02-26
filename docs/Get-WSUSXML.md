---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/
schema: 2.0.0
---

# Get-WSUSXML

## SYNOPSIS
Returns an Array of Microsoft Updates

## SYNTAX

```
Get-WSUSXML [[-Catalog] <String>] [-UpdateArch <String>] [-UpdateBuild <String>] [-UpdateGroup <String>]
 [-UpdateOS <String>] [-GridView] [-Silent] [<CommonParameters>]
```

## DESCRIPTION
Returns an Array of Microsoft Updates contained in the local WSUS Catalogs

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Catalog
Filter by Catalog Property

```yaml
Type: String
Parameter Sets: (All)
Aliases: Format

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateArch
Filter by UpdateArch Property

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateBuild
Filter by UpdateBuild Property

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateGroup
Filter by UpdateGroup Property

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateOS
Filter by UpdateOS Property

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GridView
Displays the results in GridView with -PassThru

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

### -Silent
Hide the Current Update Date information

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

## RELATED LINKS

[https://osd.osdeploy.com/](https://osd.osdeploy.com/)

