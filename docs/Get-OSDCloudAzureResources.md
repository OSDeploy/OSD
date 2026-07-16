---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-OSDCloudAzureResources

## SYNOPSIS
Discover OSDCloud Azure Storage resources.

## SYNTAX

```
Get-OSDCloudAzureResources [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses the current Azure context to enumerate storage accounts tagged OSDCloud, caches the
matching containers and blob collections in global variables, and writes discovered resource
snapshots to the WinPE log folder when available.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDCloudAzureResources
Scans Azure storage for tagged OSDCloud resources.
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
