---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Test-OSDCloudImageIndex

## SYNOPSIS
Tests if a specific Image Index exists within a provided image file.

## SYNTAX

```
Test-OSDCloudImageIndex [[-ImagePath] <string>] [[-Index] <int>] [<CommonParameters>]
```

## DESCRIPTION
This function checks whether a given Image Index exists within the specified image file. It uses the Get-WindowsImage cmdlet to query the image file and validate if the specified index is available. If the index exists, it returns the ImageIndex value; otherwise, it will return nothing.

## EXAMPLES

### Example 1 - Check if an image index exists
```powershell
PS C:\> Test-OSDCloudImageIndex -ImagePath "install.wim" -Index 3
```
This command will check if the image index 3 exists in the image file located at <drived>\OSDCloud\OS\install.wim. If it exists, the function will return the ImageIndex value.

## PARAMETERS

### -ImagePath
The path to the image file (e.g., D:\OSCloud\OS\install.wim or D:\OSCloud\OS\images\image.esd).

```yaml
Type: String
Required: true
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
### -Index
The index of the image within the image file to check.
```yaml
Type: Int
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
