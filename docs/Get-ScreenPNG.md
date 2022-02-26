---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/general/get-screenpng
schema: 2.0.0
---

# Get-ScreenPNG

## SYNOPSIS
Captures a PowerShell Screenshot

## SYNTAX

```
Get-ScreenPNG [[-Directory] <String>] [[-Prefix] <String>] [[-Delay] <UInt32>] [[-Count] <UInt32>] [-Clipboard]
 [-Primary] [<CommonParameters>]
```

## DESCRIPTION
Captures a PowerShell Screenshot and saves the image in the -Directory $Env:TEMP\Screenshot by default

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Directory
Directory where the Screenshots will be saved
Default = $Env:TEMP\Screenshots

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix
Saved files will have a Screenshot prefix in the filename

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delay
Delay before taking a Screenshot in seconds
Default: 0 (1 Count)
Default: 1 (\>1 Count)

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
Total number of Screenshots to capture
Default = 1

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clipboard
Additionally copies the Screenshot to the Clipboard

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

### -Primary
Screenshot of the Primary Display only

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
21.1.23 Initial Release

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/general/get-screenpng](https://osd.osdeploy.com/module/functions/general/get-screenpng)

