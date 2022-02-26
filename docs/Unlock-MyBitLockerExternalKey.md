---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/mybitlocker/unlock-mybitlockerexternalkey
schema: 2.0.0
---

# Unlock-MyBitLockerExternalKey

## SYNOPSIS
Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)

## SYNTAX

```
Unlock-MyBitLockerExternalKey [[-Path] <String[]>] [-Recurse] [<CommonParameters>]
```

## DESCRIPTION
Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Directory containing BitLocker ExternalKeys (BEK)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Recurse
Searches the Path for BitLocker ExternalKeys (BEK) in subdirectories

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/mybitlocker/unlock-mybitlockerexternalkey](https://osd.osdeploy.com/module/functions/mybitlocker/unlock-mybitlockerexternalkey)

