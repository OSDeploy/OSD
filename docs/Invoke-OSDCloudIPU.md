---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-OSDCloudIPU

## SYNOPSIS
Starts an OSDCloud in-place upgrade workflow.

## SYNTAX

```
Invoke-OSDCloudIPU [-OSName <String>] [-Silent] [-SkipDriverPack] [-NoReboot] [-DownloadOnly]
 [-DiagnosticPrompt] [-SkipFinalize] [-Finalize] [-DynamicUpdate] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Validates elevation, inspects the current device and operating system, resolves the target feature update image, prepares any required driver pack content, and launches Windows Setup with the requested upgrade options.

## EXAMPLES

### EXAMPLE 1
```
Invoke-OSDCloudIPU -OSName 'Windows 11 24H2 x64' -Silent -DynamicUpdate
Downloads the 24H2 x64 image and starts the upgrade with a quiet setup experience and Dynamic Update enabled.
```

## PARAMETERS

### -OSName
Specifies the target feature update image to download and install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Windows 11 24H2 x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -Silent
Runs Windows Setup with the quiet UI mode.

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

### -SkipDriverPack
Prevents driver pack download and integration even when a recommended driver pack is available.

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

### -NoReboot
Prevents Windows Setup from rebooting after the down-level phase completes.

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

### -DownloadOnly
Stops after downloading and preparing upgrade content without launching Setup.

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

### -DiagnosticPrompt
Enables the Windows Setup diagnostic command prompt.

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

### -SkipFinalize
Starts setup operations on the down-level OS without immediately initiating the offline phase.

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

### -Finalize
Completes previously started setup operations and immediately reboots to start the offline phase.

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

### -DynamicUpdate
Enables Windows Setup Dynamic Update so setup can search for and install updates during the upgrade.

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
2026-07-10 - Standardized comment-based help metadata and links.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

[https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files](https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files)

[https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11)
