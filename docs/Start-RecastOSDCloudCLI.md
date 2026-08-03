---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-RecastOSDCloudCLI

## SYNOPSIS
Starts the Recast OSDCloud command-line deployment workflow.

## SYNTAX

```
Start-RecastOSDCloudCLI [[-OSArchitecture] <String>] [[-OSReleaseID] <String>] [[-OSLanguageCode] <String>]
 [[-OSActivation] <String>] [[-OSEdition] <String>] [[-OSDManufacturer] <String>] [[-OSDModel] <String>]
 [[-OSDProduct] <String>] [[-WinPEPostAction] <String>] [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Initializes device and deployment context, discovers matching operating systems,
resolves driver pack metadata for the current device (or supplied overrides),
validates required dependencies, and prepares global state consumed by
the Recast OSDCloud CLI workflow.
The deployment workflow runs only when
the Force switch is supplied.

## EXAMPLES

### EXAMPLE 1
```
Start-RecastOSDCloudCLI -Force
Starts OSDCloud CLI using detected device values and default deployment selection.
```

### EXAMPLE 2
```
Start-RecastOSDCloudCLI -OSArchitecture arm64 -OSEdition Pro -OSReleaseID 24H2 -Force
Starts OSDCloud CLI for an ARM64 Windows 11 Pro 24H2 deployment selection.
```

## PARAMETERS

### -OSArchitecture
Operating system architecture used when selecting catalog entries.
Supported values are amd64 and arm64.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
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
Position: 3
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
Position: 4
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
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WinPEPostAction
Specifies the action to take after the WinPE deployment workflow completes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: Quit
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Confirms that OSDCloud should run after initialization.
This switch is required
to start the deployment workflow because it can modify the deployment disk.

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

## NOTES
Author: David Segura - Recast Software
2026-07-09 - Standardized comment-based help metadata and links.
2026-07-14 - Updated help content for CLI-specific behavior and parameter documentation.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

