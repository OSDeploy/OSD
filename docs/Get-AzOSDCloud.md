---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-AzOSDCloud

## SYNOPSIS
Initialize the local OSDCloud Azure workspace.

## SYNTAX

```
Get-AzOSDCloud [-edit] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates the local OSDCloud folder structure under C:\OSDCloud, copies the repository's Bicep
and Terraform templates into place, and optionally opens the workspace in Visual Studio Code.

## EXAMPLES

### EXAMPLE 1
```
Get-AzOSDCloud
Creates the local workspace and copies the Azure IaC templates.
```

### EXAMPLE 2
```
Get-AzOSDCloud -edit
Creates the local workspace and opens it in Visual Studio Code.
```

## PARAMETERS

### -edit
Open the C:\OSDCloud workspace in Visual Studio Code after the files are copied.

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
2026-07-10 - Updated help to repo standard

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://github.com/OSDeploy/OSD/blob/master/docs/Get-AzOSDCloud.md](https://github.com/OSDeploy/OSD/blob/master/docs/Get-AzOSDCloud.md)

