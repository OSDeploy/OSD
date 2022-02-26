---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowindowsimage
schema: 2.0.0
---

# Copy-PSModuleToWindowsImage

## SYNOPSIS
Copies the latest installed named PowerShell Module to a mounted Windows Image

## SYNTAX

```
Copy-PSModuleToWindowsImage [-Name] <String[]> [-ExecutionPolicy <String>] [-Path <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Copies the latest installed named PowerShell Module to a mounted Windows Image

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
{{ Fill Name Description }}

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
Specifies the new execution policy.
The acceptable values for this parameter are:
- Restricted.
Does not load configuration files or run scripts.
Restricted is the default execution policy.
- AllSigned.
Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.
- RemoteSigned.
Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.
- Unrestricted.
Loads all configuration files and runs all scripts.
If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.
- Bypass.
Nothing is blocked and there are no warnings or prompts.
- Undefined.
Removes the currently assigned execution policy from the current scope.
This parameter will not remove an execution policy that is set in a Group Policy scope.

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
Specifies the full path to the root directory of the offline Windows image that you will service
If a Path is not specified, all mounted Windows Images will be modified

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
21.3.8  Resolved issue where Name parameter was missing
21.2.9  Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowindowsimage](https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowindowsimage)

