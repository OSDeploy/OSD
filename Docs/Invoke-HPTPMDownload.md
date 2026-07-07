---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Invoke-HPTPMDownload

## SYNOPSIS
Downloads and extracts the required HP TPM firmware update softpaq using HPCMSL.

## SYNTAX

```
Invoke-HPTPMDownload [[-WorkingFolder] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Calls Get-HPTPMDetermine to identify the required softpaq, then uses the HPCMSL
Get-Softpaq cmdlet to download it to the specified working folder.
The downloaded
EXE is silently extracted to a subfolder.
Returns the path to the extracted folder.
Intended for manual download and testing scenarios.

## EXAMPLES

### EXAMPLE 1
```
Invoke-HPTPMDownload
Downloads and extracts the required TPM firmware softpaq to $env:TEMP\TPM.
```

### EXAMPLE 2
```
Invoke-HPTPMDownload -WorkingFolder 'C:\Temp\TPMWork'
Downloads and extracts the required TPM firmware softpaq to C:\Temp\TPMWork.
```

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
### Returns the path to the extracted firmware folder.
## NOTES
Requires internet access and the HPCMSL PowerShell module.
Must be run with administrator privileges.

## RELATED LINKS
