---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# New-OSDCloudUSB

## SYNOPSIS
Creates resources by using New-OSDCloudUSB.

## SYNTAX

### Workspace (Default)
```
New-OSDCloudUSB [-WorkspacePath <String>] [<CommonParameters>]
```

### fromIsoFile
```
New-OSDCloudUSB -fromIsoFile <FileInfo> [<CommonParameters>]
```

### fromIsoUrl
```
New-OSDCloudUSB -fromIsoUrl <String> [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for New-OSDCloudUSB.

## EXAMPLES

### EXAMPLE 1
```
-fromIsoFile <fromIsoFile>
```

Runs New-OSDCloudUSB with common parameters.

## PARAMETERS

### -WorkspacePath
Specifies the value for WorkspacePath.

```yaml
Type: String
Parameter Sets: Workspace
Aliases:

Required: False
Position: Named
Default value: None
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

