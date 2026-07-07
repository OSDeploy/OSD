---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-PowerSettingTurnMonitorOffAfter

## SYNOPSIS
Gets the active power plan monitor-off timeout in minutes.

## SYNTAX

```
Get-PowerSettingTurnMonitorOffAfter [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the "Turn off display after" timeout for the active power plan.
The function reads both AC (plugged in) and DC (battery) values from
power policy data in root\cimv2\power.

## EXAMPLES

### EXAMPLE 1
```
Get-PowerSettingTurnMonitorOffAfter
```

Returns a PSCustomObject with AC and DC monitor-off timeout values
in minutes.

## PARAMETERS

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

### PSCustomObject
## NOTES

## RELATED LINKS
