---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-HPTPMDetermine

## SYNOPSIS
Determines which HP TPM firmware update package is required for the current device.

## SYNTAX

```
Get-HPTPMDetermine [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the TPM via WMI (win32_tpm) to identify the manufacturer and firmware version.
For Infineon (IFX) TPMs, compares the firmware version against known vulnerable version
ranges and returns the appropriate HP softpaq package ID.
Returns 'SP87753' for firmware requiring an older update package, 'SP94937' for firmware
requiring the newer package, or $false if no update is needed or the TPM is not Infineon.

## EXAMPLES

### EXAMPLE 1
```
$Package = Get-HPTPMDetermine
Returns 'SP87753', 'SP94937', or $false.
```

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

### System.String
### Returns 'SP87753', 'SP94937', or $false.
## NOTES
Requires access to the root\cimv2\security\MicrosoftTPM WMI namespace.
Must be run with administrator privileges.

## RELATED LINKS
