---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Invoke-HPIA

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Invoke-HPIA [[-Operation] <Object>] [[-Category] <Object>] [[-Selection] <Object>] [[-Action] <Object>]
 [[-LogFolder] <Object>] [[-ReportsFolder] <Object>] [[-HPIAInstallPath] <Object>] [[-ReferenceFile] <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Action
{{ Fill Action Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: List, Download, Extract, Install, UpdateCVA

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
{{ Fill Category Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: All, BIOS, Drivers, Software, Firmware, Accessories, BIOS,Drivers

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HPIAInstallPath
{{ Fill HPIAInstallPath Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFolder
{{ Fill LogFolder Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Operation
{{ Fill Operation Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: Analyze, DownloadSoftPaqs

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReferenceFile
{{ Fill ReferenceFile Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportsFolder
{{ Fill ReportsFolder Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Selection
{{ Fill Selection Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: All, Critical, Recommended, Routine

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
