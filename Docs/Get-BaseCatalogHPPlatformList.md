---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com
schema: 2.0.0
---

# Get-BaseCatalogHPPlatformList

## SYNOPSIS
Converts the HP Platform list to a PowerShell Object.
Useful to get the computer model name for System Ids

## SYNTAX

```
Get-BaseCatalogHPPlatformList [<CommonParameters>]
```

## DESCRIPTION
Converts the HP Platform list to a PowerShell Object.
Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab

## EXAMPLES

### EXAMPLE 1
```
Get-BaseCatalogHPPlatformList
```

Don't do this, you will get a big list.

### EXAMPLE 2
```
$Results = Get-BaseCatalogHPPlatformList
```

Yes do this. 
Save it in a Variable

### EXAMPLE 3
```
Get-BaseCatalogHPPlatformList | Out-GridView
```

Displays all the HP System Ids with the applicable computer model names in GridView

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://osd.osdeploy.com](https://osd.osdeploy.com)

