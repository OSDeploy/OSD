---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Install-AzOSDIacTools

## SYNOPSIS
Install prerequisite IaC tooling for OSDCloud Azure.

## SYNTAX

```
Install-AzOSDIacTools [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Detects Terraform, Bicep, and Azure CLI, installs missing components, updates the current
user's PATH, and verifies the OSD PowerShell modules needed by the Azure IaC workflow.

## EXAMPLES

### EXAMPLE 1
```
Install-AzOSDIacTools
Installs any missing tooling and validates the OSD modules.
```

## PARAMETERS

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
