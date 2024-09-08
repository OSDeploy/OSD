---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/Docs
schema: 2.0.0
---

# Get-OSDGather

## SYNOPSIS
Returns common OSD information as an ordered hash table

## SYNTAX

```
Get-OSDGather [[-Property] <String>] [-Full] [<CommonParameters>]
```

## DESCRIPTION
Returns common OSD information as an ordered hash table

## EXAMPLES

### EXAMPLE 1
```
OSDGather
```

Get-OSDGather
Returns the Gather Results

### EXAMPLE 2
```
$OSDGather = Get-OSDGather
```

$OSDGather.IsAdmin
$OSDGather.ComputerInfo
Returns the Gather Results saved in a Variable

## PARAMETERS

### -Property
Returns the Name Value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Full
Returns additional CimInstance results

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
19.10.4.0   David Segura @SeguraOSD

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/Docs](https://github.com/OSDeploy/OSD/tree/master/Docs)

