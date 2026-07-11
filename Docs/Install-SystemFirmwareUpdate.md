---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Install-SystemFirmwareUpdate

## SYNOPSIS
Downloads and installs the latest system firmware update from Microsoft Update Catalog.

## SYNTAX

```
Install-SystemFirmwareUpdate [[-DestinationDirectory] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Finds the latest firmware update for the current system firmware HardwareID, downloads and extracts the package to a destination directory, and installs matching INF drivers.

This function requires elevation and PowerShell 5.1. In WinPE (`X:` system drive), it stages drivers by using `Add-WindowsDriver`. In a full Windows OS, it installs drivers with `pnputil`.

Supports `-WhatIf` and `-Confirm`.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-SystemFirmwareUpdate
```

Downloads, extracts, and installs the latest available firmware update using the default destination directory.

### Example 2
```powershell
PS C:\> Install-SystemFirmwareUpdate -DestinationDirectory 'D:\Updates\Firmware'
```

Downloads and installs the latest available firmware update using a custom destination directory.

### Example 3
```powershell
PS C:\> Install-SystemFirmwareUpdate -WhatIf
```

Shows what the function would do without downloading or installing any drivers.

## PARAMETERS

### -DestinationDirectory
Directory used to save and extract the firmware update package before installation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: C:\Drivers\SystemFirmwareUpdate
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how progress is displayed.

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

### None

## OUTPUTS

### None
## NOTES
Author: David Segura - Recast Software

Requires administrative privileges and internet access to Microsoft Update Catalog.

## RELATED LINKS
[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)
