---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDPad

## SYNOPSIS
Starts the workflow for Start-OSDPad.

## SYNTAX

### Standalone (Default)
```
Start-OSDPad [-Brand <String>] [-Color <String>] [-Hide <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### GitHub
```
Start-OSDPad [-RepoOwner] <String> [-RepoName] <String> [[-RepoFolder] <String>] [-OAuth <String>]
 [-Brand <String>] [-Color <String>] [-Hide <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### GitLab
```
Start-OSDPad [-RepoName] <String> [[-RepoFolder] <String>] -RepoDomain <String> [-OAuth <String>]
 [-Brand <String>] [-Color <String>] [-Hide <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for Start-OSDPad.

## EXAMPLES

### EXAMPLE 1
```
-RepoName <RepoName> -RepoDomain <RepoDomain>
Runs Start-OSDPad with common parameters.
```

## PARAMETERS

### -RepoOwner
Specifies the value for RepoOwner.

```yaml
Type: String
Parameter Sets: GitHub
Aliases: Owner, GitOwner

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoName
Specifies the value for RepoName.

```yaml
Type: String
Parameter Sets: GitHub, GitLab
Aliases: Repository, GitRepo

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoFolder
Specifies the value for RepoFolder.

```yaml
Type: String
Parameter Sets: GitHub, GitLab
Aliases: GitPath, Folder

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoDomain
Specifies the value for RepoDomain.

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

### -OAuth
Specifies the value for OAuth.

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

### -Brand
Specifies the value for Brand.

```yaml
Type: String
Parameter Sets: (All)
Aliases: BrandingTitle

Required: False
Position: Named
Default value: OSDPad
Accept pipeline input: False
Accept wildcard characters: False
```

### -Color
Specifies the value for Color.

```yaml
Type: String
Parameter Sets: (All)
Aliases: BrandingColor

Required: False
Position: Named
Default value: #01786A
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hide
Specifies the value for Hide.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
Author: David Segura - Recast Software
2026-07-09 - Updated comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
