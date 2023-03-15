---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com
schema: 2.0.0
---

# Get-PSCloudScript

## SYNOPSIS
Development function to get the contents of a PSCloudScript.
Optionally allows for execution by command or file

## SYNTAX

### FromUriContent (Default)
```
Get-PSCloudScript [-Uri] <String> [-Invoke <String>] [<CommonParameters>]
```

### FromAzKeyVaultSecret
```
Get-PSCloudScript -VaultName <String> [-Name <String[]>] [-Invoke <String>] [<CommonParameters>]
```

### FromClipboard
```
Get-PSCloudScript [-Clipboard] [-Invoke <String>] [<CommonParameters>]
```

### FromFile
```
Get-PSCloudScript -File <FileInfo> [-Invoke <String>] [<CommonParameters>]
```

### FromString
```
Get-PSCloudScript -String <String> [-Invoke <String>] [<CommonParameters>]
```

### FromGitHubRepo
```
Get-PSCloudScript -RepoOwner <String> -RepoName <String> [-GithubPath <String>] [-Invoke <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Development function to get the contents of a PSCloudScript.
Optionally allows for execution by command or file

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Uri
Uri content to use as a PSCloudScript

```yaml
Type: String
Parameter Sets: FromUriContent
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultName
Specifies the name of the key vault to which the secret belongs.
This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.

```yaml
Type: String
Parameter Sets: FromAzKeyVaultSecret
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the secret to get the content to use as a PSCloudScript

```yaml
Type: String[]
Parameter Sets: FromAzKeyVaultSecret
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clipboard
Clipboard raw text to use as a PSCloudScript

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
File content to use as a PSCloudScript

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
String to use as a PSCloudScript

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

### -RepoOwner
GitHub Organization

```yaml
Type: String
Parameter Sets: FromGitHubRepo
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoName
GitHub Repo

```yaml
Type: String
Parameter Sets: FromGitHubRepo
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GithubPath
GitHub Path

```yaml
Type: String
Parameter Sets: FromGitHubRepo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Invoke
{{ Fill Invoke Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

