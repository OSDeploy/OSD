---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-HPPlatformCatalog

## SYNOPSIS
Converts the HP Platform list to a PowerShell Object.
Useful to get the computer model name for System Ids

## SYNTAX

```
Get-HPPlatformCatalog [-Online] [-UpdateModuleCatalog] [<CommonParameters>]
```

## DESCRIPTION
Converts the HP Platform list to a PowerShell Object.
Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab

## EXAMPLES

### EXAMPLE 1
```
Get-HPPlatformCatalog
```

Don't do this, you will get a big list.

### EXAMPLE 2
```
$Results = Get-HPPlatformCatalog
```

Yes do this. 
Save it in a Variable

### EXAMPLE 3
```
Get-HPPlatformCatalog | Out-GridView
```

Displays all the HP System Ids with the applicable computer model names in GridView

## PARAMETERS

### -Online
Checks for the latest Online version

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

### -UpdateModuleCatalog
Updates the OSD Module Offline Catalog

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

## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

