---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCoreDriverPacks

## SYNOPSIS
Retrieves driver pack information for the specified manufacturer and operating system architecture.

## SYNTAX

```
Get-OSDCoreDriverPacks [[-GenericDriverPackJson] <String>] [[-OSDManufacturer] <String>]
 [[-ProcessorArchitecture] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets driver pack catalogs based on the device manufacturer and OS architecture.
For AMD64 architecture,
manufacturer-specific catalogs are loaded.
For ARM64 and other architectures, the default catalog is returned.
Supports Dell, HP, Lenovo, Microsoft (Surface), and generic devices.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCoreDriverPacks
```

Returns driver packs for the current device's manufacturer and architecture.

### EXAMPLE 2
```
Get-OSDCoreDriverPacks -OSDManufacturer 'Dell' -ProcessorArchitecture 'amd64'
```

Returns driver packs for Dell devices with AMD64 architecture.

## PARAMETERS

### -GenericDriverPackJson
{{ Fill GenericDriverPackJson Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\generic.json')
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSDManufacturer
The device manufacturer name.
Defaults to the value from $global:OSDCoreDevice.OSDManufacturer.
Supported values: Dell, HP, Lenovo, Microsoft, or any other value will use the Default catalog.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $global:OSDCoreDevice.OSDManufacturer
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessorArchitecture
The operating system architecture.
Defaults to the value from $global:OSDCoreDevice.ProcessorArchitecture.
Typically 'amd64' or 'arm64'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $env:PROCESSOR_ARCHITECTURE
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
### Array of driver pack objects containing driver information for the specified manufacturer and architecture.
## NOTES
Requires manufacturer-specific cmdlets (Get-OSDCoreDriverPackCatalogDell, Get-OSDCoreDriverPackCatalogHP, etc.) to be available.

## RELATED LINKS
