---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/mybitlocker/save-mybitlockerkeypackage
schema: 2.0.0
---

# Save-MyBitLockerKeyPackage

## SYNOPSIS
Saves all BitLocker KeyPackages (KPG)

## SYNTAX

```
Save-MyBitLockerKeyPackage [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Saves all BitLocker KeyPackages (KPG) to a Directory (Path).
The key package can be used in conjunction with the repair tool to repair corrupted drives.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Directory to save the BitLocker Keys. 
This directory will be created if it does not exist

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
21.2.10  Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/mybitlocker/save-mybitlockerkeypackage](https://osd.osdeploy.com/module/functions/mybitlocker/save-mybitlockerkeypackage)

[https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde-keypackage](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde-keypackage)

