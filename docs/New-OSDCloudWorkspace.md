---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudWorkspace

## SYNOPSIS
Creates resources by using New-OSDCloudWorkspace.

## SYNTAX

### fromTemplate (Default)
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [-Public] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### fromUsbDrive
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [-fromUsbDrive] [-Public]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### fromIsoUrl
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoUrl <String> [-Public]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### fromIsoFile
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoFile <FileInfo> [-Public]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for New-OSDCloudWorkspace.

## EXAMPLES

### EXAMPLE 1
```
-fromIsoFile <fromIsoFile>
Runs New-OSDCloudWorkspace with common parameters.
```

## PARAMETERS

### -WorkspacePath
Specifies the value for WorkspacePath.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$env:SystemDrive\OSDCloud"
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -fromIsoFile
Specifies the value for fromIsoFile.

```yaml
Type: FileInfo
Parameter Sets: fromIsoFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -fromIsoUrl
Specifies the value for fromIsoUrl.

```yaml
Type: String
Parameter Sets: fromIsoUrl
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -fromUsbDrive
Indicates whether to enable fromUsbDrive.

```yaml
Type: SwitchParameter
Parameter Sets: fromUsbDrive
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Public
Indicates whether to enable Public.

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
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

