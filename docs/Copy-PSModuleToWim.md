---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Copy-PSModuleToWim

## SYNOPSIS
Copies PowerShell modules into an offline Windows image.

## SYNTAX

```
Copy-PSModuleToWim [[-ExecutionPolicy] <String>] [-ImagePath] <String[]> [[-Index] <UInt32>] [-Name] <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
Mounts one or more WIM images, copies selected modules into the offline
module path, optionally sets the image execution policy, and saves changes.

## EXAMPLES

### EXAMPLE 1
```
Copy-PSModuleToWim -ImagePath 'C:\Media\boot.wim' -Name OSD
```

Copies the latest installed OSD module into index 1 of boot.wim.

### EXAMPLE 2
```
Copy-PSModuleToWim -ImagePath 'C:\Media\boot.wim' -Index 2 -Name OSD -ExecutionPolicy RemoteSigned
```

Copies modules to image index 2 and sets execution policy in the mounted image.

## PARAMETERS

### -ExecutionPolicy
Optional execution policy to set in the mounted image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ImagePath
One or more WIM image file paths to mount and update.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Index
Image index to mount from each WIM.
Default is 1.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
One or more module names to copy into the image.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

