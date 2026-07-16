---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDCloudAzure

## SYNOPSIS
Start an OSDCloud deployment from Azure Storage.

## SYNTAX

```
Start-OSDCloudAzure [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Runs from WinPE, installs the OSDCloudAzure dependencies, connects to Azure, discovers
available OSDCloud resources, and starts the deployment workflow when an image is available.

## EXAMPLES

### EXAMPLE 1
```
Start-OSDCloudAzure
Starts an Azure-backed OSDCloud deployment using the current selection.
```

### EXAMPLE 2
```
Start-OSDCloudAzure -Force
Resets the current Azure image selection and restarts the deployment flow.
```

## PARAMETERS

### -Force
Reset OSDCloudAzure state before continuing.

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

[https://github.com/OSDeploy/OSD/blob/master/Docs/Start-OSDCloudAzure.md](https://github.com/OSDeploy/OSD/blob/master/Docs/Start-OSDCloudAzure.md)
