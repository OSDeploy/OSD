---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdeploy.com/
schema: 2.0.0
---

# Show-RegistryXML

## SYNOPSIS
Displays registry entries from all RegistryXML files in the Source Directory

## SYNTAX

```
Show-RegistryXML [-SourceDirectory] <String> [<CommonParameters>]
```

## DESCRIPTION
Displays registry entries from all RegistryXML files in the Source Directory

## EXAMPLES

### EXAMPLE 1
```
Show-RegistryXML -SourceDirectory C:\DeploymentShare\OSDeploy\OSConfig\LocalPolicy\ImportGPO
```

Displays all RegistryXML entries found in Source Directory

## PARAMETERS

### -SourceDirectory
Directory to search for XML files

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

## NOTES
NAME:	Show-RegistryXML.ps1
AUTHOR:	David Segura, david@segura.org
BLOG:	http://www.osdeploy.com
VERSION:	18.9.4

## RELATED LINKS

[https://www.osdeploy.com/](https://www.osdeploy.com/)

