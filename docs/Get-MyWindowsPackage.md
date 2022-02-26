---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/dism/get-mywindowspackage
schema: 2.0.0
---

# Get-MyWindowsPackage

## SYNOPSIS
Gets information about packages in a Windows image. 
Modified version of Get-WindowsPackage

## SYNTAX

### Online (Default)
```
Get-MyWindowsPackage [-PackageState <String>] [-ReleaseType <String>] [-Category <String>]
 [-Culture <String[]>] [-Like <String[]>] [-Match <String[]>] [-Detail] [<CommonParameters>]
```

### Offline
```
Get-MyWindowsPackage -Path <String> [-PackageState <String>] [-ReleaseType <String>] [-Category <String>]
 [-Culture <String[]>] [-Like <String[]>] [-Match <String[]>] [-Detail] [<CommonParameters>]
```

## DESCRIPTION
The Get-MyWindowsPackage cmdlet gets information about all packages in a Windows image or about a specific package that is provided as a .cab file.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service.
Get-MyWindowsPackage -Path C:\Temp\MountedWim

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

### -PackageState
Installation state of the Windows Package
Get-MyWindowsPackage -PackageState Installed
Get-MyWindowsPackage -PackageState Superseded

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

### -ReleaseType
ReleaseType of the Windows Package
Get-MyWindowsPackage -ReleaseType FeaturePack
Get-MyWindowsPackage -ReleaseType Foundation
Get-MyWindowsPackage -ReleaseType LanguagePack
Get-MyWindowsPackage -ReleaseType OnDemandPack
Get-MyWindowsPackage -ReleaseType SecurityUpdate
Get-MyWindowsPackage -ReleaseType Update

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
Category of the Windows Package
Get-MyWindowsPackage -Category FOD
Get-MyWindowsPackage -Category Language
Get-MyWindowsPackage -Category LanguagePack
Get-MyWindowsPackage -Category Update
Get-MyWindowsPackage -Category Other

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
Culture of the Package
Get-MyWindowsPackage -Culture 'de-DE'
Get-MyWindowsPackage -Culture 'de-DE','es-ES','fr-FR'

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
Searches the PackageName for the specified string. 
Wildcards are permitted
Get-MyWindowsPackage -Like "*Tools*"

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
Searches the Package Name for a matching string. 
Wildcards are not permitted
Get-MyWindowsPackage -Match 'Tools'
Get-MyWindowsPackage -Match 'Tools','FoD'

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
Processes a foreach Get-WindowsPackage \<PackageName\> to get further details of the Windows Package

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

### None
## OUTPUTS

### Microsoft.Dism.Commands.BasicPackageObject
### Microsoft.Dism.Commands.AdvancedPackageObject
## NOTES
21.2.8.1    Initial Release
21.2.8.2    Added IsAdmin requirement
            Added validation for Get-WindowsPackage
            Resolved issue if multiple OSD modules are installed
            Renamed Language parameter to Culture
21.2.9.1    Resolved issue with Like and Match parameters not working as expected

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/dism/get-mywindowspackage](https://osd.osdeploy.com/module/functions/dism/get-mywindowspackage)

[https://docs.microsoft.com/en-us/powershell/module/dism/get-windowspackage?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/dism/get-windowspackage?view=win10-ps)

[Add-WindowsPackage]()

[Get-WindowsPackage]()

[Remove-WindowsPackage]()

