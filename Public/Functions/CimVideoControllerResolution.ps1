function Get-CimVideoControllerResolution {
    <#
    .SYNOPSIS
    Returns CIM video controller resolution entries for the system display adapter.

    .DESCRIPTION
    Queries CIM_VideoControllerResolution, filters out low resolutions, and returns
    either progressive or interlaced modes based on the selected switch.

    .PARAMETER Interlaced
    Returns interlaced resolutions when specified. By default, progressive
    resolutions are returned.

    .EXAMPLE
    Get-CimVideoControllerResolution
    Returns progressive resolutions with a horizontal resolution of 800 or higher.

    .EXAMPLE
    Get-CimVideoControllerResolution -Interlaced
    Returns interlaced resolutions with a horizontal resolution of 800 or higher.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Updated comment-based help
    #>
    [CmdletBinding()]
    param (

        #Returns Interlaced resolutions
        [System.Management.Automation.SwitchParameter]$Interlaced=$false
    )

    $GetMyVideoControllerResolution = (Get-CimInstance -Class CIM_VideoControllerResolution | Select-Object -Property * | `
    Select-Object SettingID, Caption, HorizontalResolution, VerticalResolution, NumberOfColors, RefreshRate, ScanMode | `
    Sort-Object HorizontalResolution, VerticalResolution -Descending)

    #HorizontalResolution -ge 800
    $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.HorizontalResolution -ge 800}

    if ($Interlaced -eq $true) {
        #Interlaced
        $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.ScanMode -eq 5}
    }
    else {
        $Progressive
        $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.ScanMode -eq 4}
    }

    Return $GetMyVideoControllerResolution
}
