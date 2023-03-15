---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Start-OSDPad

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Standalone (Default)
```
Start-OSDPad [-Brand <String>] [-Color <String>] [-Hide <String[]>] [<CommonParameters>]
```

### GitHub
```
Start-OSDPad [-RepoOwner] <String> [-RepoName] <String> [[-RepoFolder] <String>] [-OAuth <String>]
 [-Brand <String>] [-Color <String>] [-Hide <String[]>] [<CommonParameters>]
```

### GitLab
```
Start-OSDPad [-RepoName] <String> [[-RepoFolder] <String>] -RepoDomain <String> [-OAuth <String>]
 [-Brand <String>] [-Color <String>] [-Hide <String[]>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Brand
{{ Fill Brand Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: BrandingTitle

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Color
{{ Fill Color Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: BrandingColor

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hide
{{ Fill Hide Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Branding, Script

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OAuth
{{ Fill OAuth Description }}

```yaml
Type: String
Parameter Sets: GitHub, GitLab
Aliases: OAuthToken

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoDomain
{{ Fill RepoDomain Description }}

```yaml
Type: String
Parameter Sets: GitLab
Aliases: GitLabUri

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoFolder
{{ Fill RepoFolder Description }}

```yaml
Type: String
Parameter Sets: GitHub, GitLab
Aliases: GitPath, Folder

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoName
{{ Fill RepoName Description }}

```yaml
Type: String
Parameter Sets: GitHub, GitLab
Aliases: Repository, GitRepo

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoOwner
{{ Fill RepoOwner Description }}

```yaml
Type: String
Parameter Sets: GitHub
Aliases: Owner, GitOwner

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
