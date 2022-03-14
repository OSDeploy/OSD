---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Show-MsSettings

## SYNOPSIS
Opens the ms-setting: URI that is specified in the Setting parameter

## SYNTAX

```
Show-MsSettings [[-Setting] <String>] [-DisableWSUS] [<CommonParameters>]
```

## DESCRIPTION
Opens the ms-setting: URI that is specified in the Setting parameter

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Setting
{{ Fill Setting Description }}

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

### -DisableWSUS
Sets the Group Policy 'Download repair content and optional features directly from Windows Update instead of Windows Server Update Services (WSUS)'
Restarts the Windows Update Service
This setting will be enabled after restart by Group Policy

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

