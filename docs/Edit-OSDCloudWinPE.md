---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-winpe
schema: 2.0.0
---

# Edit-OSDCloudWinPE

## SYNOPSIS
Edits WinPE in an OSDCloud Workspace

## SYNTAX

```
Edit-OSDCloudWinPE [-Brand <String>] [-CloudDriver <String[]>] [-DriverHWID <String[]>]
 [-DriverPath <String[]>] [-PSModuleCopy <String[]>] [-PSModuleInstall <String[]>] [-Startnet <String>]
 [-StartOSDCloud <String>] [-StartOSDCloudGUI] [-StartOSDPad <String>] [-StartPSCommand <String>]
 [-StartWebScript <String>] [-UpdateUsb] [-Wallpaper <String>] [-WorkspacePath <String>] [<CommonParameters>]
```

## DESCRIPTION
Edits WinPE in an OSDCloud Workspace

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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

### -CloudDriver
WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,USB,VMware,WiFi

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

### -DriverHWID
WinPE Driver: HardwareID of the Driver to add to WinPE

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

### -DriverPath
WinPE Driver: Path to additional Drivers you want to install

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
Copies named PowerShell Modules from the running OS to WinPE

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
Installs named PowerShell Modules from PowerShell Gallery to WinPE

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
WinPE Startup: Modifies Startnet.cmd to execute Start-OSDCloud with the specified string

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

### -StartWebScript
WinPE Startup: Modifies Startnet.cmd to execute the specified string before OSDCloud

```yaml
Type: String
Parameter Sets: (All)
Aliases: WebPSScript

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateUsb
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
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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
