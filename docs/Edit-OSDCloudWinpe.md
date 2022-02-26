---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osdcloud.osdeploy.com
schema: 2.0.0
---

# Edit-OSDCloudWinpe

## SYNOPSIS
Edits the boot.wim in an OSDCloudWorkspace

## SYNTAX

```
Edit-OSDCloudWinpe [-Brand <Object>] [-CloudDriver <String[]>] [-DriverHWID <String[]>]
 [-DriverPath <String[]>] [-PSModuleCopy <String[]>] [-PSModuleInstall <String[]>] [-Startnet <String>]
 [-StartOSDCloud <String>] [-StartOSDCloudGUI] [-StartOSDPad <String>] [-StartPSCommand <String>]
 [-StartWebScript <String>] [-UpdateUsb] [-Wallpaper <String>] [-WorkspacePath <String>] [<CommonParameters>]
```

## DESCRIPTION
Edits the boot.wim in an OSDCloudWorkspace

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Brand
Sets the Brand for OSDCloudGUI

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: OSDCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloudDriver
Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,USB,VMware,WiFi

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
HardwareID of the Driver to add to WinPE

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
Path to additional Drivers you want to install

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
Copies named PowerShell Modules to WinPE

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
{{ Fill Startnet Description }}

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
{{ Fill StartOSDCloud Description }}

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
{{ Fill StartOSDCloudGUI Description }}

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
{{ Fill StartOSDPad Description }}

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
{{ Fill StartPSCommand Description }}

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
{{ Fill StartWebScript Description }}

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
{{ Fill UpdateUsb Description }}

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
{{ Fill Wallpaper Description }}

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

[https://osdcloud.osdeploy.com](https://osdcloud.osdeploy.com)

