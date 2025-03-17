---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs/Set-OSDCloudWorkspace.md
schema: 2.0.0
---

# Set-SetupCompleteOSDCloudUSB

## SYNOPSIS
This function copies SetupComplete Files to the Local OSDCloud SetupComplete Folder
Then onfigures the System SetupComplete.ps1 File to run the Custom Scripts from the OSDCloud SetupComplete Folder.

## SYNTAX

```
Set-SetupCompleteOSDCloudUSB
```

## DESCRIPTION
This function checks for the presence of an OSDCLoud SetupComplete Folder on any drive other than 'C'.
Sorts the drives in Descending order and returns $true if the SetupComplete Folder with files inside is found.
Copies the SetupComplete Files to the Local OSDCloud SetupComplete Folder.
Then onfigures the System SetupComplete.ps1 File to run the Custom Scripts from the OSDCloud SetupComplete Folder.

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
