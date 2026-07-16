---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-HPTPMEXEInstall

## SYNOPSIS
Extracts and installs the HP TPM firmware update from C:\OSDCloud\HP\TPM.

## SYNTAX

```
Invoke-HPTPMEXEInstall [[-path] <Object>] [[-filename] <Object>] [[-spec] <Object>] [[-logsuffix] <Object>]
 [[-WorkingFolder] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Locates the firmware EXE in C:\OSDCloud\HP\TPM, silently extracts it, then runs
TPMConfig64.exe with the specified arguments to apply the TPM firmware update.
Logs activity to C:\OSDCloud\Logs\TPMConfig.log.
Outputs the exit code from
TPMConfig64 along with a human-readable description for all documented exit codes.

## EXAMPLES

### EXAMPLE 1
```
Invoke-HPTPMEXEInstall
```

Installs the TPM firmware using default TPMConfig64 arguments.

### EXAMPLE 2
```
Invoke-HPTPMEXEInstall -spec '1.2'
```

Installs the TPM firmware targeting the 1.2 specification.

## PARAMETERS

### -path
Reserved parameter.
Not currently used.

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

### -filename
Optional firmware binary filename passed to TPMConfig64 via the -f argument.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -spec
Optional TPM specification version to target (e.g., '1.2' or '2.0').
Passed to TPMConfig64 via the -a argument.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -logsuffix
Reserved parameter.
Not currently used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkingFolder
Reserved parameter.
Not currently used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Run Invoke-HPTPMEXEDownload first to stage the firmware file.
Must be run with administrator privileges.
Exit code 3010 indicates success with a required reboot.

## RELATED LINKS
