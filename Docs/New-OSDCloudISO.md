---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com/setup/osdcloud-iso
schema: 2.0.0
---

# New-OSDCloudISO

## SYNOPSIS
Creates an .iso file in the OSDCloud Workspace. 
ADK is required

## SYNTAX

```
New-OSDCloudISO [[-WorkspacePath] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates an .iso file in the OSDCloud Workspace. 
ADK is required

## EXAMPLES

### EXAMPLE 1
```
New-OSDCloudISO
```

### EXAMPLE 2
```
New-OSDCloudISO -WorkspacePath C:\OSDCloud
```

## PARAMETERS

### -WorkspacePath
Path to the OSDCloud Workspace containing the Media directory
This parameter is not necessary if Get-OSDCloudWorkspace can get a return

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

## RELATED LINKS

[https://www.osdcloud.com/setup/osdcloud-iso](https://www.osdcloud.com/setup/osdcloud-iso)

