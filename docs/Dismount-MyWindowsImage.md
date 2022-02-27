---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/mywindowsimage
schema: 2.0.0
---

# Dismount-MyWindowsImage

## SYNOPSIS
Dismounts a Windows image from the directory it is mapped to.

## SYNTAX

### DismountDiscard (Default)
```
Dismount-MyWindowsImage [-Path <String[]>] [-Discard] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### DismountSave
```
Dismount-MyWindowsImage [-Path <String[]>] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Dismount-WindowsImage cmdlet either saves or discards the changes to a Windows image and then dismounts the image.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service.

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

### -Discard
Discards the changes to a Windows image.

```yaml
Type: SwitchParameter
Parameter Sets: DismountDiscard
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Save
Saves the changes to a Windows image.

```yaml
Type: SwitchParameter
Parameter Sets: DismountSave
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
### Microsoft.Dism.Commands.ImageObject
### Microsoft.Dism.Commands.MountedImageInfoObject
### Microsoft.Dism.Commands.ImageInfoObject
## OUTPUTS

### Microsoft.Dism.Commands.BaseDismObject
## NOTES
19.11.21    Initial Release
21.2.9      Renamed from Dismount-WindowsImageOSD

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/mywindowsimage](https://osd.osdeploy.com/module/functions/mywindowsimage)

