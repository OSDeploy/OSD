---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-IntelWirelessDriverPack

## SYNOPSIS
Returns the Intel Wireless Driver Object

## SYNTAX

```
Get-IntelWirelessDriverPack [[-CompatArch] <String>] [[-CompatOS] <String>] [-Online] [-UpdateModuleCatalog]
 [<CommonParameters>]
```

## DESCRIPTION
Returns the Intel Wireless Driver Object

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CompatArch
{{ Fill CompatArch Description }}

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

### -CompatOS
{{ Fill CompatOS Description }}

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

### -Online
Checks for the latest Online version

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

### -UpdateModuleCatalog
Updates the OSD Module Offline Catalog

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
Modified 24.01.02 - Gary Blok
    Changed method to download the Intel Driver & Support Assistant Catalog Files and extract info from that.
    Intel DSA: https://www.intel.com/content/www/us/en/support/intel-driver-support-assistant.html
    Manual Downloads can be done from here: https://www.intel.com/content/www/us/en/download/18231/intel-proset-wireless-software-and-drivers-for-it-admins.html

Removed support for x86 (32bit)
Removed support for older OSes. 
Only Supports Win10 & 11 now.

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

