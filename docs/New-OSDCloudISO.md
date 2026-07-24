---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudISO

## SYNOPSIS
Creates an OSDCloud bootable ISO from an OSDCloud workspace.

## SYNTAX

```
New-OSDCloudISO [[-WorkspacePath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Validates the local environment and generates an ISO from the workspace
Media directory by calling New-WindowsAdkISO.
If an OSDeploy marker file
exists, the function creates an OSDeploy-labeled ISO for compatibility.

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudISO -WorkspacePath 'C:\OSDCloud'
Creates OSDCloud.iso from C:\OSDCloud\Media.
```

## PARAMETERS

### -WorkspacePath
Path to an OSDCloud workspace that contains Media\sources\boot.wim.
If omitted, the current workspace returned by Get-OSDCloudWorkspace is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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
2026-07-16 - Improved validation, path handling, and error flow

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

