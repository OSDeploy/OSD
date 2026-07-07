---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Invoke-HPTPMEXEDownload

## SYNOPSIS
Downloads the required HP TPM firmware EXE to C:\OSDCloud\HP\TPM.

## SYNTAX

```
Invoke-HPTPMEXEDownload [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Calls Get-HPTPMDetermine to identify the required softpaq, then downloads the firmware
EXE to C:\OSDCloud\HP\TPM.
If the file is already present on a connected OSDCloud USB
drive it is copied locally instead of being downloaded from the internet.
The destination
folder is cleared before each run.
Also disables Virtualization Technology (VTx) in the
BIOS via Set-HPBIOSSetting.

## EXAMPLES

### EXAMPLE 1
```
Invoke-HPTPMEXEDownload
Determines the required TPM softpaq and downloads (or copies) it to C:\OSDCloud\HP\TPM.
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

## NOTES
Requires HPCMSL if the firmware file is not already available on an OSDCloud USB drive.
Must be run with administrator privileges.

## RELATED LINKS
