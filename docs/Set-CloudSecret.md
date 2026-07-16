---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Set-CloudSecret

## SYNOPSIS
Convert content to an Azure Key Vault secret.

## SYNTAX

### FromUriContent (Default)
```
Set-CloudSecret [-VaultName] <String> [-Name] <String> -Uri <Uri> [<CommonParameters>]
```

### FromClipboard
```
Set-CloudSecret [-VaultName] <String> [-Name] <String> [-Clipboard] [<CommonParameters>]
```

### FromFile
```
Set-CloudSecret [-VaultName] <String> [-Name] <String> -File <FileInfo> [<CommonParameters>]
```

### FromString
```
Set-CloudSecret [-VaultName] <String> [-Name] <String> -String <String> [<CommonParameters>]
```

## DESCRIPTION
Reads content from a URL, the clipboard, a file, or a raw string and stores it in Azure Key
Vault as a secret.

## EXAMPLES

### EXAMPLE 1
```
Set-CloudSecret -VaultName contoso -Name Script -File .\script.ps1
```

Uploads file contents to Key Vault.

### EXAMPLE 2
```
Set-CloudSecret -VaultName contoso -Name Script -Clipboard
```

Stores clipboard contents in Key Vault.

## PARAMETERS

### -VaultName
Name of the Key Vault that receives the secret.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Vault

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the secret to set.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Secret, SecretName

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
URI content to set as the Azure Key Vault secret.

```yaml
Type: Uri
Parameter Sets: FromUriContent
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clipboard
Clipboard text to set as the Azure Key Vault secret.

```yaml
Type: SwitchParameter
Parameter Sets: FromClipboard
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -File
File content to set as the Azure Key Vault secret.

```yaml
Type: FileInfo
Parameter Sets: FromFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -String
String content to set as the Azure Key Vault secret.

```yaml
Type: String
Parameter Sets: FromString
Aliases:

Required: True
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

