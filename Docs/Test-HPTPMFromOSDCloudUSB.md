---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Test-HPTPMFromOSDCloudUSB

## SYNOPSIS
Tests whether HP TPM firmware packages exist on an OSDCloud USB drive.

## SYNTAX

```
Test-HPTPMFromOSDCloudUSB [[-PackageID] <String>] [-TryToCopy] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Searches for HP TPM firmware softpaq files (SP87753 and/or SP94937) on a connected
OSDCloud USB volume.
If found, optionally copies them to C:\OSDCloud\HP for local use.
Returns $true if the requested package(s) are found, otherwise $false.

## EXAMPLES

### EXAMPLE 1
```
Test-HPTPMFromOSDCloudUSB -PackageID SP94937
Returns $true if SP94937.exe exists on the OSDCloud USB and copies it to C:\OSDCloud\HP.
```

### EXAMPLE 2
```
Test-HPTPMFromOSDCloudUSB
Returns $true only if both SP87753.exe and SP94937.exe exist on the OSDCloud USB.
```

## PARAMETERS

### -PackageID
The HP softpaq package ID to check for.
Valid values are 'SP87753' or 'SP94937'.
If not specified, both packages are checked.

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

### -TryToCopy
Switch to indicate that found firmware files should be copied to C:\OSDCloud\HP.
Note: this parameter is currently unreachable due to early return statements when
a PackageID is specified.

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

### System.Boolean
## NOTES

## RELATED LINKS
