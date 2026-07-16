---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Copy-PSModuleToWindowsImage

## SYNOPSIS
Copies PowerShell modules to a mounted Windows image

## SYNTAX

```
Copy-PSModuleToWindowsImage [-Name] <String[]> [-ExecutionPolicy <String>] [-Path <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Copies specified PowerShell modules from the running operating system to a mounted Windows image for offline servicing.

## EXAMPLES

### EXAMPLE 1
```
Copy-PSModuleToWindowsImage -Name 'OSD' -Path 'C:\Mount'
```

Copies the OSD module to the mounted image at C:\\\\Mount

### EXAMPLE 2
```
Copy-PSModuleToWindowsImage -Name 'OSD','ActiveDirectory' -ExecutionPolicy Bypass -Path 'C:\Mount'
```

Copies multiple modules and sets execution policy

## PARAMETERS

### -Name
Name of the PowerShell module(s) to copy.
Wildcard patterns are supported.
This parameter is mandatory.

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

### -ExecutionPolicy
Sets the PowerShell Execution Policy in the Windows image.
Valid values are Restricted, AllSigned, RemoteSigned, Unrestricted, Bypass, and Undefined.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Path to the mounted Windows image.
If not specified, will use the currently mounted image.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

