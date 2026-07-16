---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDriverPackCatalogDell

## SYNOPSIS
Downloads and parses the Dell driver pack catalog for Windows 11.

## SYNTAX

```
Get-OSDCoreDriverPackCatalogDell [[-LocalDriverPackCatalog] <String>] [[-OemDriverPackCatalog] <String>]
 [-Force] [-LocalOnly] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the latest Dell DriverPackCatalog.cab from Dell's download site,
extracts and parses it to create a catalog of available Windows 11 driver packs.
If online retrieval fails, the function falls back to the bundled local catalog.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDriverPackCatalogDell
```

Retrieves the Dell driver pack catalog for Windows 11.

### EXAMPLE 2
```
Get-OSDCoreDriverPackCatalogDell -Force
```

Forces a fresh online download of the Dell catalog before parsing.

### EXAMPLE 3
```
Get-OSDCoreDriverPackCatalogDell -LocalDriverPackCatalog 'C:\Catalogs\dell.xml'
```

Uses a custom local fallback catalog path.

### EXAMPLE 4
```
Get-OSDCoreDriverPackCatalogDell -LocalOnly
```

Processes only local catalog values without any online download checks.

## PARAMETERS

### -LocalDriverPackCatalog
Path to the local fallback Dell catalog XML file.
This file is used when the
online catalog cannot be downloaded or extracted.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\dell.xml')
Accept pipeline input: False
Accept wildcard characters: False
```

### -OemDriverPackCatalog
URL to the online Dell DriverPack catalog CAB file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Https://downloads.dell.com/catalog/DriverPackCatalog.cab
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Forces download and rebuild of the temporary online catalog even when a
cached temp catalog file already exists.

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
Uses only local catalog values and skips online catalog download/extraction.

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

### PSCustomObject[]
### Returns custom objects with driver pack information including Name, Model,
### SystemId, URL, ReleaseDate, and other metadata.
## NOTES
Catalog is downloaded from https://downloads.dell.com/catalog/DriverPackCatalog.cab

## RELATED LINKS
