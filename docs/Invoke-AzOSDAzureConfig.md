---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-AzOSDAzureConfig

## SYNOPSIS
Deploy OSDCloud Azure infrastructure with Bicep or Terraform.

## SYNTAX

### Bicep
```
Invoke-AzOSDAzureConfig [-Location <Object>] [-ResourceGroupName <String>] [-AzOSDUserNameStart <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Terraform
```
Invoke-AzOSDAzureConfig [-UseTerraform <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Prepares the local OSDCloud workspace, installs the required IaC tools, authenticates to Azure
or the Azure CLI based on the selected parameter set, and deploys either the Bicep template or
the Terraform configuration in C:\OSDCloud.

## EXAMPLES

### EXAMPLE 1
```
Invoke-AzOSDAzureConfig -Location eastus -ResourceGroupName rg-osdcloud
Runs the Bicep deployment path for the selected Azure region and resource group.
```

### EXAMPLE 2
```
Invoke-AzOSDAzureConfig -UseTerraform $true
Runs the Terraform deployment path from C:\OSDCloud.
```

## PARAMETERS

### -Location
Azure region used by the Bicep deployment path.

```yaml
Type: Object
Parameter Sets: Bicep
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName
Name of the resource group created and deployed by the Bicep path.

```yaml
Type: String
Parameter Sets: Bicep
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AzOSDUserNameStart
Optional prefix passed through the Bicep parameter set for related OSDCloud Azure workflows.

```yaml
Type: String
Parameter Sets: Bicep
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseTerraform
Select the Terraform deployment path.

```yaml
Type: Boolean
Parameter Sets: Terraform
Aliases:

Required: False
Position: Named
Default value: True
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

[https://github.com/OSDeploy/OSD/blob/master/Docs/Invoke-AzOSDAzureConfig.md](https://github.com/OSDeploy/OSD/blob/master/Docs/Invoke-AzOSDAzureConfig.md)
