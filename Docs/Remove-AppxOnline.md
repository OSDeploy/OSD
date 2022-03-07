---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/appx/remove-appxonline
schema: 2.0.0
---

# Remove-AppxOnline

## SYNOPSIS
Removes Appx Packages and Appx Provisioned Packages for All Users

## SYNTAX

```
Remove-AppxOnline [-GridRemoveAppx] [-GridRemoveAppxPP] [[-Name] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Removes Appx Packages and Appx Provisioned Packages for All Users

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -GridRemoveAppx
Appx Packages selected in GridView will be removed from the Windows Image

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

### -GridRemoveAppxPP
Appx Provisioned Packages selected in GridView will be removed from the Windows Image

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

### -Name
Appx Packages matching the string will be removed

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
19.12.20 David Segura @SeguraOSD

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/appx/remove-appxonline](https://osd.osdeploy.com/module/functions/appx/remove-appxonline)

