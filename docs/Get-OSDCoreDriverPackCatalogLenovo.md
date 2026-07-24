---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDriverPackCatalogLenovo

## SYNOPSIS
Downloads and parses the Lenovo driver pack catalog for Windows 11.

## SYNTAX

```
Get-OSDCoreDriverPackCatalogLenovo [[-LocalDriverPackCatalog] <String>] [[-OemDriverPackCatalog] <String>]
 [-Force] [-LocalOnly] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the latest Lenovo SCCM driver pack catalog from Lenovo's download site,
parses the XML to create a catalog of available Windows 11 driver packs.
Falls back to offline catalog if download fails.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDriverPackCatalogLenovo
```

Retrieves the Lenovo driver pack catalog for Windows 11.

### EXAMPLE 2
```
Get-OSDCoreDriverPackCatalogLenovo -Force
```

Forces a fresh online download of the Lenovo catalog before parsing.

### EXAMPLE 3
```
Get-OSDCoreDriverPackCatalogLenovo -LocalOnly
```

Processes only local catalog values without any online download checks.

## PARAMETERS

### -LocalDriverPackCatalog
Path to the local fallback Lenovo catalog XML file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\lenovo.xml')
Accept pipeline input: False
Accept wildcard characters: False
```

### -OemDriverPackCatalog
URL to the online Lenovo driver pack catalog XML file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Https://download.lenovo.com/cdrt/td/catalogv2.xml
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
Uses only local catalog values and skips online catalog download.

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
### Returns custom objects with driver pack information including Name, Model,
### SystemId, URL, ReleaseDate, and other metadata.
## NOTES
Catalog is downloaded from https://download.lenovo.com/cdrt/td/catalogv2.xml

## RELATED LINKS
