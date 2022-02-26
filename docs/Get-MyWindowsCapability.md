---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/dism/get-mywindowscapability
schema: 2.0.0
---

# Get-MyWindowsCapability

## SYNOPSIS
Gets Windows capabilities for an image or a running operating system. 
Modified version of Get-WindowsCapability

## SYNTAX

### Online (Default)
```
Get-MyWindowsCapability [-State <String>] [-Category <String>] [-Culture <String[]>] [-Like <String[]>]
 [-Match <String[]>] [-Detail] [-DisableWSUS] [<CommonParameters>]
```

### Offline
```
Get-MyWindowsCapability -Path <String> [-State <String>] [-Category <String>] [-Culture <String[]>]
 [-Like <String[]>] [-Match <String[]>] [-Detail] [<CommonParameters>]
```

## DESCRIPTION
The Get-MyWindowsCapability function gets Windows capabilities installed in an image or running operating system

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service.

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -State
Installation state of the Windows Capability
Get-MyWindowsCapability -State Installed
Get-MyWindowsCapability -State NotPresent

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
Category of the Windows Capability
Get-MyWindowsCapability -Category Language
Get-MyWindowsCapability -Category Rsat
Get-MyWindowsCapability -Category Other

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Culture
Culture of the Capability
Get-MyWindowsCapability -Culture 'de-DE'
Get-MyWindowsCapability -Culture 'de-DE','es-ES','fr-FR'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Like
Searches the Capability Name for the specified string. 
Wildcards are permitted
Get-MyWindowsCapability -Like "*Dns*"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Match
Searches the Capability Name for a matching string. 
Wildcards are not permitted
Get-MyWindowsCapability -Match 'Dhcp'
Get-MyWindowsCapability -Match 'Dhcp','Rsat'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detail
Processes a foreach Get-WindowsCapability \<Name\> to get further details of the Windows Capability
Get-MyWindowsCapability -Detail

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

### -DisableWSUS
Allows computers configured to Add-WindowsCapability from Windows Update
Temporarily sets the Group Policy 'Download repair content and optional features directly from Windows Update instead of Windows Server Update Services (WSUS)'
Restarts the Windows Update Service
Get-MyWindowsCapability -Culture es-es -Match Basic -State NotPresent -DisableWSUS | Add-WindowsCapability

```yaml
Type: SwitchParameter
Parameter Sets: Online
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

### None
## OUTPUTS

### Microsoft.Dism.Commands.ImageObject
## NOTES
21.2.8.1    Initial Release
21.2.8.2    Added IsAdmin requirement
            Added validation for Get-WindowsCapability
            Resolved issue if multiple OSD modules are installed
            Renamed Language parameter to Culture
21.2.9.1    Added DisableWSUS Parameter
            Resolved issue with Like and Match parameters not working as expected

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/dism/get-mywindowscapability](https://osd.osdeploy.com/module/functions/dism/get-mywindowscapability)

[https://docs.microsoft.com/en-us/powershell/module/dism/get-windowscapability?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/dism/get-windowscapability?view=win10-ps)

[Add-WindowsCapability]()

[Get-WindowsCapability]()

[Remove-WindowsCapability]()

