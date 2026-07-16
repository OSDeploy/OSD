---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Export-OSDCertificatesAsReg

## SYNOPSIS
Exports selected LocalMachine certificates as .reg files.

## SYNTAX

```
Export-OSDCertificatesAsReg [<CommonParameters>]
```

## DESCRIPTION
Prompts for installed certificates and exports matching certificate registry keys from system certificate hives into .reg files under the temporary Certs folder.

## EXAMPLES

### EXAMPLE 1
```
Export-OSDCertificatesAsReg
```

Opens a selection grid and exports registry-backed certificate entries for selected certificates to $env:Temp\Certs.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: David Segura - Recast Software
2026-07-11 - Added comment-based help

## RELATED LINKS

[https://github.com/OSDeploy/OSD/tree/master/docs](https://github.com/OSDeploy/OSD/tree/master/docs)

