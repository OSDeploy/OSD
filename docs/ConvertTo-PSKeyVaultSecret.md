---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com
schema: 2.0.0
---

# ConvertTo-PSKeyVaultSecret

## SYNOPSIS
Converts a value to an Azure Key Vault Secret

## SYNTAX

### FromUriContent (Default)
```
ConvertTo-PSKeyVaultSecret -VaultName <String> -Name <String> -Uri <Uri> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### FromClipboard
```
ConvertTo-PSKeyVaultSecret -VaultName <String> -Name <String> [-Clipboard] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### FromFile
```
ConvertTo-PSKeyVaultSecret -VaultName <String> -Name <String> -File <FileInfo>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### FromString
```
ConvertTo-PSKeyVaultSecret -VaultName <String> -Name <String> -String <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Converts a value to an Azure Key Vault Secret

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -VaultName
Specifies the name of the key vault to which the secret belongs.
This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Vault

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the secret to set

```yaml
Type: String
Parameter Sets: (All)
Aliases: Secret, SecretName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Uri content to set as the Azure Key Vault secret

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
Clipboard raw text to set as the Azure Key Vault secret

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
File content to set as the Azure Key Vault secret

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
String to set as the Azure Key Vault secret

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

## RELATED LINKS

[https://osd.osdeploy.com](https://osd.osdeploy.com)

