---
external help file: OSD-help.xml
Module Name: OSD
online version:
schema: 2.0.0
---

# Enable-PEWimPSGallery

## SYNOPSIS
Mount a Windows Image (WIM), enable PowerShell Gallery, and Dismount Save

## SYNTAX

```
Enable-PEWimPSGallery [-ImagePath] <String[]> [[-Index] <UInt32>] [<CommonParameters>]
```

## DESCRIPTION
Mount a Windows Image (WIM), enable PowerShell Gallery, and Dismount Save

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ImagePath
Mandatory Path to the Windows Image (WIM)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Index
Index of the Windows Image (WIM) to mount. 
Default is 1 (Index 1)

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
