---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Test-OSDCloudFileWim

## SYNOPSIS
Tests if a .wim, .esd, or .install.swm file exists in the specified directory.

## SYNTAX

```
Test-OSDCloudFileWim [-ImageFileItem] <string> [<CommonParameters>]
```

## DESCRIPTION
This function checks whether a .wim, .esd, or .install.swm file exists at the given path. It uses the Get-PSDrive cmdlet to search through available file system drives (excluding C:\ and X:\), and then it attempts to find a matching file. If a matching file is found, the function returns the file object. If no such file exists, the function returns nothing.
## EXAMPLES

### Example 1 - Check if a WIM file exists
```powershell
PS C:\> Test-OSDCloudFileWim -ImageFileItem "D:\images\install.wim"
```
This command will search for install.wim in the D:\images\ directory. If it exists, it returns the file object.

## PARAMETERS

### -ImageFileItem
The path to the image file or directory (e.g., D:\images\install.wim). The function will check for .wim, .esd, or .install.swm files in the specified path.

```yaml
Type: String
Required: true
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
## RELATED LINKS
[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)
