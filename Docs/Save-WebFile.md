---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Save-WebFile

## SYNOPSIS
Downloads a file from the internet and returns a Get-Item Object

## SYNTAX

```
Save-WebFile [-SourceUrl] <String> [-DestinationName <String>] [-DestinationDirectory <String>] [-Overwrite]
 [-WebClient] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Downloads a file from the internet and returns a Get-Item Object

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -SourceUrl
{{ Fill SourceUrl Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: FileUri

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationName
{{ Fill DestinationName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: FileName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationDirectory
{{ Fill DestinationDirectory Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: Named
Default value: (Join-Path $env:TEMP 'OSD')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Overwrite
Overwrite the file if it exists already
The default action is to skip the download

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WebClient
{{ Fill WebClient Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### System.IO.FileInfo
## NOTES

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

