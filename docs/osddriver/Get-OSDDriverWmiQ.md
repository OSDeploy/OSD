---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/driver/get-osddriverwmiq
schema: 2.0.0
---

# Get-OSDDriverWmiQ

## SYNOPSIS
Returns a Computer Model WMI Query that can be used in Task Sequences

## SYNTAX

```
Get-OSDDriverWmiQ [[-InputObject] <Object[]>] [[-OSDGroup] <String>] [[-Result] <String>] [-ShowTextFile]
 [<CommonParameters>]
```

## DESCRIPTION
Returns a Computer Model WMI Query that can be used in Task Sequences

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -InputObject
{{ Fill InputObject Description }}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OSDGroup
Select a Computer Manufacturer OSDGroup
Default is DellModel

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Result
Select whether the Query is based off Model or SystemId SystemSku Product
Default is Model

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Model
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowTextFile
Open a Text File with the WMI Query after completion

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
19.12.6     David Segura @SeguraOSD

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/driver/get-osddriverwmiq](https://osd.osdeploy.com/module/functions/driver/get-osddriverwmiq)

