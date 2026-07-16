---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-RecastOSDCloudGUI

## SYNOPSIS
Starts the Recast OSDCloud graphical deployment workflow.

## SYNTAX

```
Start-RecastOSDCloudGUI [[-BrandName] <String>] [[-BrandColor] <String>] [[-OSArchitecture] <String>]
 [[-OSReleaseID] <String>] [[-OSLanguageCode] <String>] [[-OSActivation] <String>] [[-OSEdition] <String>]
 [[-OSDManufacturer] <String>] [[-OSDModel] <String>] [[-OSDProduct] <String>] [-v2] [<CommonParameters>]
```

## DESCRIPTION
Initializes device and deployment context, discovers matching operating systems,
resolves driver pack metadata for the current device (or supplied overrides),
validates required dependencies, and then prepares global state consumed by
the Recast OSDCloud GUI workflow.

## EXAMPLES

### EXAMPLE 1
```
Start-RecastOSDCloudGUI
```

Starts OSDCloud GUI using detected device values and default branding.

### EXAMPLE 2
```
Start-RecastOSDCloudGUI -BrandName 'Contoso' -BrandColor '#005A9C'
```

Starts OSDCloud GUI with custom branding.

### EXAMPLE 3
```
Start-RecastOSDCloudGUI -OSArchitecture arm64 -OSEdition Pro -OSReleaseID 24H2
```

Starts OSDCloud GUI with an ARM64 Windows 11 Pro 24H2 deployment selection.

## PARAMETERS

### -BrandName
Sets the branding text shown in the OSDCloud GUI title/header.
Defaults to the module resource value.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Brand

Required: False
Position: 1
Default value: $Global:OSDModuleResource.StartOSDCloudGUI.BrandName
Accept pipeline input: False
Accept wildcard characters: False
```

### -BrandColor
Sets the branding color shown in the OSDCloud GUI.
Provide a hex color value, for example '#0096D6'.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Color

Required: False
Position: 2
Default value: $Global:OSDModuleResource.StartOSDCloudGUI.BrandColor
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSArchitecture
Operating system architecture used when selecting catalog entries.
Supported values are amd64 and arm64.

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

### -OSReleaseID
Operating system release identifier used for catalog selection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 25H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguageCode
Operating system language code used for catalog selection.
If not specified, the value is inferred from the current keyboard layout.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSActivation
Operating system activation channel used for catalog selection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Retail
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
Operating system edition used for catalog selection.
Valid values depend on OSArchitecture at runtime.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: Pro
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSDManufacturer
Overrides the detected computer manufacturer for driver pack matching.
If omitted, the detected device manufacturer is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSDModel
Overrides the detected computer model for logging and context alignment.
If omitted, the detected device model is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSDProduct
Overrides the detected computer product/system ID for driver pack matching.
If omitted, the detected device product value is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -v2
Legacy compatibility switch.
This parameter is non-functional and retained
temporarily to avoid breaking existing scripts.

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
Author: David Segura - Recast Software
2026-07-09 - Standardized comment-based help metadata and links.
2026-07-09 - The -v2 parameter is deprecated and will be removed in a future release.
2026-07-14 - Added complete parameter help coverage and updated examples.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

