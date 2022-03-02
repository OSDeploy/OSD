---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Set-OSDCloudREBootmgr

## SYNOPSIS
OSDCloudRE: Configures OSDCloudRE Boot Manager options

## SYNTAX

```
Set-OSDCloudREBootmgr [-OSMenuAdd] [-OSMenuRemove] [-BootToOSDCloudRE] [<CommonParameters>]
```

## DESCRIPTION
OSDCloudRE: Configures OSDCloudRE Boot Manager options.
Requires ADMIN righs

## EXAMPLES

### EXAMPLE 1
```
Set-OSDCloudREBootmgr -OSMenuAdd
```

Adds OSDCloudRE to the Boot Manager Operating System selection

### EXAMPLE 2
```
Set-OSDCloudREBootmgr -OSMenuRemove
```

Removes OSDCloudRE from the Boot Manager Operating System selection

### EXAMPLE 3
```
Set-OSDCloudREBootmgr -BootToOSDCloudRE
```

Boots to OSDCloudRE on the next reboot

## PARAMETERS

### -OSMenuAdd
Adds OSDCloudRE to the Boot Manager Operating System selection

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

### -OSMenuRemove
Removes OSDCloudRE from the Boot Manager Operating System selection

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

### -BootToOSDCloudRE
Boots to OSDCloudRE on the next reboot

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

### System.Void
## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

