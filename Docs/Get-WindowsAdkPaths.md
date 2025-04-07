---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-WindowsAdkPaths

## SYNOPSIS
Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

## SYNTAX

```
Get-WindowsAdkPaths [[-Architecture] <String>] [[-WindowsAdkRoot] <FileInfo>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Architecture
Windows ADK architecture to get.
Valid values are 'amd64', 'x86', and 'arm64'.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Arch

Required: False
Position: 1
Default value: $Env:PROCESSOR_ARCHITECTURE
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WindowsAdkRoot
Path to the Windows ADK root directory.
Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases: AdkRoot

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Author: David Segura

## RELATED LINKS
