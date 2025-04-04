---
external help file: OSD-help.xml
Module Name: OSD
online version: https://www.osdcloud.com
schema: 2.0.0
---

# Test-WindowsPackageCAB

## SYNOPSIS
OSDBuilder function that tests the LCU and returns the Package Type

## SYNTAX

```
Test-WindowsPackageCAB [-PackagePath] <String> [[-Path] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
OSDBuilder function that tests the LCU and returns the Package Type

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PackagePath
Path to the Windows update package to test

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

### -Path
Directory path where the Windows Image is mounted

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
Credit to Lasse Meggele @lassemeggele for correcting some issues.
Thanks!

## RELATED LINKS

[https://www.osdcloud.com](https://www.osdcloud.com)

