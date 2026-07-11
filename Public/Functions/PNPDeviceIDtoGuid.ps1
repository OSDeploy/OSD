function Convert-PNPDeviceIDtoGuid {
    <#
    .SYNOPSIS
    Extracts GUID values from a PNP Device ID string.

    .DESCRIPTION
    Uses a regular expression to locate and return GUID values embedded in a
    Plug and Play device identifier. Accepts input directly or from the
    pipeline.

    .PARAMETER PNPDeviceID
    PNP device ID string to search for GUID values.

    .EXAMPLE
    Convert-PNPDeviceIDtoGuid -PNPDeviceID 'USB\\VID_1234&PID_5678\\{12345678-1234-1234-1234-1234567890AB}'
    Returns the GUID found in the PNP device ID.

    .EXAMPLE
    'USB\\VID_1234&PID_5678\\{12345678-1234-1234-1234-1234567890AB}' | Convert-PNPDeviceIDtoGuid
    Returns the GUID found in the piped PNP device ID.

    .OUTPUTS
    System.String

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    2026-07-11 - Added pipeline support and improved GUID matching logic
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DeviceID','PNPDeviceId')]
        [ValidateNotNullOrEmpty()]
        [string]$PNPDeviceID
    )

    begin {
        # Match canonical GUID strings with optional curly braces.
        $GuidRegex = [System.Text.RegularExpressions.Regex]::new(
            '(?i)\{?[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\}?',
            [System.Text.RegularExpressions.RegexOptions]::Compiled
        )
    }

    process {
        $Matches = $GuidRegex.Matches($PNPDeviceID)

        if ($Matches.Count -eq 0) {
            Write-Verbose 'Convert-PNPDeviceIDtoGuid: No GUID found in provided PNPDeviceID.'
            return
        }

        foreach ($Match in $Matches) {
            $Match.Value
        }
    }
}
