---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-SetupCompleteOSDCloudUSB

## SYNOPSIS
This function checks for the presence of an OSDCloud SetupComplete Folder on any drive other than 'C'.

## SYNTAX

```
Get-SetupCompleteOSDCloudUSB
```

## DESCRIPTION
This function checks for the presence of an OSDCloud SetupComplete Folder on any drive other than 'C'.
Sorts the drives in Descending order and returns $true if the SetupComplete Folder with files inside is found.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
Sorting in descending order is done to try and have the USB Drive take precedence over any other drives.

## RELATED LINKS
