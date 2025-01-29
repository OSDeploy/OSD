---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/
schema: 2.0.0
---

# Get-WinPEDrivers

## SYNOPSIS
Gets the WinPEDrivers in the OSDCache at $env:ProgramData\OSDCache.

## SYNTAX

```
Get-WinPEDrivers [[-Architecture] <String[]>] [-BootImage <String>] [-GridView] [<CommonParameters>]
```

## DESCRIPTION
Gets the WinPEDrivers in the OSDCache at $env:ProgramData\OSDCache.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Architecture
Filters the drivers by architecture (amd64, arm64)

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

### -BootImage
Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GridView
Displays the drivers in a GridView for selection with PassThru

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
David Segura

## RELATED LINKS
