---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-DellSystemCatalog

## SYNOPSIS
Builds the Dell System Catalog

## SYNTAX

```
Get-DellSystemCatalog [-Compatible] [[-Component] <String>] [[-DownloadPath] <String>] [-Online]
 [-UpdateModuleCatalog] [<CommonParameters>]
```

## DESCRIPTION
Builds the Dell System Catalog

## EXAMPLES

### EXAMPLE 1
```
Get-DellSystemCatalog
```

Don't do this, you will get an almost endless list

### EXAMPLE 2
```
$Result = Get-DellSystemCatalog
```

Yes do this. 
Save it in a Variable

### EXAMPLE 3
```
Get-DellSystemCatalog -Component BIOS | Out-GridView
```

Displays all the Dell BIOS Updates in GridView

## PARAMETERS

### -Compatible
Limits the results to match the current system

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

### -Component
Limits the results to a specified component

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DownloadPath
Specifies a download path for matching results displayed in Out-GridView

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

