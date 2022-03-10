---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com
schema: 2.0.0
---

# Get-BaseCatalogDellSystem

## SYNOPSIS
Converts the Dell Catalog PC to a PowerShell Object

## SYNTAX

```
Get-BaseCatalogDellSystem [[-DownloadPath] <String>] [-Compatible] [[-Component] <String>] [<CommonParameters>]
```

## DESCRIPTION
Converts the Dell Catalog PC to a PowerShell Object
Requires Internet Access to download Dell CatalogPC.cab

## EXAMPLES

### EXAMPLE 1
```
Get-BaseCatalogDellSystem
```

Don't do this, you will get an almost endless list

### EXAMPLE 2
```
$Result = Get-BaseCatalogDellSystem
```

Yes do this. 
Save it in a Variable

### EXAMPLE 3
```
Get-BaseCatalogDellSystem -Component BIOS | Out-GridView
```

Displays all the Dell BIOS Updates in GridView

## PARAMETERS

### -DownloadPath
{{ Fill DownloadPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

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

### -Component
Filter the results based on these Components:
Application
BIOS
Driver
Firmware

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://osd.osdeploy.com](https://osd.osdeploy.com)

