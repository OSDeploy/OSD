---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Edit-MyWindowsImage

## SYNOPSIS
Edits a mounted Windows Image

## SYNTAX

### Offline (Default)
```
Edit-MyWindowsImage [-Path <String[]>] [-CleanupImage <String>] [-GridRemoveAppxPP] [-RemoveAppxPP <String[]>]
 [-DismountSave] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Online
```
Edit-MyWindowsImage [-Online] [-GridRemoveAppx] [-GridRemoveAppxPP] [-RemoveAppx <String[]>]
 [-RemoveAppxPP <String[]>] [-DismountSave] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Edits a mounted Windows Image

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service.
If the directory named Windows is not a subdirectory of the root directory, -WindowsDirectory must be specified.

```yaml
Type: String[]
Parameter Sets: Offline
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CleanupImage
Dism Actions
Analyze cannot be used for PassThru

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Specifies that the action is to be taken on the operating system that is currently running on the local computer.

```yaml
Type: SwitchParameter
Parameter Sets: Online
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GridRemoveAppx
Appx Packages selected in GridView will be removed from the Windows Image

```yaml
Type: SwitchParameter
Parameter Sets: Online
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

### -RemoveAppx
Appx Packages matching the string will be removed

```yaml
Type: String[]
Parameter Sets: Online
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveAppxPP
Appx Provisioned Packages matching the string will be removed

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

### -DismountSave
{{ Fill DismountSave Description }}

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
19.11.22 David Segura @SeguraOSD

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

