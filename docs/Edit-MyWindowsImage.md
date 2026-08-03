---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Edit-MyWindowsImage

## SYNOPSIS
Edits MyWindowsImage content.

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
Applies modifications to MyWindowsImage in the current servicing workflow.

## EXAMPLES

### EXAMPLE 1
```
Demonstrates a common way to run Edit-MyWindowsImage.
```

## PARAMETERS

### -Path
Specifies the Path to use when running Edit-MyWindowsImage.

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
Specifies the CleanupImage to use when running Edit-MyWindowsImage.

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
Specifies the Online to use when running Edit-MyWindowsImage.

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
Specifies the GridRemoveAppx to use when running Edit-MyWindowsImage.

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
Specifies the GridRemoveAppxPP to use when running Edit-MyWindowsImage.

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
Specifies the RemoveAppx to use when running Edit-MyWindowsImage.

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
Specifies the RemoveAppxPP to use when running Edit-MyWindowsImage.

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
Specifies the DismountSave to use when running Edit-MyWindowsImage.

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
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

