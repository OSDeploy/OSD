---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDCloud

## SYNOPSIS
Prepare and start an OSDCloud deployment session (selects image, language, edition and other options).

## SYNTAX

### Default (Default)
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-OSName <String>] [-OSEdition <String>] [-OSLanguage <String>]
 [-OSActivation <String>] [<CommonParameters>]
```

### Legacy
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-OSVersion <String>] [-OSBuild <String>] [-OSEdition <String>]
 [-OSLanguage <String>] [-OSActivation <String>] [<CommonParameters>]
```

### CustomImage
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-FindImageFile] [-ImageFileUrl <String>] [-OSImageIndex <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Start-OSDCloud gathers system information, validates prerequisites (PowerShell version, network,
presence of required utilities), and prepares a global configuration used by the OSDCloud workflow.
It can select a Windows Feature Update image from local catalogs or an image URL, prompt the user
for OS version/build/edition/culture when needed, and then calls Invoke-OSDCloud to run the deployment.

The function supports three parameter sets:
- Default: Choose a Windows feature update by name (recommended for normal interactive use).
- Legacy: Older style parameters (OSVersion + OSBuild) for backward compatibility.
- CustomImage: Use a custom WIM/ESD image from disk or a provided URL.

## EXAMPLES

### EXAMPLE 1
```
Start-OSDCloud
```

Interactive: choose image and options via menus.

### EXAMPLE 2
```
Start-OSDCloud -OSName 'Windows 11 25H2 x64' -OSEdition Enterprise -OSLanguage en-us -SkipAutopilot
```

Non-interactive: specify OS selection and suppress autopilot.

### EXAMPLE 3
```
Start-OSDCloud -FindImageFile -ImageFileUrl 'https://server.example.com/images/install.wim' -OSImageIndex 1
```

Use a custom image URL.

## PARAMETERS

### -Manufacturer
(Optional) Computer manufacturer string.
Automatically populated from Get-MyComputerManufacturer -Brief.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-MyComputerManufacturer -Brief)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
(Optional) Computer product string.
Automatically populated from Get-MyComputerProduct.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-MyComputerProduct)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Firmware
Switch.
When set, instructs the module to include firmware (MSC) catalog scanning.

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

### -Restart
Switch.
Restart the computer after the deployment finishes.

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
Switch.
Shutdown the computer after the deployment finishes.

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
Switch.
Capture screenshots during OSDCloud WinPE using Start-ScreenPNGProcess.
Screenshots are saved
to $env:TEMP\Screenshots by default.

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
Switch.
Skip AutoPilot enrollment tasks during the workflow.

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

### -SkipODT
Switch.
Skip running the Office Deployment Tool (ODT) tasks.

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
Switch.
Zero-touch install mode (ZTI).
When set, disk wipes proceed automatically without prompting.

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
(Default parameter set) A validated OS selection string such as 'Windows 11 25H2 x64'.
If omitted the
function prompts interactively (unless ZTI is used which selects sensible defaults).

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
(Legacy parameter set) Operating system family, e.g.
'Windows 11' or 'Windows 10'.

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

### -OSBuild
(Legacy parameter set) Operating system build (alias: Build) such as '25H2','24H2','23H2','22H2'.

```yaml
Type: String
Parameter Sets: Legacy
Aliases: Build

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
Edition of Windows to install (e.g.
'Enterprise', 'Pro', 'Home').
Affects edition mapping and activation
type (Retail vs Volume).

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
Language/culture tag to install (for example 'en-us', 'fr-fr', 'zh-cn').

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
License type for the installation.
Valid values are 'Retail' or 'Volume'.

```yaml
Type: String
Parameter Sets: Default, Legacy
Aliases: License, OSLicense, Activation

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FindImageFile
(CustomImage parameter set) Switch to prompt for a WIM/ESD file on removable media.

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
(CustomImage parameter set) URL to download a custom image if not available locally.

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
(CustomImage parameter set) Image index within a WIM/ESD.
Default is 0.

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

### None. The function does not accept pipeline input.
## OUTPUTS

### This function populates the global variable $Global:StartOSDCloud (an ordered hashtable) with the
### selected configuration and then invokes Invoke-OSDCloud. It does not return structured objects to the
### pipeline beyond writing progress and informational messages.
## NOTES
Author: David Segura - Recast Software
2026-07-09 - Standardized comment-based help metadata and links.
- Requires the OSD module helper functions used by the workflow (Get-FeatureUpdate, Invoke-OSDCloud,
  Find-OSDCloudFile, Get-MyComputerManufacturer, Get-MyComputerProduct, Start-ScreenPNGProcess, etc.).
- This function changes global state: $Global:StartOSDCloud and may interact with $Global:StartOSDCloudGUI.
- Intended to be run in WinPE or full Windows with administrative privileges.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

