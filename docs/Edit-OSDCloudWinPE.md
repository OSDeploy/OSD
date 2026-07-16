---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Edit-OSDCloudWinPE

## SYNOPSIS
Edits content by using Edit-OSDCloudWinPE.

## SYNTAX

```
Edit-OSDCloudWinPE [-CloudDriver <String[]>] [-StartOSDCloudGUI] [-DriverHWID <String[]>]
 [-DriverPath <String[]>] [-PSModuleCopy <String[]>] [-PSModuleInstall <String[]>] [-Startnet <String>]
 [-StartOSDCloud <String>] [-StartOSDPad <String>] [-StartPSCommand <String>] [-StartURL <String>] [-UpdateUSB]
 [-Wallpaper <FileInfo>] [-UseDefaultWallpaper] [-Brand <String>] [-WorkspacePath <String>] [-WirelessConnect]
 [-WifiProfile <FileInfo>] [-Add7Zip] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for Edit-OSDCloudWinPE.

## EXAMPLES

### EXAMPLE 1
```
-StartOSDCloudGUI
Runs Edit-OSDCloudWinPE with common parameters.
```

## PARAMETERS

### -CloudDriver
Specifies the value for CloudDriver.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartOSDCloudGUI
Indicates whether to enable StartOSDCloudGUI.

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

### -DriverHWID
Specifies the value for DriverHWID.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: HardwareID

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverPath
Specifies the value for DriverPath.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSModuleCopy
Specifies the value for PSModuleCopy.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSModuleInstall
Specifies the value for PSModuleInstall.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Modules

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Startnet
Specifies the value for Startnet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartOSDCloud
Specifies the value for StartOSDCloud.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartOSDPad
Specifies the value for StartOSDPad.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartPSCommand
Specifies the value for StartPSCommand.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartURL
Specifies the value for StartURL.

```yaml
Type: String
Parameter Sets: (All)
Aliases: WebPSScript, StartWebScript, StartCloudScript

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateUSB
Indicates whether to enable UpdateUSB.

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

### -Wallpaper
Specifies the value for Wallpaper.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseDefaultWallpaper
Indicates whether to enable UseDefaultWallpaper.

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

### -Brand
Specifies the value for Brand.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: OSDCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath
Specifies the value for WorkspacePath.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WirelessConnect
Indicates whether to enable WirelessConnect.

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

### -WifiProfile
Specifies the value for WifiProfile.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Add7Zip
Indicates whether to enable Add7Zip.

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
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
