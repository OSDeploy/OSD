---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Update-OSDCloudUSB

## SYNOPSIS
Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

## SYNTAX

```
Update-OSDCloudUSB [[-DriverPack] <String[]>] [-PSUpdate] [-OS] [[-OSLanguage] <String>]
 [[-OSActivation] <String>] [[-OSName] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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
Updates the required OSDCloud PowerShell Modules

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
Optional.
Allows the selection of an Operating System to add to the USB

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

### -OSLanguage
Optional.
Allows the selection of Driver Packs to download. 
If this parameter is not used, any language can be downloaded downloaded

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

### -OSActivation
Optional.
Selects the proper OS License.
If this parameter is not used, Operating Systems with the specified License can be downloaded

```yaml
Type: String
Parameter Sets: (All)
Aliases: Activation, License, OSLicense

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSName
Optional.
Selects an Operating System to download
If this parameter is not used, any Operating Systems can be downloaded
'Windows 11 22H2','Windows 11 21H2','Windows 10 22H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004','Windows 10 1909','Windows 10 1903','Windows 10 1809'

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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
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

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

