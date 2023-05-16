---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-SessionsXml

## SYNOPSIS
Returns the Session.xml Updates that have been applied to an Operating System

## SYNTAX

```
Get-SessionsXml [[-Path] <String>] [[-KBNumber] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns the Session.xml Updates that have been applied to an Operating System

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service
Or Path of the Sessions.xml file
If this value is not set, the running OS Sessions.xml will be processed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$env:SystemRoot\Servicing\Sessions\Sessions.xml"
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KBNumber
Returns the KBNumber

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

