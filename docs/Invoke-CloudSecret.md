---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-CloudSecret

## SYNOPSIS
Invoke a secret retrieved from Azure Key Vault.

## SYNTAX

```
Invoke-CloudSecret [-VaultName] <String> [-Name] <String> [-Invoke <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Loads the named secret with Get-CloudSecret and either invokes it directly, writes it to a
temporary file, or runs it elevated depending on the selected invoke mode.

## EXAMPLES

### EXAMPLE 1
```
Invoke-CloudSecret -VaultName contoso -Name Script
Invokes the retrieved secret in the current session.
```

### EXAMPLE 2
```
Invoke-CloudSecret -VaultName contoso -Name Script -Invoke FileRunas
Writes the secret to a temporary file and runs it elevated.
```

## PARAMETERS

### -VaultName
Name of the Key Vault that contains the secret.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the secret to read.

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

### -Invoke
Choose how to run the secret content: Command, File, or FileRunas.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Command
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
