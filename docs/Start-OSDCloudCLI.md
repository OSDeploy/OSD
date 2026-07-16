---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDCloudCLI

## SYNOPSIS
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

## SYNTAX

### Default (Default)
```
Start-OSDCloudCLI [-ComputerManufacturer <String>] [-ComputerProduct <String>] [-Firmware] [-Restart]
 [-Shutdown] [-Screenshot] [-SkipAutopilot] [-ZTI] [-OSName <String>] [-OSEdition <String>]
 [-OSLanguage <String>] [-OSActivation <String>] [<CommonParameters>]
```

### Legacy
```
Start-OSDCloudCLI [-ComputerManufacturer <String>] [-ComputerProduct <String>] [-Firmware] [-Restart]
 [-Shutdown] [-Screenshot] [-SkipAutopilot] [-ZTI] [-OSVersion <String>] [-OSReleaseID <String>]
 [-OSEdition <String>] [-OSLanguage <String>] [-OSActivation <String>] [<CommonParameters>]
```

### CustomImage
```
Start-OSDCloudCLI [-ComputerManufacturer <String>] [-ComputerProduct <String>] [-Firmware] [-Restart]
 [-Shutdown] [-Screenshot] [-SkipAutopilot] [-ZTI] [-FindImageFile] [-ImageFileUrl <String>]
 [-OSImageIndex <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

## EXAMPLES

### EXAMPLE 1
```
Start-OSDCloudCLI
```

Starts OSDCloud CLI interactively.

### EXAMPLE 2
```
Start-OSDCloudCLI -OSName 'Windows 11 25H2 x64' -OSEdition Enterprise -OSLanguage en-us
```

Starts OSDCloud CLI with explicit OS selections.

## PARAMETERS

### -ComputerManufacturer
Overrides the detected manufacturer used for driver pack matching.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Manufacturer

Required: False
Position: Named
Default value: (Get-MyComputerManufacturer -Brief)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerProduct
Overrides the detected product/system identifier used for driver pack matching.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Product

Required: False
Position: Named
Default value: (Get-MyComputerProduct)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Firmware
Enables firmware catalog processing for the deployment workflow.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Global:OSDModuleResource.StartOSDCloudGUI.updateFirmware
Accept pipeline input: False
Accept wildcard characters: False
```

### -Restart
Restarts the computer after deployment completes.

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

### -Shutdown
Shuts down the computer after deployment completes.

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

### -Screenshot
Captures screenshots during the workflow in WinPE.

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

### -SkipAutopilot
Skips Autopilot tasks in the deployment process.

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

### -ZTI
Enables zero-touch mode and suppresses disk wipe prompts.

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

### -OSName
Default parameter set OS selection, for example 'Windows 11 25H2 x64'.

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
Legacy parameter set operating system family.

```yaml
Type: String
Parameter Sets: Legacy
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSReleaseID
Legacy parameter set operating system release identifier.

```yaml
Type: String
Parameter Sets: Legacy
Aliases: Build, OSBuild

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
Target Windows edition.

```yaml
Type: String
Parameter Sets: Default, Legacy
Aliases: Edition

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Target Windows language/culture.

```yaml
Type: String
Parameter Sets: Default, Legacy
Aliases: Culture, OSCulture

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSActivation
Target activation channel: Retail or Volume.

```yaml
Type: String
Parameter Sets: Default, Legacy
Aliases: OSLicense

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FindImageFile
CustomImage parameter set switch to locate a local WIM/ESD file.

```yaml
Type: SwitchParameter
Parameter Sets: CustomImage
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageFileUrl
CustomImage parameter set URL to download a WIM/ESD image.

```yaml
Type: String
Parameter Sets: CustomImage
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSImageIndex
CustomImage parameter set image index.

```yaml
Type: Int32
Parameter Sets: CustomImage
Aliases: ImageIndex

Required: False
Position: Named
Default value: 0
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

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

