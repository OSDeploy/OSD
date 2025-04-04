---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Update-MyWindowsImage

## SYNOPSIS
Updates a mounted WIM

## SYNTAX

```
Update-MyWindowsImage [[-Path] <String[]>] [[-Update] <String>] [-BitsTransfer] [-Force]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Updates a mounted WIM files. 
Requires WSUSXML Catalog

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies the full path to the root directory of the offline Windows image that you will service

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Update
Check or Install the specified Update Group
Check = Validate installed Updates
All = Install all required Updates
AdobeSU = Adobe Security Update
DotNet = DotNet Update
DotNetCU = DotNet Cumulative Update
LCU = Latest Cumulative Update
SSU = Servicing Stack Update

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Check
Accept pipeline input: False
Accept wildcard characters: False
```

### -BitsTransfer
Download the file using BITS-Transfer
Interactive Login required

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

### -Force
Updates are only installed if they are needed
Force parameter will install the update even if it is already installed

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

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

