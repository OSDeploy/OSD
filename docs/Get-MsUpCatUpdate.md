---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Get-MsUpCatUpdate

## SYNOPSIS
Retrieves updates for a specific Windows operating system version from Microsoft Update Catalog

## SYNTAX

```
Get-MsUpCatUpdate [[-OS] <String>] [[-Arch] <String>] [[-Build] <String>] [[-Category] <String>] [-Insider]
 [-ListAvailable] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches Microsoft Update Catalog for updates specific to a Windows operating system and build version.

## EXAMPLES

### EXAMPLE 1
```
Get-MsUpCatUpdate -OS 'Windows 11' -Arch x64 -Build 22H2
Retrieves updates for Windows 11 22H2 x64
```

## PARAMETERS

### -OS
Operating system to search for updates.
Valid values are Windows 11, Windows 10, Windows Server, Windows Server 2016, Windows Server 2019, or Windows Server 2022.
Default is Windows 11.

```yaml
Type: String
Parameter Sets: (All)
Aliases: OperatingSystem

Required: False
Position: 1
Default value: Windows 11
Accept pipeline input: False
Accept wildcard characters: False
```

### -Arch
Processor architecture filter.
Valid values are x64 or x86.
Default is x64.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Architecture

Required: False
Position: 2
Default value: X64
Accept pipeline input: False
Accept wildcard characters: False
```

### -Build
Windows build or release ID.
Valid values include 22H2, 21H2, 21H1, 20H2, and others.
Default is 22H2.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 22H2
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
{{ Fill Category Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: LCU
Accept pipeline input: False
Accept wildcard characters: False
```

### -Insider
{{ Fill Insider Description }}

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

### -ListAvailable
{{ Fill ListAvailable Description }}

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

## NOTES
Author: David Segura - Recast Software
2026-07-10 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
