---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Update-MyDellBios

## SYNOPSIS
Downloads and installed a compatible BIOS Update for your Dell system

## SYNTAX

```
Update-MyDellBios [[-DownloadPath] <String>] [-Force] [-Reboot] [-Silent] [<CommonParameters>]
```

## DESCRIPTION
Downloads and installed a compatible BIOS Update for your Dell system
BitLocker friendly, but you need Admin Rights
Logs to $env:TEMP\Update-MyDellBios.log

## EXAMPLES

### EXAMPLE 1
```
Update-MyDellBios
```

Downloads and launches the Dell BIOS Update. 
Does not automatically install the BIOS Update

### EXAMPLE 2
```
Update-MyDellBios -Silent
```

Yes, this will update your BIOS silently, and NOT reboot when its done

### EXAMPLE 3
```
Update-MyDellBios -Silent -Reboot
```

Yes, this will update your BIOS silently, AND reboot when its done

## PARAMETERS

### -DownloadPath
{{ Fill DownloadPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: DownloadFolder, Path

Required: False
Position: 1
Default value: $env:TEMP
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
{{ Fill Force Description }}

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

### -Reboot
{{ Fill Reboot Description }}

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

### -Silent
{{ Fill Silent Description }}

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
21.3.9  Started adding logic for WinPE
21.3.5  Resolved issue with multiple objects
21.3.4  Initial Release

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

