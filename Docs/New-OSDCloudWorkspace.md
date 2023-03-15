---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-workspace
schema: 2.0.0
---

# New-OSDCloudWorkspace

## SYNOPSIS
Creates or updates an OSDCloud Workspace

## SYNTAX

### fromTemplate (Default)
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [-Public] [<CommonParameters>]
```

### fromUsbDrive
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [-fromUsbDrive] [-Public] [<CommonParameters>]
```

### fromIsoUrl
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoUrl <String> [-Public] [<CommonParameters>]
```

### fromIsoFile
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoFile <FileInfo> [-Public] [<CommonParameters>]
```

## DESCRIPTION
Creates or updates an OSDCloud Workspace

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -WorkspacePath
Directory for the OSDCloud Workspace to create or update. 
Default is $env:SystemDrive\OSDCloud

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
Path to an OSDCloud ISO
This file will be mounted and the contents will be copied to the OSDCloud Workspace

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
This file will be downloaded and mounted and the contents will be copied to the OSDCloud Workspace

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
Searches for an OSDCloud USB
The OSDCloud USB contents will be copied to the OSDCloud Workspace

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
Prevents the copying of Private Config files

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://www.osdcloud.com/setup/osdcloud-workspace](https://www.osdcloud.com/setup/osdcloud-workspace)

