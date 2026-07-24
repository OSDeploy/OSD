---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Unlock-MyBitLockerExternalKey

## SYNOPSIS
Unlocks BitLocker volumes using external key files.

## SYNTAX

```
Unlock-MyBitLockerExternalKey [[-Path] <String[]>] [-Recurse] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Searches one or more paths for matching .BEK files and unlocks locked
BitLocker volumes that use external key protectors.

## EXAMPLES

### EXAMPLE 1
```
Unlock-MyBitLockerExternalKey -Path 'D:\BitLockerBackup'
Unlocks volumes using matching .BEK files in the specified folder.
```

### EXAMPLE 2
```
Unlock-MyBitLockerExternalKey -Path 'D:\BitLockerBackup' -Recurse
Unlocks volumes using matching .BEK files found recursively.
```

## PARAMETERS

### -Path
One or more folders to search for matching .BEK external key files.

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
Searches subdirectories under each path for matching key files.

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
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

