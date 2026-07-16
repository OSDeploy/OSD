---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MsUpCat

## SYNOPSIS
Retrieves Microsoft updates from the Microsoft Update Catalog

## SYNTAX

### Search (Default)
```
Get-MsUpCat [-Architecture <String>] [-Descending] [-ExcludeFramework] [-FromDate <DateTime>]
 [-Format <String>] [-GetFramework] [-AllPages] [-IncludeDynamic] [-IncludeFileNames] [-IncludePreview]
 [-LastDays <Int32>] [-MaxSize <Double>] [-MinSize <Double>] [-Properties <String[]>] [-Search] <String>
 [-SizeUnit <String>] [-SortBy <String>] [-Strict] [-ToDate <DateTime>] [-UpdateType <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### OS
```
Get-MsUpCat [-Architecture <String>] [-Descending] [-ExcludeFramework] [-FromDate <DateTime>]
 [-Format <String>] [-GetFramework] [-AllPages] [-IncludeDynamic] [-IncludeFileNames] [-IncludePreview]
 [-LastDays <Int32>] [-MaxSize <Double>] [-MinSize <Double>] -OperatingSystem <String> [-Properties <String[]>]
 [-SizeUnit <String>] [-SortBy <String>] [-Strict] [-ToDate <DateTime>] [-UpdateType <String[]>]
 [-Version <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches the Microsoft Update Catalog for updates and returns information about available patches, driver packs, and other updates.

## EXAMPLES

### EXAMPLE 1
```
Get-MsUpCat -Architecture x64
Retrieves x64 updates from Microsoft Update Catalog
```

## PARAMETERS

### -Architecture
Filter results by processor architecture.
Valid values are All, x64, x86, or arm64.
Default is All.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Descending
Sort results in descending order by release date.

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

### -ExcludeFramework
Exclude .NET Framework updates from results.

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

### -FromDate
Filter updates from this date

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format
Format for the results

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -GetFramework
Only show .NET Framework updates

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
Search through all available pages

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

### -IncludeDynamic
Include dynamic updates

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
Include file names in the results

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

### -IncludePreview
Include preview updates

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

### -LastDays
Filter updates from the last N days

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxSize
Filter updates with maximum size

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinSize
Filter updates with minimum size

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperatingSystem
Operating System to search updates for

```yaml
Type: String
Parameter Sets: OS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Select specific properties to display

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Search query for Microsoft Update Catalog

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeUnit
Unit for size filtering (MB or GB)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: MB
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy
Sort results by specified field

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Date
Accept pipeline input: False
Accept wildcard characters: False
```

### -Strict
Use strict search with exact phrase matching

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

### -ToDate
Filter updates until this date

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateType
Filter by update type

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
endregion Parameters

```yaml
Type: String
Parameter Sets: OS
Aliases:

Required: False
Position: Named
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

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
