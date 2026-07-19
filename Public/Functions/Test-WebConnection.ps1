function Test-WebConnection
{
    <#
    .SYNOPSIS
    Tests web connectivity to a target URI using an HTTP HEAD request.

    .DESCRIPTION
    Sends HTTP HEAD requests to the specified URI and returns $true when the
    request succeeds, otherwise $false. If a URI is provided without a scheme,
    both https:// and http:// are tested.

    .PARAMETER Uri
    URI to test. Values from the pipeline are supported.

    .EXAMPLE
    Test-WebConnection -Uri 'http://example.com'
    Returns $true when the target responds to an HTTP HEAD request.

    .EXAMPLE
    'google.com' | Test-WebConnection
    Tests a bare URI supplied from the pipeline by checking both HTTPS and HTTP.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and improved request handling
    2026-07-19 - Improved terminating error handling and verbose diagnostics
    2026-07-19 - Added HTTPS and HTTP checks for bare URI values
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
        $InvokeWebRequestCommand = Get-Command Invoke-WebRequest
        $RequestUris = if ($Uri.IsAbsoluteUri) {
            @($Uri)
        }
        else {
            @(
                [System.Uri]::new("https://$($Uri.OriginalString)")
                [System.Uri]::new("http://$($Uri.OriginalString)")
            )
        }

        $Results = foreach ($RequestUri in $RequestUris) {
            $Params = @{
                Method      = 'Head'
                Uri         = $RequestUri
                Headers     = @{'Cache-Control'='no-cache'}
                ErrorAction = 'Stop'
            }

            if ($InvokeWebRequestCommand.Parameters.ContainsKey('UseBasicParsing')) {
                $Params['UseBasicParsing'] = $true
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('TimeoutSec')) {
                $Params['TimeoutSec'] = 15
            }

            try {
                Invoke-WebRequest @Params | Out-Null
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Test-WebConnection OK: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $true
                }
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Test-WebConnection FAIL: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $false
                }
            }
        }

        if (-not $Uri.IsAbsoluteUri) {
            $HttpsResult = $Results | Where-Object {$_.Uri.Scheme -eq 'https'} | Select-Object -First 1
            $HttpResult = $Results | Where-Object {$_.Uri.Scheme -eq 'http'} | Select-Object -First 1

            if (-not $HttpsResult.Success -and $HttpResult.Success) {
                Write-Warning "HTTPS connection failed for $($HttpsResult.Uri), but HTTP connection succeeded for $($HttpResult.Uri). Check the system date and time."
            }
        }

        [bool]($Results | Where-Object {$_.Success} | Select-Object -First 1)
    }
}
