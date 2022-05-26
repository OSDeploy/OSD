---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Start-OSDCloud

## SYNOPSIS
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

## SYNTAX

### Default (Default)
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-OSVersion <String>] [-OSBuild <String>] [-OSEdition <String>]
 [-OSLanguage <String>] [-OSLicense <String>] [<CommonParameters>]
```

### CustomImage
```
Start-OSDCloud [-Manufacturer <String>] [-Product <String>] [-Firmware] [-Restart] [-Shutdown] [-Screenshot]
 [-SkipAutopilot] [-SkipODT] [-ZTI] [-FindImageFile] [-ImageFileUrl <String>] [-ImageIndex <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Manufacturer
Automatically populated from Get-MyComputerManufacturer -Brief

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
Automatically populated from Get-MyComputerProduct

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
$Global:StartOSDCloud.ApplyCatalogFirmware = $true

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
Restart the computer after Invoke-OSDCloud to OOBE

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
Shutdown the computer after Invoke-OSDCloud

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
Captures screenshots during OSDCloud WinPE

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
Skips the Autopilot Task routine

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
Skips the ODT Task routine

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
Skip prompting to wipe Disks

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

### -OSVersion
Operating System Version of the Windows installation

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

### -OSBuild
Operating System Build of the Windows installation
Alias = Build

```yaml
Type: String
Parameter Sets: Default
Aliases: Build

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSEdition
Operating System Edition of the Windows installation
Alias = Edition

```yaml
Type: String
Parameter Sets: Default
Aliases: Edition

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Operating System Language of the Windows installation
Alias = Culture, OSCulture

```yaml
Type: String
Parameter Sets: Default
Aliases: Culture, OSCulture

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLicense
License of the Windows Operating System

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

### -FindImageFile
Searches for the specified WIM file

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
Downloads a WIM file specified by the URK

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

### -ImageIndex
Images using the specified Image Index

```yaml
Type: String
Parameter Sets: CustomImage
Aliases:

Required: False
Position: Named
Default value: AUTO
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

