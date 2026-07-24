---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-OSDCoreOperatingSystemCloudObject

## SYNOPSIS
Tests whether an OSDCore operating system object URL is reachable.

## SYNTAX

```
Test-OSDCoreOperatingSystemCloudObject [[-OperatingSystemCloudObject] <PSObject>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads the Url property from the supplied operating system object, or from
$global:OSDCoreOperatingSystemCloudObject when no object is supplied, and returns
$true when a live TCP connection and HTTP HEAD request can reach it.
Returns $false when the object
is missing, the Url property is empty, or the URL test fails.
HTTP and HTTPS
are both tested for host-only web URLs so systems with an invalid date can still
detect basic network reachability over HTTP.
Specific absolute file URLs are
tested exactly as supplied.

## EXAMPLES

### EXAMPLE 1
```
Test-OSDCoreOperatingSystemCloudObject
Tests the Url property on $global:OSDCoreOperatingSystemCloudObject.
```

### EXAMPLE 2
```
Test-OSDCoreOperatingSystemCloudObject -OperatingSystemCloudObject $global:OSDCoreOperatingSystemCloudObject
Tests the Url property on the supplied operating system object.
```

## PARAMETERS

### -OperatingSystemCloudObject
Operating system object containing a Url property to test.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $global:OSDCoreOperatingSystemCloudObject
Accept pipeline input: True (ByValue)
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
Author: David Segura - Recast Software
2026-07-19 - Initial private helper created
2026-07-19 - Removed Test-WebConnection dependency
2026-07-19 - Preserved supplied scheme for specific file URLs
2026-07-20 - Added live TCP validation before HTTP HEAD to avoid cached success responses

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

