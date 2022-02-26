---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletofolder
schema: 2.0.0
---

# Copy-PSModuleToFolder

## SYNOPSIS
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

## SYNTAX

```
Copy-PSModuleToFolder [-Name] <String[]> [-Destination] <String> [-RemoveOldVersions] [<CommonParameters>]
```

## DESCRIPTION
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
Name of the PowerShell Module to Copy

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
Destination PSModule directory
Copied Module is a Child of Destination

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
Removes older Module Versions from the Destination

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
21.1.30.1   Initial Release
21.1.30.2   Added WinPE Parameter
21.1.30.3   Renamed PSModulePath Parameter to Destination, Added RemoveOldVersions
21.1.31.1   Removed WinPE Parameter
21.2.2.1	Renamed to Copy-ModuleToFolder so I don't mess with PowerShellGet
21.2.9.1	Renamed to Copy-PSModuleToFolder to standardize

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletofolder](https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletofolder)

