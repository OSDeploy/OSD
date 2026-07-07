---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-MsUpCat

## SYNOPSIS
{{ Fill in the Synopsis }}

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
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AllPages
Search through all available pages

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Filter updates by architecture

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, x64, x86, arm64

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Descending
Sort in descending order

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeFramework
Exclude .NET Framework updates

```yaml
Type: SwitchParameter
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
Accepted values: Default, CSV, JSON, XML

Required: False
Position: Named
Default value: None
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

### -GetFramework
Only show .NET Framework updates

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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
Default value: None
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
Default value: None
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
Default value: None
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
Default value: None
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
Default value: None
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperatingSystem
Operating System to search updates for

```yaml
Type: String
Parameter Sets: OS
Aliases:
Accepted values: Windows 11, Windows 10, Windows Server

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
Position: 0
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
Accepted values: MB, GB

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy
Sort results by specified field

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Date, Size, Title, Classification, Product

Required: False
Position: Named
Default value: None
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
Default value: None
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
Accepted values: Security Updates, Updates, Critical Updates, Feature Packs, Service Packs, Tools, Update Rollups, Cumulative Updates, Security Quality Updates, Driver Updates

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
OS Version/Release (e.g., 22H2, 21H2, 23H2)

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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
