---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# New-WindowsAdkISO

## SYNOPSIS
Creates an .iso file from a bootable media directory. 
ADK is required

## SYNTAX

```
New-WindowsAdkISO [[-WindowsAdkRoot] <FileInfo>] [-MediaPath] <FileInfo> [-isoFileName] <String>
 [-isoLabel] <String> [-OpenExplorer] [<CommonParameters>]
```

## DESCRIPTION
Creates a .iso file from a bootable media directory. 
ADK is required

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -WindowsAdkRoot
Path to the Windows ADK root directory.
Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
if (-NOT (Test-Path "$($_.FullName)\Windows Preinstallation Environment")) { throw "Path does not contain a Windows Preinstallation Environment directory: $_"}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath
Directory containing the bootable media

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoFileName
File Name of the ISO

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isoLabel
Label of the ISO. 
Limited to 16 characters

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenExplorer
Opens Windows Explorer to the parent directory of the ISO File

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
David Segura
25.02.26     Initial Release replacing New-AdkISO
25.03.01     Updated to use Get-WindowsAdkPaths

## RELATED LINKS
