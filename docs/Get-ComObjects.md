---
external help file: OSD-help.xml
Module Name: OSD
online version: https://osd.osdeploy.com/module/functions/comobj
https://www.powershellmagazine.com/2013/06/27/pstip-get-a-list-of-all-com-objects-available/
schema: 2.0.0
---

# Get-ComObjects

## SYNOPSIS
Returns all ComObjects

## SYNTAX

### FilterByName
```
Get-ComObjects -Filter <String> [<CommonParameters>]
```

### ListAllComObjects
```
Get-ComObjects [-ListAll] [<CommonParameters>]
```

## DESCRIPTION
Returns all ComObjects

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Filter
{{ Fill Filter Description }}

```yaml
Type: String
Parameter Sets: FilterByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListAll
{{ Fill ListAll Description }}

```yaml
Type: SwitchParameter
Parameter Sets: ListAllComObjects
Aliases:

Required: True
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
21.2.3     Initial Release
I'm not quite sure this works as it is not listing the Microsoft Update stuff

## RELATED LINKS

[https://osd.osdeploy.com/module/functions/comobj
https://www.powershellmagazine.com/2013/06/27/pstip-get-a-list-of-all-com-objects-available/](https://osd.osdeploy.com/module/functions/comobj
https://www.powershellmagazine.com/2013/06/27/pstip-get-a-list-of-all-com-objects-available/)

