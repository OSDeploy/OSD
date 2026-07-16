---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Install-ModuleHPCMSL

## SYNOPSIS
Installs or updates the HP Client Management Script Library (HPCMSL) PowerShell module.

## SYNTAX

```
Install-ModuleHPCMSL [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Ensures the HPCMSL module (version 1.8.5) is installed and up to date from the PowerShell Gallery.
If PowerShellGet 2.2.5 or later is not present, it is installed first.
Compares the installed HPCMSL version against the Gallery version and installs if missing or outdated.
Supports both WinPE and full Windows environments.
After installation, the module is imported into the global scope.

## EXAMPLES

### EXAMPLE 1
```
Install-ModuleHPCMSL
Installs or updates HPCMSL 1.8.5 for all users and imports it into the current session.
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
Requires internet access to reach the PowerShell Gallery.
Must be run with administrator privileges.
Uses the $WindowsPhase variable to detect WinPE vs.
full OS context.

## RELATED LINKS
