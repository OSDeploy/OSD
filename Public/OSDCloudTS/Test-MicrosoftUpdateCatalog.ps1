function Test-MicrosoftUpdateCatalog {
    <#
    .SYNOPSIS
    Tests connectivity to Microsoft Update Catalog.

    .DESCRIPTION
    Sends an HTTP request to Microsoft Update Catalog and returns True when the
    endpoint is reachable with a successful or redirect status code. Uses a
    HEAD request first, then falls back to GET if needed.

    .PARAMETER Uri
    The Microsoft Update Catalog endpoint to test.

    .PARAMETER TimeoutSec
    Timeout in seconds for each HTTP request attempt.

    .EXAMPLE
    Test-MicrosoftUpdateCatalog
    Returns True when the default Microsoft Update Catalog endpoint is reachable.

    .EXAMPLE
    Test-MicrosoftUpdateCatalog -TimeoutSec 5
    Tests connectivity with a shorter timeout.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Improved request resilience and added comment-based help
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Uri = 'https://www.catalog.update.microsoft.com',

        [Parameter()]
        [ValidateRange(1, 120)]
        [int]$TimeoutSec = 15
    )

    $requestParams = @{
        Uri         = $Uri
        Method      = 'Head'
        TimeoutSec  = $TimeoutSec
        ErrorAction = 'Stop'
    }

    if ($PSVersionTable.PSVersion.Major -eq 5) {
        $requestParams.UseBasicParsing = $true
    }

    try {
        $response = Invoke-WebRequest @requestParams
    }
    catch {
        $fallbackParams = @{
            Uri         = $Uri
            Method      = 'Get'
            TimeoutSec  = $TimeoutSec
            ErrorAction = 'Stop'
        }

        if ($PSVersionTable.PSVersion.Major -eq 5) {
            $fallbackParams.UseBasicParsing = $true
        }

        try {
            $response = Invoke-WebRequest @fallbackParams
        }
        catch {
            Write-Verbose "Test-MicrosoftUpdateCatalog: $($_.Exception.Message)"
            return $false
        }
    }

    if ($null -eq $response -or $null -eq $response.StatusCode) {
        return $false
    }

    $statusCode = [int]$response.StatusCode
    return ($statusCode -ge 200 -and $statusCode -lt 400)
}
