---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-ReAgentXml

## SYNOPSIS
Returns information from the Windows Recovery Agent XML file

## SYNTAX

```
Get-ReAgentXml [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads and parses the Reagent.xml file to extract Windows Recovery Environment configuration and status information.
This function must be run in Windows.

## EXAMPLES

### EXAMPLE 1
```
Get-ReAgentXml
Returns ReAgent.xml configuration details
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
2026-07-10 - Updated help to follow OSD standard

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

