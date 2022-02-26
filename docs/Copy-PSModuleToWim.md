---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowim
schema: 2.0.0
---

# Copy-PSModuleToWim

## SYNOPSIS
Copies the latest installed named PowerShell Module to a Windows Image .wim file (Mount | Copy | Dismount -Save)

## SYNTAX

```
Copy-PSModuleToWim [[-ExecutionPolicy] <String>] [-ImagePath] <String[]> [[-Index] <UInt32>] [-Name] <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
Copies the latest installed named PowerShell Module to a Windows Image .wim file (Mount | Copy | Dismount -Save)

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ImagePath
Specifies the location of the WIM or VHD file containing the Windows image you want to mount.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Index
Index of the WIM to Mount
Default is 1

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Name of the PowerShell Module to Copy

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
21.2.9  Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowim](https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowim)

