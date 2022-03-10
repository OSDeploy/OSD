---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MsUpCat

## SYNOPSIS
Query catalog.update.micrsosoft.com for available updates.

## SYNTAX

```
Get-MsUpCat [-Search] <String> [[-SortBy] <String>] [-Descending] [-Strict] [-IncludeFileNames] [-AllPages]
 [<CommonParameters>]
```

## DESCRIPTION
Given that there is currently no public API available for the catalog.update.micrsosoft.com site, this
command makes HTTP requests to the site and parses the returned HTML for the required data.

## EXAMPLES

### EXAMPLE 1
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903"
```

### EXAMPLE 2
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -SortBy "Title" -Descending
```

### EXAMPLE 3
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -Strict
```

### EXAMPLE 4
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -IncludeFileNames
```

### EXAMPLE 5
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -AllPages
```

## PARAMETERS

### -Search
Specify a string to search for.

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

### -SortBy
Specify a field to sort the results by.
The default sort is by LastUpdated and in descending order.

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

### -Descending
Switch the sort order to descending.

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

### -Strict
Force a Search paramater with multiple words to be treated as a single string.

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

### -IncludeFileNames
Include the filenames for the files as they would be downloaded from catalog.update.micrsosoft.com.
This option will cause an extra web request for each update included in the results.
It is best to only
use this option with a very narrow search term.

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

### -AllPages
By default the Get-MSCatalogUpdate command returns the first page of results from catalog.update.micrsosoft.com, which is
limited to 25 updates.
If you specify this switch the command will instead return all pages of search results.
This can result in a significant increase in the number of HTTP requests to the catalog.update.micrsosoft.com endpoint.

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
