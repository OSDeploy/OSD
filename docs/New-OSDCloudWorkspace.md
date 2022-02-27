---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osdcloud.osdeploy.com
schema: 2.0.0
---

# New-OSDCloudWorkspace

## SYNOPSIS
Creates or updates an OSDCloud Workspace

## SYNTAX

### fromTemplate (Default)
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [<CommonParameters>]
```

### fromUsbDrive
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] [-fromUsbDrive] [<CommonParameters>]
```

### fromIsoUrl
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoUrl <String> [<CommonParameters>]
```

### fromIsoFile
```
New-OSDCloudWorkspace [[-WorkspacePath] <String>] -fromIsoFile <FileInfo> [<CommonParameters>]
```

## DESCRIPTION
Creates or updates an OSDCloud Workspace from an OSDCloud Template

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

### -fromUsbDrive
{{ Fill fromUsbDrive Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://osdcloud.osdeploy.com](https://osdcloud.osdeploy.com)

