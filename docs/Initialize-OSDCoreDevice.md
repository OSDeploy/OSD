---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Initialize-OSDCoreDevice

## SYNOPSIS
Collects local hardware, firmware, TPM, and network details for OSDCloud.

## SYNTAX

```
Initialize-OSDCoreDevice [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Initialize-OSDCoreDevice gathers device information from CIM classes, firmware,
and environment data, then normalizes manufacturer/model/product values for
workflow use.
It writes diagnostic logs to $env:TEMP\osdcloud-logs, attempts to
copy logs to an available OSDCloudLogs path, and populates
$global:OSDCoreDevice with an ordered property set used by downstream OSDCloud
deployment logic.

## EXAMPLES

### EXAMPLE 1
```
Initialize-OSDCoreDevice
```

Collects current device metadata, creates or updates
$global:OSDCoreDevice, and writes log artifacts for troubleshooting.

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

### None. This function does not emit pipeline output.
## NOTES
Side effects:
- Clears the current PowerShell error collection.
- Updates date/time in WinPE when needed.
- Writes logs to $env:TEMP\osdcloud-logs.
- Sets $global:OSDCoreDevice.

## RELATED LINKS
