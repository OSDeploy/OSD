---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-GithubRawUrl

## SYNOPSIS
Resolves a GitHub or Gist URL to one or more raw content URLs.

## SYNTAX

```
Get-GithubRawUrl [-Uri] <Uri[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Converts common GitHub URL forms (blob, raw, and gist) to direct raw content
URLs that can be consumed by download or content retrieval commands.
For gist
pages, the function queries the GitHub Gist API to return raw URLs for all files.

## EXAMPLES

### EXAMPLE 1
```
Get-GithubRawUrl -Uri 'https://github.com/OSDeploy/OSD/blob/master/README.md'
Returns the matching raw.githubusercontent.com URL for README.md.
```

### EXAMPLE 2
```
Get-GithubRawUrl -Uri 'https://gist.github.com/user/0123456789abcdef'
Returns raw URLs for files in the specified gist.
```

## PARAMETERS

### -Uri
A GitHub, Gist, raw URL, or other absolute URI to resolve.

```yaml
Type: Uri[]
Parameter Sets: (All)
Aliases: Url

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
2026-07-13 - Improved URL normalization and gist API handling

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

