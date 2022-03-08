---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-usb
schema: 2.0.0
---

# New-OSDCloudUSB

## SYNOPSIS
Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
Clear, Initialize, Partition (WinPE and OSDCloudUSB), and Format a USB Disk
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
Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudUSB -WorkspacePath C:\OSDCloud
```

### EXAMPLE 2
```
New-OSDCloudUSB -fromIsoFile D:\osdcloud.iso
```

### EXAMPLE 3
```
New-OSDCloudUSB -fromIsoUrl https://contoso.blob.core.windows.net/public/osdcloud.iso
```

## PARAMETERS

### -WorkspacePath
Path to the OSDCloud Workspace containing the Media directory
This parameter is not necessary if Get-OSDCloudWorkspace can get a return

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
Path to an OSDCloud ISO
This file will be mounted and the contents will be copied to the OSDCloud USB

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
Path to an OSDCloud ISO saved on the internet
This file will be downloaded and mounted and the contents will be copied to the OSDCloud USB

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

[https://www.osdcloud.com/setup/osdcloud-usb](https://www.osdcloud.com/setup/osdcloud-usb)

