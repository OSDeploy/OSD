---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-GithubRawContent

## SYNOPSIS
Retrieves content from GitHub or Gist raw URLs.

## SYNTAX

```
Get-GithubRawContent [-Uri] <Uri[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves one or more GitHub/Gist URLs to raw content URLs and retrieves the
content for each URL using Invoke-RestMethod.
Failed URLs emit warnings while
successful responses continue to stream to the pipeline.

## EXAMPLES

### EXAMPLE 1
```
Get-GithubRawContent -Uri 'https://github.com/OSDeploy/OSD/blob/master/README.md'
Retrieves the raw README.md content.
```

### EXAMPLE 2
```
'https://gist.github.com/user/0123456789abcdef' | Get-GithubRawContent
Retrieves content for each file in the gist.
```

## PARAMETERS

### -Uri
A GitHub, Gist, raw URL, or other absolute URI to retrieve content from.

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
2026-07-13 - Improved error handling and pipeline support

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
