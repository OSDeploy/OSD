---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Set-AzClipboard

## SYNOPSIS
Write the current clipboard text to the Azure clipboard Key Vault.

## SYNTAX

```
Set-AzClipboard [[-Name] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Connects to Azure if needed, finds the first Key Vault tagged with AzClipboard, and stores
the current clipboard text in the named secret as plain text.

## EXAMPLES

### EXAMPLE 1
```
Set-AzClipboard
Copies the current clipboard text into the default Clipboard secret.
```

### EXAMPLE 2
```
Set-AzClipboard -Name Clipboard
Copies the current clipboard text into the Clipboard secret explicitly.
```

## PARAMETERS

### -Name
The name of the Key Vault secret to write.
The default secret name is Clipboard.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Clipboard
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
2026-07-10 - Updated help to repo standard

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://github.com/OSDeploy/OSD/blob/master/Docs/Set-AzClipboard.md](https://github.com/OSDeploy/OSD/blob/master/Docs/Set-AzClipboard.md)
