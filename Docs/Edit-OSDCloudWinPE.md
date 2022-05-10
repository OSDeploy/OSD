---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-winpe
schema: 2.0.0
---

# Edit-OSDCloudWinPE

## SYNOPSIS
Edits WinPE in an OSDCloud Workspace for customization

## SYNTAX

```
Edit-OSDCloudWinPE [-CloudDriver <String[]>] [-StartOSDCloudGUI] [-DriverHWID <String[]>]
 [-DriverPath <String[]>] [-PSModuleCopy <String[]>] [-PSModuleInstall <String[]>] [-Startnet <String>]
 [-StartOSDCloud <String>] [-StartOSDPad <String>] [-StartPSCommand <String>] [-StartURL <String>] [-UpdateUSB]
 [-Wallpaper <FileInfo>] [-UseDefaultWallpaper] [-Brand <String>] [-WorkspacePath <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Edits WinPE in an OSDCloud Workspace for customization

## EXAMPLES

### EXAMPLE 1
```
Edit-OSDCloudWinPE -StartOSDCloudGUI
```

### EXAMPLE 2
```
Edit-OSDCloudWinPE -StartOSDCloud '-OSBuild 21H2 -OSEdition Pro -OSLanguage en-us -OSLicense Retail'
```

### EXAMPLE 3
```
Edit-OSDCloudWinPE â€"StartURL 'https://sandbox.osdcloud.com'
```

## PARAMETERS

### -CloudDriver
WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi

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
WinPE Startup: Modifies Startnet.cmd to execute Start-OSDCloudGUI

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
WinPE Driver: HardwareID of the Driver to add to WinPE

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
WinPE Driver: Path to additional Drivers you want to add to WinPE

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
PowerShell: Copies named PowerShell Modules from the running OS to WinPE
This is useful for adding Modules that are customized or not on PowerShell Gallery

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
PowerShell: Installs named PowerShell Modules from PowerShell Gallery to WinPE

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
WinPE Startup: Modifies Startnet.cmd to execute the specified string

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
WinPE Startup: Modifies Startnet.cmd to execute Start-OSDCloud with the specified string parameters

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
WinPE Startup: Modifies Startnet.cmd to execute Start-OSDPad with the specified string

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
WinPE Startup: Modifies Startnet.cmd to execute the specified string before OSDCloud

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
WinPE Startup: Modifies Startnet.cmd to execute the specified string before OSDCloud

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
After WinPE has been updated, the contents of the OSDCloud Workspace will be updated on any OSDCloud USB Drives

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
Sets the specified Wallpaper JPG file as the WinPE Background

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
Uses the default OSDCloud Wallpaper

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
Sets the custom Brand for OSDCloudGUI

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
Directory for the OSDCloudWorkspace which contains Media directory
This is optional as the OSDCloudWorkspace is returned by Get-OSDCloudWorkspace automatically

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://www.osdcloud.com/setup/osdcloud-winpe](https://www.osdcloud.com/setup/osdcloud-winpe)

