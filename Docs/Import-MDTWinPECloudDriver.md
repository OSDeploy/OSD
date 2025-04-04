---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Import-MDTWinPECloudDriver

## SYNOPSIS
Imports OSDCloud CloudDrivers into an MDT Deployment Share

## SYNTAX

```
Import-MDTWinPECloudDriver [[-CloudDriver] <String[]>] [[-DriverHWID] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Imports OSDCloud CloudDrivers into an MDT Deployment Share

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CloudDriver
WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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
Position: 2
Default value: None
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

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

