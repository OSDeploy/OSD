---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com
schema: 2.0.0
---

# Update-OSDCloudUSB

## SYNOPSIS
Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

## SYNTAX

```
Update-OSDCloudUSB [[-DriverPack] <String[]>] [-PSUpdate] [-OS] [[-OSName] <String>] [[-OSLanguage] <String>]
 [[-OSLicense] <String>] [<CommonParameters>]
```

## DESCRIPTION
Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DriverPack
Optional.
Select one or more of the following Driver Packs to download
'*','ThisPC','Dell','HP','Lenovo','Microsoft'

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

### -PSUpdate
{{ Fill PSUpdate Description }}

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

### -OS
{{ Fill OS Description }}

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

### -OSName
Optional.
Selects an Operating System to download
If this parameter is not used, any Operating Systems can be downloaded
'Windows 11 21H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004','Windows 10 1909','Windows 10 1903','Windows 10 1809'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLanguage
Optional.
Allows the selection of Driver Packs to download
If this parameter is not used, any language can be downloaded downloaded

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSLicense
Optional.
Selects the proper OS License
If this parameter is not used, Operating Systems with either license can be downloaded
'Retail','Volume'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://www.osdcloud.com](https://www.osdcloud.com)

