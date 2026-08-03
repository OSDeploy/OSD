---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Start-ScreenPNGProcess

## SYNOPSIS
Starts a background process to capture screenshots

## SYNTAX

```
Start-ScreenPNGProcess [-Directory] <String> [[-Delay] <UInt32>] [[-Count] <UInt32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Launches a hidden PowerShell process that periodically captures screenshots and saves them to the specified directory.

## EXAMPLES

### EXAMPLE 1
```
Start-ScreenPNGProcess -Directory 'C:\Screenshots'
Starts capturing screenshots with default delay and count
```

### EXAMPLE 2
```
Start-ScreenPNGProcess -Directory 'C:\Screenshots' -Count 5 -Delay 3
Starts capturing 5 screenshots with 3-second intervals
```

## PARAMETERS

### -Directory
Directory where screenshots will be saved.
This parameter is mandatory.

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

### -Delay
Delay in seconds between screenshots.
Default is 2 seconds

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
Total number of screenshots to capture.
Default is 9999

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 9999
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
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

