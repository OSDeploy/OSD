---
external help file: OSD-help.xml
Module Name: OSD
online version:
schema: 2.0.0
---

# Add-WindowsPackageSSU

## SYNOPSIS
Adds the SSU from a Cumulative Update .cab or .msu to a Windows Image

## SYNTAX

### Offline (Default)
```
Add-WindowsPackageSSU -PackagePath <String> -Path <String> [-LogPath <String>] [<CommonParameters>]
```

### Online
```
Add-WindowsPackageSSU -PackagePath <String> [-Online] [-LogPath <String>] [<CommonParameters>]
```

## DESCRIPTION
The Add-WindowsPackageSSU cmdlet installs a specified .cab or .msu package in the image

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PackagePath
Specifies the location of the package to add to the image

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service.

```yaml
Type: String
Parameter Sets: Offline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Specifies that the action is to be taken on the operating system that is currently running on the local computer.

```yaml
Type: SwitchParameter
Parameter Sets: Online
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogPath
Specifies the full path and file name to log to.
If not set, the default is %WINDIR%\Logs\Dism\dism.log.
In Windows PE, the default directory is the RAMDISK scratch space which can be as low as 32 MB.
The log file will automatically be archived.
The archived log file will be saved with .bak appended to the file name and a new log file will be generated.
Each time the log file is archived the .bak file will be overwritten. 
When using a network share that is not joined to a domain, use the net use command together with domain credentials to set access permissions before you set the log path for the DISM log.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: "$env:windir\Logs\Dism\dism.log"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
