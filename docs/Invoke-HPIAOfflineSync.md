---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-HPIAOfflineSync

## SYNOPSIS
Creates and synchronizes an offline HPIA repository for the local HP platform.

## SYNTAX

```
Invoke-HPIAOfflineSync [[-Category] <Object>] [[-OS] <Object>] [[-Release] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Builds a local repository using HPCMSL commands, applies platform and OS
filters, and downloads selected update content for offline use.
Logs are
written to C:\OSDCloud\Logs\HPIAOfflineSync.log.

## EXAMPLES

### EXAMPLE 1
```
Invoke-HPIAOfflineSync
Creates an offline repository for the local platform using default Driver, win11, and 23H2 filters.
```

### EXAMPLE 2
```
Invoke-HPIAOfflineSync -Category BIOS -OS win10 -Release 22H2
Creates an offline repository filtered to Windows 10 22H2 BIOS content.
```

## PARAMETERS

### -Category
Update category filter for repository content.
Valid values are All, BIOS,
Driver, Software, Firmware, and UWPPack.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Driver
Accept pipeline input: False
Accept wildcard characters: False
```

### -OS
Operating system filter passed to Add-RepositoryFilter, such as win11.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Win11
Accept pipeline input: False
Accept wildcard characters: False
```

### -Release
Operating system release filter passed to Add-RepositoryFilter, such as 23H2.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 23H2
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

## NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
