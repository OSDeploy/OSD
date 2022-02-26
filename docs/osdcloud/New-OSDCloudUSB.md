---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osdcloud.osdeploy.com
schema: 2.0.0
---

# New-OSDCloudUSB

## SYNOPSIS
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

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
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudUSB -WorkspacePath C:\OSDCloud
```

## PARAMETERS

### -WorkspacePath
Path to the OSDCloud Workspace containing the Media directory

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
{{ Fill fromIsoFile Description }}

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
{{ Fill fromIsoUrl Description }}

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

## RELATED LINKS

[https://osdcloud.osdeploy.com](https://osdcloud.osdeploy.com)

