---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-HPTPMDowngrade

## SYNOPSIS
Downloads and applies the HP SP94937 softpaq to downgrade a TPM from 2.0 to 1.2.

## SYNTAX

```
Invoke-HPTPMDowngrade [[-WorkingFolder] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Downloads softpaq SP94937 using HPCMSL, extracts it, and runs TPMConfig64.exe with
the '-a 1.2' argument to downgrade an Infineon TPM from firmware version 2.0 to 1.2.
Disables Virtualization Technology (VTx) in the BIOS via Set-HPBIOSSetting before
applying the firmware change.

## EXAMPLES

### EXAMPLE 1
```
Invoke-HPTPMDowngrade
```

Downloads SP94937 to $env:TEMP\TPM and downgrades the Infineon TPM to spec 1.2.

## PARAMETERS

### -WorkingFolder
The folder path where the softpaq EXE will be downloaded and extracted.
Defaults to $env:TEMP\TPM if not specified.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Requires HPCMSL and the HP BIOS WMI interface (Set-HPBIOSSetting).
Must be run with administrator privileges.
A system reboot is typically required after the firmware change takes effect.

## RELATED LINKS
