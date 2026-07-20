function Test-WebConnection
{
    <#
    .SYNOPSIS
    Tests web connectivity to a target URI using a live TCP connection and HTTP HEAD request.

    .DESCRIPTION
    Opens a live TCP connection and sends HTTP HEAD requests to the specified
    URI, returning $true when the request succeeds and $false otherwise. If a URI
    is provided without a scheme, both https:// and http:// are tested.

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
    2026-07-20 - Added live TCP validation before HTTP HEAD to avoid cached success responses
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
            if ($RequestUri.Scheme -in @('http','https')) {
                $RequestPort = $RequestUri.Port
                if ($RequestUri.IsDefaultPort) {
                    if ($RequestUri.Scheme -eq 'https') {
                        $RequestPort = 443
                    }
                    else {
                        $RequestPort = 80
                    }
                }

                $TcpClient = New-Object System.Net.Sockets.TcpClient
                try {
                    $ConnectTask = $TcpClient.ConnectAsync($RequestUri.DnsSafeHost, $RequestPort)
                    if (-not $ConnectTask.Wait(15000) -or -not $TcpClient.Connected) {
                        throw "TCP connection failed."
                    }
                }
                catch {
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Test-WebConnection TCP FAIL: $RequestUri"
                    [pscustomobject]@{
                        Uri     = $RequestUri
                        Success = $false
                    }
                    continue
                }
                finally {
                    $TcpClient.Close()
                }
            }

            $Params = @{
                Method      = 'Head'
                Uri         = $RequestUri
                Headers     = @{'Cache-Control'='no-cache, no-store'; 'Pragma'='no-cache'}
                ErrorAction = 'Stop'
            }

            if ($InvokeWebRequestCommand.Parameters.ContainsKey('UseBasicParsing')) {
                $Params['UseBasicParsing'] = $true
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('TimeoutSec')) {
                $Params['TimeoutSec'] = 15
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('DisableKeepAlive')) {
                $Params['DisableKeepAlive'] = $true
            }

            $PreviousCachePolicy = [System.Net.WebRequest]::DefaultCachePolicy
            try {
                [System.Net.WebRequest]::DefaultCachePolicy = New-Object System.Net.Cache.RequestCachePolicy ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
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
            finally {
                [System.Net.WebRequest]::DefaultCachePolicy = $PreviousCachePolicy
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
