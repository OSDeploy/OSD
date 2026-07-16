---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDriverPackCatalogHP

## SYNOPSIS
Downloads and parses the HP driver pack catalog for Windows 11.

## SYNTAX

```
Get-OSDCoreDriverPackCatalogHP [[-LocalDriverPackCatalog] <String>] [[-OemDriverPackCatalog] <String>] [-Force]
 [-LocalOnly] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the latest HP Client Driver Pack Catalog from HP's cloud repository,
extracts and parses it to create a catalog of available Windows 11 driver packs.
Falls back to offline catalog if download fails.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDriverPackCatalogHP
```

Retrieves the HP driver pack catalog for Windows 11.

### EXAMPLE 2
```
Get-OSDCoreDriverPackCatalogHP -Force
```

Forces a refresh of the HP driver pack catalog by downloading the latest version
from HP's server, bypassing any cached copies.

### EXAMPLE 3
```
Get-OSDCoreDriverPackCatalogHP -LocalOnly
```

Processes only local catalog values without any online download checks.

## PARAMETERS

### -LocalDriverPackCatalog
Path to the local fallback HP catalog XML file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\hp.xml')
Accept pipeline input: False
Accept wildcard characters: False
```

### -OemDriverPackCatalog
URL to the online HP driver pack catalog CAB file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HPClientDriverPackCatalog.cab
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
Catalog is downloaded from https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HPClientDriverPackCatalog.cab

## RELATED LINKS
