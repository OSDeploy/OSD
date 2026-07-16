function Get-SystemFirmwareDevice {
    <#
    .SYNOPSIS
    Returns the system firmware device

    .DESCRIPTION
    Retrieves the system firmware device by querying Win32_PnpEntity for the System Firmware class GUID.

    .EXAMPLE
    Get-SystemFirmwareDevice
    Returns the system firmware device information

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Improved CIM filtering and error handling
    #>
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [CmdletBinding()]
    param ()

    $SystemFirmwareClassGuid = '{f2e7dd72-6468-4e36-b6f1-6488f42c1b52}'
    $Filter = "ClassGuid = '$SystemFirmwareClassGuid' AND Caption LIKE '%System%'"

    try {
        Get-CimInstance -ClassName Win32_PnpEntity -Filter $Filter -ErrorAction Stop
    }
    catch {
        Write-Verbose "Failed to query Win32_PnpEntity. $_"
        $null
    }
}
function Get-SystemFirmwareResource {
    <#
    .SYNOPSIS
    Returns the GUID of the system firmware resource

    .DESCRIPTION
    Retrieves the system firmware device and extracts GUID values directly from
    its PNP Device ID for use with Microsoft Update Catalog queries.

    .EXAMPLE
    Get-SystemFirmwareResource
    Returns the firmware resource GUID

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Removed dependency on Convert-PNPDeviceIDtoGuid and added local GUID extraction
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param ()

    $UefiFirmwareDevice = Get-SystemFirmwareDevice

    if (-not $UefiFirmwareDevice) {
        Write-Verbose 'Get-SystemFirmwareResource: No system firmware device found.'
        return
    }

    $GuidRegex = [System.Text.RegularExpressions.Regex]::new(
        '(?i)\{?[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\}?',
        [System.Text.RegularExpressions.RegexOptions]::Compiled
    )

    foreach ($Device in @($UefiFirmwareDevice)) {
        $Matches = $GuidRegex.Matches($Device.PNPDeviceID)

        if ($Matches.Count -eq 0) {
            Write-Verbose "Get-SystemFirmwareResource: No GUID found in PNPDeviceID '$($Device.PNPDeviceID)'."
            continue
        }

        foreach ($Match in $Matches) {
            $Match.Value
        }
    }
}
