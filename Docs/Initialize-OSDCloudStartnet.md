---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Initialize-OSDCloudStartnet

## SYNOPSIS
Initializes the OSDCloud startnet environment.

## SYNTAX

```
Initialize-OSDCloudStartnet [-WirelessConnect] [<CommonParameters>]
```

## DESCRIPTION
This function initializes the OSDCloud startnet environment by performing the following tasks:
- Creates a log path if it does not already exist.
- Copies OSDCloud config startup scripts to the mounted WinPE.
- Initializes a splash screen if a SPLASH.JSON file is found in OSDCloud\Config.
- Initializes hardware devices.
- Initializes wireless network (optional).
- Initializes network connections.
- Updates PowerShell modules.

## EXAMPLES

### EXAMPLE 1
```
Initialize-OSDCloudStartnet -WirelessConnect
```

Initializes the OSDCloud startnet environment and attempts to connect to a wireless network.

## PARAMETERS

### -WirelessConnect
Specifies whether to connect to a wireless network.
If this switch is specified, the function will attempt to connect to a wireless network using the Start-WinREWiFi function.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
