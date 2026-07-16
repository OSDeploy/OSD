---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDriverPackCatalogSurface

## SYNOPSIS
Retrieves the Microsoft Surface driver pack catalog, enriching entries from live download pages.

## SYNTAX

```
Get-OSDCoreDriverPackCatalogSurface [[-LocalDriverPackCatalog] <String>] [-Force] [-LocalOnly]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Loads the bundled surface.json catalog as the offline base.
For entries that include an
UpdatePage URL, the function scrapes the corresponding Microsoft download page to find the
newest available MSI and updates FileName, Url, and ReleaseDate accordingly.
Results are cached in $env:TEMP so subsequent calls within the same session skip network
requests.
Falls back to base JSON values when a page cannot be reached.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDriverPackCatalogSurface
```

Returns all Surface driver pack entries, with live URLs where available.

### EXAMPLE 2
```
Get-OSDCoreDriverPackCatalogSurface -Verbose
```

Returns all Surface driver pack entries with verbose progress output.

### EXAMPLE 3
```
Get-OSDCoreDriverPackCatalogSurface -Force
```

Bypasses the temp cache and rebuilds the enriched catalog.

### EXAMPLE 4
```
Get-OSDCoreDriverPackCatalogSurface -LocalOnly
```

Processes only local catalog values without any live network checks.

## PARAMETERS

### -LocalDriverPackCatalog
Path to the local fallback Surface catalog JSON file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\surface.json')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Forces bypass of the temp cache and rebuilds the enriched catalog from the
local Surface catalog.

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

### -LocalOnly
Uses only local catalog values and skips connectivity probing and all live
UpdatePage checks.

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

### PSCustomObject[]
### Objects with CatalogVersion, ReleaseDate, Name, Manufacturer, Model, SystemId, FileName,
### Url, OperatingSystem, OSArchitecture, and HashMD5 properties.
## NOTES
Base catalog: core/driverpacks/surface.json (bundled with the module)
Temp cache:   $env:TEMP\osdcloud-driverpack-surface.json

## RELATED LINKS
