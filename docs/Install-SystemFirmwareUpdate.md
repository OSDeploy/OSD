---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Install-SystemFirmwareUpdate

## SYNOPSIS
Downloads and installs the system firmware update

## SYNTAX

```
Install-SystemFirmwareUpdate [[-DestinationDirectory] <String>] [-Force] [-Restart] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Downloads the latest system firmware update from Microsoft Update Catalog and installs it on the running system.
Requires admin rights and PowerShell 5.1.

## EXAMPLES

### EXAMPLE 1
```
Install-SystemFirmwareUpdate
```

Downloads and installs the latest firmware update

### EXAMPLE 2
```
Install-SystemFirmwareUpdate -DestinationDirectory 'D:\Updates'
```

Downloads firmware update to D:\Updates and installs it

### EXAMPLE 3
```
Install-SystemFirmwareUpdate -Force -Restart
```

Downloads and installs the latest firmware update and restarts if required.

## PARAMETERS

### -DestinationDirectory
Directory where the firmware update will be downloaded.
Default is C:\Drivers\SystemFirmwareUpdate

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\Drivers\SystemFirmwareUpdate
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Required switch to perform the firmware update.
Without this switch, the function only warns and exits.

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

### -Restart
Restarts the computer automatically when a reboot is required after installation.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help
2026-07-11 - Refactored to use Save-SystemFirmwareUpdate and improved install error handling
2026-07-11 - Added BitLocker warning, Force gate, and optional restart handling

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

