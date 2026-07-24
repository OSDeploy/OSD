---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-OSDPadCategories

## SYNOPSIS
Starts the workflow for Start-OSDPadCategories.

## SYNTAX

```
Start-OSDPadCategories [-RepoOwner] <String> [-RepoName] <String> [-OAuth <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides the implementation for Start-OSDPadCategories.

## EXAMPLES

### EXAMPLE 1
```
-RepoName <RepoName>
Runs Start-OSDPadCategories with common parameters.
```

## PARAMETERS

### -RepoOwner
Specifies the value for RepoOwner.

```yaml
Type: String
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases: Repository, GitRepo

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OAuth
Specifies the value for OAuth.

```yaml
Type: String
Parameter Sets: (All)
Aliases: OAuthToken

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

