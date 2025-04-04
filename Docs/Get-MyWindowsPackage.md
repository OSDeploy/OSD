---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-MyWindowsPackage

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Online (Default)
```
Get-MyWindowsPackage [-PackageState <String>] [-ReleaseType <String>] [-Category <String>]
 [-Culture <String[]>] [-Like <String[]>] [-Match <String[]>] [-Detail] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Offline
```
Get-MyWindowsPackage -Path <String> [-PackageState <String>] [-ReleaseType <String>] [-Category <String>]
 [-Culture <String[]>] [-Like <String[]>] [-Match <String[]>] [-Detail] [-ProgressAction <ActionPreference>]
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

### -Category
{{ Fill Category Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: FOD, Language, LanguagePack, Update, Other

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Culture
{{ Fill Culture Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detail
{{ Fill Detail Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Like
{{ Fill Like Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Match
{{ Fill Match Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PackageState
{{ Fill PackageState Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Installed, Superseded

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ReleaseType
{{ Fill ReleaseType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: FeaturePack, Foundation, LanguagePack, OnDemandPack, SecurityUpdate, Update

Required: False
Position: Named
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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
