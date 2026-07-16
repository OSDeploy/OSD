function Test-WebConnection
{
    <#
    .SYNOPSIS
    Tests web connectivity to a target URI using an HTTP HEAD request.

    .DESCRIPTION
    Sends an HTTP HEAD request to the specified URI and returns `$true` when the
    request succeeds, otherwise `$false`. If a URI is provided without a scheme,
    `http://` is assumed.

    .PARAMETER Uri
    URI to test. Values from the pipeline are supported.

    .EXAMPLE
    Test-WebConnection -Uri 'http://example.com'
    Returns `$true` when the target responds to an HTTP HEAD request.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and improved request handling
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        # Uri to test
        [System.Uri]
        $Uri = 'http://www.google.com'
    )
    process {
        $RequestUri = $Uri
        if (-not $RequestUri.IsAbsoluteUri) {
            $RequestUri = [System.Uri]::new("http://$($RequestUri.OriginalString)")
        }

        $Params = @{
            Method  = 'Head'
            Uri     = $RequestUri
            Headers = @{'Cache-Control'='no-cache'}
        }

        if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey('UseBasicParsing')) {
            $Params['UseBasicParsing'] = $true
        }
        if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey('TimeoutSec')) {
            $Params['TimeoutSec'] = 15
        }

        try {
            Invoke-WebRequest @Params | Out-Null
            Write-Verbose "Test-WebConnection OK: $RequestUri"
            $true
        }
        catch {
            Write-Verbose "Test-WebConnection FAIL: $RequestUri"
            $false
        }
    }
}
