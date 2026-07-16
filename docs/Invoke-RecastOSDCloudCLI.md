---
external help file: OSD-help.xml
Module Name: OSD
online version: https://github.com/OSDeploy/OSD/tree/master/docs
schema: 2.0.0
---

# Invoke-RecastOSDCloudCLI

## SYNOPSIS
Executes the core OSDCloud deployment workflow.

## SYNTAX

```
Invoke-RecastOSDCloudCLI [<CommonParameters>]
```

## DESCRIPTION
Invoke-OSDCloud initializes runtime state in $Global:OSDCloud, merges user-provided configuration
from global customization hashtables, and runs the end-to-end operating system deployment process.

The function is the main execution engine used by OSDCloud entry points such as Start-OSDCloud,
Start-OSDCloudCLI, and GUI launch workflows.
It discovers startup/shutdown scripts, applies
automation artifacts (for example Autopilot JSON), prepares deployment resources, and orchestrates
imaging and post-configuration actions.

This function accepts no direct parameters and relies on module/global state populated earlier in
the launch sequence.

## EXAMPLES

### EXAMPLE 1
```
Invoke-OSDCloud
```

Runs OSDCloud using the current global configuration.

### EXAMPLE 2
```
$Global:MyOSDCloud = [ordered]@{
```

ZTI = $true
    SkipAutopilot = $true
}
Invoke-OSDCloud
Applies custom values from $Global:MyOSDCloud and starts deployment.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. Pipeline input is not supported.
## OUTPUTS

### Primarily host/progress output and state changes in $Global:OSDCloud. The function is intended to
### perform actions rather than emit structured pipeline objects.
## NOTES
- Designed for OSDCloud automation and interactive deployment scenarios in WinPE and full Windows.
- Uses and updates global variables including $Global:OSDCloud, $Global:StartOSDCloud,
  $Global:StartOSDCloudCLI, and $Global:MyOSDCloud when present.
- Should be called from OSDCloud launch functions that prepare prerequisite state.

## RELATED LINKS
