---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Connect-OSDCloudAzure

## SYNOPSIS
Connect to Azure and initialize OSDCloudAzure session state.

## SYNTAX

```
Connect-OSDCloudAzure [-UseDeviceAuthentication] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Installs the Azure and Microsoft Graph modules required by OSDCloudAzure, signs in to Azure,
optionally prompts for a subscription when multiple subscriptions are available, and populates
the global context, token, and header variables used by the Azure deployment workflow.

## EXAMPLES

### EXAMPLE 1
```
Connect-OSDCloudAzure
Signs in to Azure using the interactive browser-based authentication flow.
```

### EXAMPLE 2
```
Connect-OSDCloudAzure -UseDeviceAuthentication
Signs in to Azure by using device-code authentication.
```

## PARAMETERS

### -UseDeviceAuthentication
Use device-code authentication instead of the interactive Azure sign-in flow.

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

[https://github.com/OSDeploy/OSD/blob/master/Docs/Connect-OSDCloudAzure.md](https://github.com/OSDeploy/OSD/blob/master/Docs/Connect-OSDCloudAzure.md)
