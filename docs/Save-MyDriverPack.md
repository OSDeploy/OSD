---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Save-MyDriverPack

## SYNOPSIS
Downloads and optionally expands the driver pack for the current computer

## SYNTAX

```
Save-MyDriverPack [[-DownloadPath] <String>] [-Expand] [[-Manufacturer] <String>] [[-Product] <String>]
 [[-Guid] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Downloads the matching driver pack from OSDCloud for the current or specified computer.
Can optionally extract and expand the driver pack after download.

## EXAMPLES

### EXAMPLE 1
```
Save-MyDriverPack
Downloads the driver pack for the current computer to C:\Drivers
```

### EXAMPLE 2
```
Save-MyDriverPack -DownloadPath 'D:\DriverPacks' -Expand
Downloads and expands the driver pack to D:\DriverPacks
```

## PARAMETERS

### -DownloadPath
Directory where the driver pack will be saved.
Default is C:\Drivers

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\Drivers
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Expand
Automatically expands the driver pack archive after download

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

### -Manufacturer
Computer manufacturer.
Default is auto-detected

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-MyComputerManufacturer -Brief)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
Computer product model.
Default is auto-detected

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-MyComputerProduct)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Guid
GUID of a specific driver pack to download

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

