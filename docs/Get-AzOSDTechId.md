---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-AzOSDTechId

## SYNOPSIS
Find Azure AD users for an OSD tech identifier prefix.

## SYNTAX

```
Get-AzOSDTechId [-AzureAdUserName] <String> [<CommonParameters>]
```

## DESCRIPTION
Connects to Azure with device authentication, selects a subscription when multiple subscriptions
are available, and returns Azure AD users whose name starts with the supplied value.

## EXAMPLES

### EXAMPLE 1
```
Get-AzOSDTechId -AzureAdUserName alex
```

Finds Azure AD users whose names start with alex.

## PARAMETERS

### -AzureAdUserName
Prefix to search for in Azure AD user names.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: David Segura - Recast Software
2026-07-10 - Updated help to repo standard

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://github.com/OSDeploy/OSD/blob/master/docs/Get-AzOSDTechId.md](https://github.com/OSDeploy/OSD/blob/master/docs/Get-AzOSDTechId.md)

