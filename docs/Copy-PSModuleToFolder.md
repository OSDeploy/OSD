---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Copy-PSModuleToFolder

## SYNOPSIS
Copies PowerShell modules to a destination module path.

## SYNTAX

```
Copy-PSModuleToFolder [-Name] <String[]> [-Destination] <String> [-RemoveOldVersions] [<CommonParameters>]
```

## DESCRIPTION
Finds the latest installed version of each requested module and copies it to
the destination using the standard module\version folder layout.

## EXAMPLES

### EXAMPLE 1
```
Copy-PSModuleToFolder -Name OSD -Destination 'C:\Modules'
```

Copies the latest installed OSD module to C:\Modules\OSD\\\<version\>.

### EXAMPLE 2
```
Copy-PSModuleToFolder -Name OSD,PackageManagement -Destination 'C:\Modules' -RemoveOldVersions
```

Removes existing destination module content and copies fresh module versions.

## PARAMETERS

### -Name
One or more module names to copy.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Destination
Destination root folder for copied modules.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Folder

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RemoveOldVersions
Removes existing module content from the destination before copying.

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
Author: David Segura - Recast Software
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

