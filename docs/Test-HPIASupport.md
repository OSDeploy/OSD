---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Test-HPIASupport

## SYNOPSIS
Tests whether the current HP platform is supported by HPIA.

## SYNTAX

```
Test-HPIASupport
```

## DESCRIPTION
Downloads the HP platform catalog, reads the platform IDs from the XML, and
compares the local baseboard product ID to determine whether HPIA support is
available on this device.

## EXAMPLES

### EXAMPLE 1
```
Test-HPIASupport
Returns True when the current device platform is listed in the HPIA platform catalog.
```

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)
