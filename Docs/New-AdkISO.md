---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# New-AdkISO

## SYNOPSIS
Creates an .iso file from a bootable media directory. 
ADK is required

## SYNTAX

```
New-AdkISO [[-WindowsAdkRoot] <String>] [-MediaPath] <String> [-isoFileName] <String> [-isoLabel] <String>
 [-OpenExplorer] [<CommonParameters>]
```

## DESCRIPTION
Creates a .iso file from a bootable media directory. 
ADK is required

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -WindowsAdkRoot
{{ Fill WindowsAdkRoot Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: AdkRoot

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath
Directory containing the bootable media

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoFileName
File Name of the ISO

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoLabel
Label of the ISO. 
Limited to 16 characters

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenExplorer
Opens Windows Explorer to the parent directory of the ISO File

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
21.3.16     Initial Release

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

